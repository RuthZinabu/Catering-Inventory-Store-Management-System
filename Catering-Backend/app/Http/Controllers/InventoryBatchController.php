<?php

namespace App\Http\Controllers;

use App\Models\InventoryBatch;
use App\Models\StoreStock;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class InventoryBatchController extends Controller
{
    public function index(Request $request)
    {
        $filters = $request->validate([
            'store_id' => 'required|uuid|exists:stores,id',
            'search' => 'nullable|string|max:100',
            'status' => 'nullable|in:Expired,Expiring Soon,OK',
            'per_page' => 'nullable|integer|min:1|max:100',
            'page' => 'nullable|integer|min:1',
        ]);
        abort_unless($request->user()->canAccessStore($filters['store_id']), 403);

        $query = InventoryBatch::query()
            ->with(['item:id,name,code,category,unit', 'store:id,name'])
            ->where('store_id', $filters['store_id'])
            ->where('quantity_remaining', '>', 0);
        if (!empty($filters['search'])) {
            $search = '%'.$filters['search'].'%';
            $query->where(function ($builder) use ($search) {
                $builder->where('lot_number', 'like', $search)
                    ->orWhereHas('item', fn ($items) => $items->where('name', 'like', $search)->orWhere('code', 'like', $search));
            });
        }
        $today = Carbon::today()->toDateString();
        $withinThirtyDays = Carbon::today()->addDays(30)->toDateString();
        match ($filters['status'] ?? null) {
            'Expired' => $query->whereDate('expires_on', '<', $today),
            'Expiring Soon' => $query->whereBetween('expires_on', [$today, $withinThirtyDays]),
            'OK' => $query->whereDate('expires_on', '>', $withinThirtyDays),
            default => null,
        };

        $batches = $query->orderBy('expires_on')->paginate($filters['per_page'] ?? 100);

        return $this->success([
            'items' => $batches->getCollection()->map(fn (InventoryBatch $batch) => $this->serialize($batch))->values(),
            'pagination' => [
                'current_page' => $batches->currentPage(),
                'last_page' => $batches->lastPage(),
                'per_page' => $batches->perPage(),
                'total' => $batches->total(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'store_id' => 'required|uuid|exists:stores,id',
            'item_id' => 'required|uuid|exists:items,id',
            'expires_on' => 'required|date_format:Y-m-d',
            'quantity' => 'required|numeric|gt:0',
            'lot_number' => 'nullable|string|max:100',
            'unit_cost' => 'nullable|numeric|min:0',
        ]);
        abort_unless($request->user()->canAccessStore($validated['store_id']), 403);

        $batch = DB::transaction(function () use ($request, $validated) {
            $stock = StoreStock::query()
                ->where('store_id', $validated['store_id'])
                ->where('item_id', $validated['item_id'])
                ->lockForUpdate()
                ->first();
            if (!$stock) {
                throw ValidationException::withMessages([
                    'item_id' => ['The selected item has no stock at this store.'],
                ]);
            }

            $allocated = (float) InventoryBatch::query()
                ->where('store_id', $validated['store_id'])
                ->where('item_id', $validated['item_id'])
                ->sum('quantity_remaining');
            $quantity = (float) $validated['quantity'];
            if ($allocated + $quantity > (float) $stock->quantity + 0.0005) {
                throw ValidationException::withMessages([
                    'quantity' => ['Tracked batch quantities cannot exceed the current store stock.'],
                ]);
            }

            return InventoryBatch::create([
                'store_id' => $validated['store_id'],
                'item_id' => $validated['item_id'],
                'expires_on' => $validated['expires_on'],
                'quantity_remaining' => $quantity,
                'received_quantity' => $quantity,
                'lot_number' => $validated['lot_number'] ?? null,
                'unit_cost' => $validated['unit_cost'] ?? $stock->current_cost ?? $stock->last_cost,
                'created_by' => $request->user()->id,
            ]);
        });

        return $this->success(
            $this->serialize($batch->load(['item:id,name,code,category,unit', 'store:id,name'])),
            'Inventory batch recorded successfully',
            201
        );
    }

    public function update(Request $request, InventoryBatch $inventoryBatch)
    {
        abort_unless($request->user()->canAccessStore($inventoryBatch->store_id), 403);
        $validated = $request->validate([
            'expires_on' => 'sometimes|required|date_format:Y-m-d',
            'lot_number' => 'sometimes|nullable|string|max:100',
        ]);
        $inventoryBatch->update($validated);

        return $this->success(
            $this->serialize($inventoryBatch->fresh()->load(['item:id,name,code,category,unit', 'store:id,name'])),
            'Inventory batch updated successfully'
        );
    }

    private function serialize(InventoryBatch $batch): array
    {
        $expiresOn = Carbon::parse($batch->expires_on)->startOfDay();
        $today = Carbon::today();
        $days = (int) $today->diffInDays($expiresOn, false);
        $status = $days < 0 ? 'Expired' : ($days <= 30 ? 'Expiring Soon' : 'OK');

        return [
            'id' => $batch->id,
            'store_id' => $batch->store_id,
            'item_id' => $batch->item_id,
            'item' => $batch->item?->name ?? 'Unknown item',
            'category' => $batch->item?->category ?? '',
            'unit' => $batch->item?->unit ?? '',
            'quantity' => (float) $batch->quantity_remaining,
            'received_quantity' => (float) $batch->received_quantity,
            'expiry_date' => $expiresOn->toDateString(),
            'batch_number' => $batch->lot_number ?: 'BATCH-'.strtoupper(substr($batch->id, 0, 8)),
            'location' => $batch->store?->name ?? '',
            'status' => $status,
            'days_until_expiry' => $days,
        ];
    }
}