<?php

namespace App\Http\Controllers;

use App\Enums\MovementType;
use App\Enums\StockStatus;
use App\Models\KitchenIssue;
use App\Models\StockMovement;
use App\Models\StoreStock;
use App\Services\OperationalNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class KitchenIssueController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'store_id' => 'nullable|uuid|exists:stores,id',
            'status' => ['nullable', Rule::in(['Pending Approval', 'Approved', 'Issued', 'Cancelled'])],
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);
        $user = $request->user();
        $query = KitchenIssue::with([
            'store:id,name,code',
            'requestedBy:id,name',
            'approvedBy:id,name',
            'items.item:id,code,name,category,unit',
        ]);
        if ($user->role !== 'admin') {
            $query->whereIn('store_id', $user->stores()->pluck('stores.id'));
        }
        if (!empty($validated['store_id'])) {
            abort_unless($user->canAccessStore($validated['store_id']), 403);
            $query->where('store_id', $validated['store_id']);
        }
        if (!empty($validated['status'])) {
            $query->where('status', $validated['status']);
        }

        $issues = $query->latest('requested_date')->paginate($validated['per_page'] ?? 50);
        return $this->success([
            'items' => $issues->getCollection()->map(fn (KitchenIssue $issue) => $this->serializeIssue($issue)),
            'pagination' => [
                'current_page' => $issues->currentPage(),
                'last_page' => $issues->lastPage(),
                'per_page' => $issues->perPage(),
                'total' => $issues->total(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $this->validateIssue($request, true);
        abort_unless($request->user()->canAccessStore($validated['store_id']), 403);

        $issue = DB::transaction(function () use ($request, $validated) {
            $issue = KitchenIssue::create([
                'number' => $this->nextNumber(),
                'store_id' => $validated['store_id'],
                'department' => $validated['department'],
                'kitchen' => $validated['kitchen'],
                'requested_by' => $request->user()->id,
                'requested_date' => $validated['requested_date'],
                'status' => 'Pending Approval',
                'notes' => $validated['notes'] ?? null,
                'approval_notes' => $validated['approval_notes'] ?? null,
            ]);
            $this->replaceItems($issue, $validated['items']);
            return $issue;
        });

        app(OperationalNotificationService::class)->notifyStores(
            [$issue->store_id],
            $request->user(),
            'Kitchen issue needs approval',
            "Kitchen issue {$issue->number} was submitted for approval.",
            'kitchen',
            'kitchen_issue',
            $issue->id
        );

        return $this->success($this->serializeIssue($issue->load([
            'store:id,name,code', 'requestedBy:id,name', 'approvedBy:id,name', 'items.item:id,code,name,category,unit',
        ])), 'Kitchen issue request submitted for approval', 201);
    }

    public function show(Request $request, KitchenIssue $kitchenIssue)
    {
        abort_unless($request->user()->canAccessStore($kitchenIssue->store_id), 403);
        return $this->success($this->serializeIssue($kitchenIssue->load([
            'store:id,name,code', 'requestedBy:id,name', 'approvedBy:id,name', 'items.item:id,code,name,category,unit',
        ])));
    }

    public function update(Request $request, KitchenIssue $kitchenIssue)
    {
        abort_unless($request->user()->canAccessStore($kitchenIssue->store_id), 403);
        if ($kitchenIssue->status !== 'Pending Approval') {
            return $this->error('Only pending kitchen issues can be edited.', 409);
        }
        $validated = $this->validateIssue($request, false);
        if (isset($validated['store_id'])) {
            abort_unless($request->user()->canAccessStore($validated['store_id']), 403);
        }
        DB::transaction(function () use ($kitchenIssue, $validated) {
            $kitchenIssue->update(collect($validated)->except('items')->all());
            if (array_key_exists('items', $validated)) {
                $this->replaceItems($kitchenIssue, $validated['items']);
            }
        });
        return $this->success($this->serializeIssue($kitchenIssue->fresh()->load([
            'store:id,name,code', 'requestedBy:id,name', 'approvedBy:id,name', 'items.item:id,code,name,category,unit',
        ])), 'Kitchen issue updated successfully');
    }

    public function approve(Request $request, KitchenIssue $kitchenIssue)
    {
        abort_unless($request->user()->canAccessStore($kitchenIssue->store_id), 403);
        if ($kitchenIssue->status !== 'Pending Approval') {
            return $this->error('Only pending kitchen issues can be approved.', 409);
        }
        $validated = $request->validate(['approval_notes' => 'nullable|string|max:2000']);
        $kitchenIssue->update([
            'status' => 'Approved',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
            'approval_notes' => $validated['approval_notes'] ?? $kitchenIssue->approval_notes,
        ]);
        app(OperationalNotificationService::class)->notifyUser(
            $kitchenIssue->requested_by,
            $request->user(),
            'Kitchen issue approved',
            "Kitchen issue {$kitchenIssue->number} was approved.",
            'kitchen',
            $kitchenIssue->store_id,
            'kitchen_issue',
            $kitchenIssue->id
        );
        return $this->success($this->serializeIssue($kitchenIssue->fresh()->load([
            'store:id,name,code', 'requestedBy:id,name', 'approvedBy:id,name', 'items.item:id,code,name,category,unit',
        ])), 'Kitchen issue approved');
    }

    public function issue(Request $request, KitchenIssue $kitchenIssue)
    {
        abort_unless($request->user()->canAccessStore($kitchenIssue->store_id), 403);
        $issue = DB::transaction(function () use ($request, $kitchenIssue) {
            $issue = KitchenIssue::with('items.item')->whereKey($kitchenIssue->id)->lockForUpdate()->firstOrFail();
            if ($issue->status !== 'Approved') {
                abort(409, 'Only approved kitchen issues can be issued.');
            }

            foreach ($issue->items as $line) {
                $stock = StoreStock::where('item_id', $line->item_id)
                    ->where('store_id', $issue->store_id)
                    ->lockForUpdate()->first();
                $quantity = (float) $line->quantity_requested;
                if (!$stock || (float) $stock->available_quantity < $quantity) {
                    abort(422, "Insufficient available stock for {$line->item->name}.");
                }

                $before = (float) $stock->quantity;
                $after = $before - $quantity;
                $stock->update([
                    'quantity' => $after,
                    'status' => $after <= 0 ? StockStatus::OUT_OF_STOCK : ($after <= (float) $stock->min_quantity ? StockStatus::LOW_STOCK : StockStatus::HEALTHY),
                ]);
                $line->update(['quantity_issued' => $quantity]);
                StockMovement::create([
                    'item_id' => $line->item_id,
                    'store_id' => $issue->store_id,
                    'type' => MovementType::STOCK_OUT,
                    'quantity' => $quantity,
                    'unit' => $line->unit,
                    'quantity_before' => $before,
                    'quantity_after' => $after,
                    'reference_type' => StockMovement::REFERENCE_KITCHEN_ISSUE,
                    'reference_id' => $issue->id,
                    'note' => "Kitchen issue {$issue->number} for {$issue->kitchen}",
                    'performed_by' => $request->user()->id,
                ]);
            }

            $issue->update([
                'status' => 'Issued',
                'issued_by' => $request->user()->id,
                'issued_at' => now(),
            ]);
            return $issue->fresh();
        });

        app(OperationalNotificationService::class)->notifyUser(
            $issue->requested_by,
            $request->user(),
            'Kitchen issue completed',
            "Items for kitchen issue {$issue->number} were issued.",
            'kitchen',
            $issue->store_id,
            'kitchen_issue',
            $issue->id
        );

        return $this->success($this->serializeIssue($issue->load([
            'store:id,name,code', 'requestedBy:id,name', 'approvedBy:id,name', 'items.item:id,code,name,category,unit',
        ])), 'Kitchen issue issued successfully');
    }

    public function destroy(Request $request, KitchenIssue $kitchenIssue)
    {
        abort_unless($request->user()->canAccessStore($kitchenIssue->store_id), 403);
        if (!in_array($kitchenIssue->status, ['Pending Approval', 'Approved'], true)) {
            return $this->error('Issued or cancelled kitchen issues cannot be cancelled.', 409);
        }
        $kitchenIssue->update(['status' => 'Cancelled']);
        return $this->success(null, 'Kitchen issue cancelled');
    }

    private function validateIssue(Request $request, bool $creating): array
    {
        $required = $creating ? ['required'] : ['sometimes', 'required'];
        return $request->validate([
            'store_id' => [...$required, 'uuid', 'exists:stores,id'],
            'department' => [...$required, 'string', 'max:100'],
            'kitchen' => [...$required, 'string', 'max:100'],
            'requested_date' => [...$required, 'date'],
            'notes' => 'nullable|string|max:2000',
            'approval_notes' => 'nullable|string|max:2000',
            'items' => [$creating ? 'required' : 'sometimes', 'array', 'min:1'],
            'items.*.item_id' => ['required_with:items', 'uuid', 'distinct', Rule::exists('items', 'id')->whereNull('deleted_at')->where('is_active', true)],
            'items.*.quantity_requested' => 'required_with:items|numeric|gt:0',
        ]);
    }

    private function replaceItems(KitchenIssue $issue, array $items): void
    {
        $issue->items()->delete();
        foreach ($items as $input) {
            $item = \App\Models\Item::findOrFail($input['item_id']);
            $issue->items()->create([
                'item_id' => $item->id,
                'quantity_requested' => $input['quantity_requested'],
                'unit' => $item->unit,
            ]);
        }
    }

    private function nextNumber(): string
    {
        do {
            $number = 'KI-' . now()->format('Y') . '-' . Str::upper(Str::random(6));
        } while (KitchenIssue::where('number', $number)->exists());
        return $number;
    }

    private function serializeIssue(KitchenIssue $issue): array
    {
        return [
            'id' => $issue->id,
            'number' => $issue->number,
            'store_id' => $issue->store_id,
            'store' => $issue->store?->name ?? '',
            'department' => $issue->department,
            'kitchen' => $issue->kitchen,
            'requested_by' => $issue->requestedBy?->name ?? '',
            'approved_by' => $issue->approvedBy?->name ?? '',
            'issue_date' => $issue->requested_date?->toDateString() ?? '',
            'status' => $issue->status,
            'items_issued' => $issue->items->count(),
            'total_quantity' => (float) $issue->items->sum(fn ($line) => $line->quantity_requested),
            'notes' => $issue->notes ?? '',
            'approval_notes' => $issue->approval_notes ?? '',
            'ingredients' => $issue->items->map(fn ($line) => [
                'item_id' => $line->item_id,
                'name' => $line->item?->name ?? '',
                'category' => $line->item?->category ?? '',
                'unit' => $line->unit,
                'available_stock' => 0,
                'quantity' => (float) $line->quantity_requested,
                'quantity_issued' => (float) ($line->quantity_issued ?? 0),
            ])->values(),
        ];
    }
}