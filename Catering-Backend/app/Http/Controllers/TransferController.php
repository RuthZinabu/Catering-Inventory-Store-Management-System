<?php

namespace App\Http\Controllers;

use App\Enums\MovementType;
use App\Enums\StockStatus;
use App\Models\StockMovement;
use App\Models\StoreStock;
use App\Models\Transfer;
use App\Models\TransferItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class TransferController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'store_id' => 'nullable|uuid|exists:stores,id',
            'status' => ['nullable', Rule::in(['pending', 'approved', 'in_transit', 'received', 'cancelled'])],
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);
        $user = $request->user();
        $query = Transfer::with(['fromStore:id,name,code', 'toStore:id,name,code', 'items.item:id,code,name,unit', 'requestedBy:id,name']);

        if ($user->role !== 'admin') {
            $accessibleStoreIds = $user->stores()->pluck('stores.id');
            $query->whereIn('from_store_id', $accessibleStoreIds)
                ->whereIn('to_store_id', $accessibleStoreIds);
        }
        if (!empty($validated['store_id'])) {
            $storeId = $validated['store_id'];
            $query->where(fn ($builder) => $builder
                ->where('from_store_id', $storeId)
                ->orWhere('to_store_id', $storeId));
        }
        if (!empty($validated['status'])) {
            $query->where('status', $validated['status']);
        }

        $transfers = $query->latest('requested_date')->paginate($validated['per_page'] ?? 50);
        return $this->success([
            'items' => $transfers->getCollection()->map(fn (Transfer $transfer) => $this->serializeTransfer($transfer)),
            'pagination' => [
                'current_page' => $transfers->currentPage(),
                'last_page' => $transfers->lastPage(),
                'per_page' => $transfers->perPage(),
                'total' => $transfers->total(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $this->validateTransfer($request, true);
        abort_if($validated['from_store_id'] === $validated['to_store_id'], 422, 'Source and destination stores must differ.');
        abort_unless($request->user()->canAccessStore($validated['from_store_id']), 403);
        abort_unless($request->user()->canAccessStore($validated['to_store_id']), 403);

        $transfer = DB::transaction(function () use ($request, $validated) {
            $transfer = Transfer::create([
                'transfer_number' => $this->nextNumber(),
                'from_store_id' => $validated['from_store_id'],
                'to_store_id' => $validated['to_store_id'],
                'status' => 'pending',
                'priority' => $validated['priority'] ?? 'normal',
                'requested_by' => $request->user()->id,
                'requested_date' => $validated['requested_date'] ?? now()->toDateString(),
                'required_date' => $validated['required_date'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]);
            $this->replaceItems($transfer, $validated['items']);
            return $transfer;
        });

        return $this->success($this->serializeTransfer($transfer->load([
            'fromStore:id,name,code', 'toStore:id,name,code', 'items.item:id,code,name,unit', 'requestedBy:id,name',
        ])), 'Transfer request created successfully', 201);
    }

    public function show(Request $request, Transfer $transfer)
    {
        $this->authorizeTransferStores($request, $transfer);
        return $this->success($this->serializeTransfer($transfer->load([
            'fromStore:id,name,code', 'toStore:id,name,code', 'items.item:id,code,name,unit', 'requestedBy:id,name',
        ])));
    }

    public function update(Request $request, Transfer $transfer)
    {
        $this->authorizeTransferStores($request, $transfer);
        if ($transfer->status !== 'pending') {
            return $this->error('Only pending transfers can be edited.', 409);
        }
        $validated = $this->validateTransfer($request, false);
        if (isset($validated['from_store_id'])) {
            abort_unless($request->user()->canAccessStore($validated['from_store_id']), 403);
        }
        if (isset($validated['to_store_id'])) {
            abort_unless($request->user()->canAccessStore($validated['to_store_id']), 403);
        }
        DB::transaction(function () use ($transfer, $validated) {
            $transfer->update(collect($validated)->except('items')->all());
            if (array_key_exists('items', $validated)) {
                $this->replaceItems($transfer, $validated['items']);
            }
        });
        return $this->success($this->serializeTransfer($transfer->fresh()->load([
            'fromStore:id,name,code', 'toStore:id,name,code', 'items.item:id,code,name,unit', 'requestedBy:id,name',
        ])), 'Transfer updated successfully');
    }

    public function destroy(Request $request, Transfer $transfer)
    {
        $this->authorizeTransferStores($request, $transfer);
        if ($transfer->status !== 'pending') {
            return $this->error('Only pending transfers can be cancelled.', 409);
        }
        $transfer->update(['status' => 'cancelled']);
        return $this->success(null, 'Transfer cancelled successfully');
    }

    public function approve(Request $request, Transfer $transfer)
    {
        $this->authorizeTransferStores($request, $transfer);
        if ($transfer->status !== 'pending') {
            return $this->error('Only pending transfers can be approved.', 409);
        }
        DB::transaction(function () use ($request, $transfer) {
            $transfer = Transfer::whereKey($transfer->id)->lockForUpdate()->firstOrFail();
            if ($transfer->status !== 'pending') {
                abort(409, 'Only pending transfers can be approved.');
            }
            $transfer->update([
                'status' => 'approved',
                'approved_by' => $request->user()->id,
                'approved_date' => now()->toDateString(),
            ]);
            foreach ($transfer->items as $item) {
                $item->update(['quantity_approved' => $item->quantity_requested]);
            }
        });
        return $this->success($this->serializeTransfer($transfer->fresh()->load([
            'fromStore:id,name,code', 'toStore:id,name,code', 'items.item:id,code,name,unit', 'requestedBy:id,name',
        ])), 'Transfer approved successfully');
    }

    public function ship(Request $request, Transfer $transfer)
    {
        $this->authorizeTransferStores($request, $transfer);
        $transfer = DB::transaction(function () use ($request, $transfer) {
            $transfer = Transfer::with('items.item')->whereKey($transfer->id)->lockForUpdate()->firstOrFail();
            if ($transfer->status !== 'approved') {
                abort(409, 'Only approved transfers can be shipped.');
            }

            foreach ($transfer->items as $line) {
                $stock = StoreStock::where('item_id', $line->item_id)
                    ->where('store_id', $transfer->from_store_id)
                    ->lockForUpdate()->first();
                $quantity = (float) ($line->quantity_approved ?? $line->quantity_requested);
                if (!$stock || (float) $stock->available_quantity < $quantity) {
                    abort(422, "Insufficient available stock for {$line->item->name}.");
                }

                $before = (float) $stock->quantity;
                $after = $before - $quantity;
                $stock->update([
                    'quantity' => $after,
                    'status' => $after <= 0 ? StockStatus::OUT_OF_STOCK : ($after <= (float) $stock->min_quantity ? StockStatus::LOW_STOCK : StockStatus::HEALTHY),
                ]);
                $line->update(['quantity_shipped' => $quantity]);
                StockMovement::create([
                    'item_id' => $line->item_id,
                    'store_id' => $transfer->from_store_id,
                    'type' => MovementType::TRANSFER,
                    'quantity' => $quantity,
                    'unit' => $line->item->unit,
                    'quantity_before' => $before,
                    'quantity_after' => $after,
                    'reference_type' => StockMovement::REFERENCE_TRANSFER,
                    'reference_id' => $transfer->id,
                    'from_store_id' => $transfer->from_store_id,
                    'to_store_id' => $transfer->to_store_id,
                    'note' => "Transfer {$transfer->transfer_number} shipped",
                    'performed_by' => $request->user()->id,
                ]);
            }
            $transfer->update([
                'status' => 'in_transit',
                'shipped_by' => $request->user()->id,
                'shipped_date' => now()->toDateString(),
                'shipping_notes' => $request->input('shipping_notes'),
            ]);
            return $transfer->fresh();
        });

        return $this->success($this->serializeTransfer($transfer->load([
            'fromStore:id,name,code', 'toStore:id,name,code', 'items.item:id,code,name,unit', 'requestedBy:id,name',
        ])), 'Transfer shipped successfully');
    }

    public function receive(Request $request, Transfer $transfer)
    {
        $this->authorizeTransferStores($request, $transfer);
        $validated = $request->validate(['notes' => 'nullable|string|max:2000']);
        $transfer = DB::transaction(function () use ($request, $transfer, $validated) {
            $transfer = Transfer::with('items.item')->whereKey($transfer->id)->lockForUpdate()->firstOrFail();
            if ($transfer->status !== 'in_transit') {
                abort(409, 'Only in-transit transfers can be received.');
            }

            foreach ($transfer->items as $line) {
                $quantity = (float) $line->quantity_shipped;
                if ($quantity <= 0) {
                    abort(409, 'A transfer with no shipped quantity cannot be received.');
                }

                $now = now();
                DB::table('store_stock')->insertOrIgnore([
                    'id' => (string) Str::uuid(),
                    'item_id' => $line->item_id,
                    'store_id' => $transfer->to_store_id,
                    'quantity' => 0,
                    'reserved_quantity' => 0,
                    'current_cost' => $line->unit_cost ?? 0,
                    'last_cost' => $line->unit_cost ?? 0,
                    'status' => StockStatus::OUT_OF_STOCK->value,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
                $stock = StoreStock::where('item_id', $line->item_id)
                    ->where('store_id', $transfer->to_store_id)
                    ->lockForUpdate()->firstOrFail();

                $before = (float) $stock->quantity;
                $after = $before + $quantity;
                $stock->update([
                    'quantity' => $after,
                    'status' => $after <= (float) $stock->min_quantity ? StockStatus::LOW_STOCK : StockStatus::HEALTHY,
                ]);
                $line->update(['quantity_received' => $quantity]);
                StockMovement::create([
                    'item_id' => $line->item_id,
                    'store_id' => $transfer->to_store_id,
                    'type' => MovementType::TRANSFER,
                    'quantity' => $quantity,
                    'unit' => $line->item->unit,
                    'quantity_before' => $before,
                    'quantity_after' => $after,
                    'reference_type' => StockMovement::REFERENCE_TRANSFER,
                    'reference_id' => $transfer->id,
                    'from_store_id' => $transfer->from_store_id,
                    'to_store_id' => $transfer->to_store_id,
                    'note' => "Transfer {$transfer->transfer_number} received",
                    'performed_by' => $request->user()->id,
                ]);
            }

            $transfer->update([
                'status' => 'received',
                'received_by' => $request->user()->id,
                'received_date' => now()->toDateString(),
                'notes' => $validated['notes'] ?? $transfer->notes,
            ]);
            return $transfer->fresh();
        });

        return $this->success($this->serializeTransfer($transfer->load([
            'fromStore:id,name,code', 'toStore:id,name,code', 'items.item:id,code,name,unit', 'requestedBy:id,name',
        ])), 'Transfer received successfully');
    }

    private function validateTransfer(Request $request, bool $creating): array
    {
        $required = $creating ? ['required'] : ['sometimes', 'required'];
        return $request->validate([
            'from_store_id' => [...$required, 'uuid', 'exists:stores,id'],
            'to_store_id' => [...$required, 'uuid', 'exists:stores,id'],
            'requested_date' => ['sometimes', 'date'],
            'required_date' => 'nullable|date|after_or_equal:requested_date',
            'priority' => ['sometimes', Rule::in(['low', 'normal', 'high', 'urgent'])],
            'notes' => 'nullable|string|max:5000',
            'items' => [$creating ? 'required' : 'sometimes', 'array', 'min:1'],
            'items.*.item_id' => ['required_with:items', 'uuid', 'distinct', Rule::exists('items', 'id')->whereNull('deleted_at')->where('is_active', true)],
            'items.*.quantity_requested' => 'required_with:items|numeric|gt:0',
        ]);
    }

    private function replaceItems(Transfer $transfer, array $items): void
    {
        $transfer->items()->delete();
        foreach ($items as $input) {
            $stock = StoreStock::where('item_id', $input['item_id'])
                ->where('store_id', $transfer->from_store_id)->first();
            $transfer->items()->create([
                'item_id' => $input['item_id'],
                'quantity_requested' => $input['quantity_requested'],
                'unit_cost' => $stock?->current_cost,
            ]);
        }
    }

    private function authorizeTransferStores(Request $request, Transfer $transfer): void
    {
        abort_unless($request->user()->canAccessStore($transfer->from_store_id), 403);
        abort_unless($request->user()->canAccessStore($transfer->to_store_id), 403);
    }

    private function nextNumber(): string
    {
        do {
            $number = 'TR-' . now()->format('Y') . '-' . Str::upper(Str::random(6));
        } while (Transfer::where('transfer_number', $number)->exists());

        return $number;
    }

    private function serializeTransfer(Transfer $transfer): array
    {
        return [
            'id' => $transfer->id,
            'number' => $transfer->transfer_number,
            'from_store_id' => $transfer->from_store_id,
            'from_store' => $transfer->fromStore?->name ?? '',
            'to_store_id' => $transfer->to_store_id,
            'to_store' => $transfer->toStore?->name ?? '',
            'status' => $transfer->status,
            'priority' => $transfer->priority,
            'date' => $transfer->requested_date?->toDateString() ?? '',
            'person' => $transfer->requestedBy?->name ?? '',
            'items' => $transfer->items->count(),
            'quantity' => (float) $transfer->items->sum(fn ($item) => $item->quantity_requested),
            'notes' => $transfer->notes ?? '',
            'lines' => $transfer->items->map(fn ($line) => [
                'id' => $line->id,
                'item_id' => $line->item_id,
                'name' => $line->item?->name ?? '',
                'code' => $line->item?->code ?? '',
                'unit' => $line->item?->unit ?? '',
                'quantity_requested' => (float) $line->quantity_requested,
                'quantity_shipped' => (float) ($line->quantity_shipped ?? 0),
                'quantity_received' => (float) ($line->quantity_received ?? 0),
            ])->values(),
        ];
    }
}