<?php

namespace App\Http\Controllers;

use App\Models\Store;
use App\Models\Item;
use App\Models\StoreStock;
use App\Enums\StockStatus;
use Illuminate\Http\Request;

class StoreStockController extends Controller
{
    /**
     * Display stock for a specific store
     */
    public function index(Request $request, Store $store)
    {
        $query = StoreStock::with(['item:id,code,name,unit,item_type', 'lastCountedBy:id,name'])
            ->where('store_id', $store->id);

        // Search by item code or name
        if ($request->has('search')) {
            $search = $request->search;
            $query->whereHas('item', function ($q) use ($search) {
                $q->where('code', 'ILIKE', "%{$search}%")
                  ->orWhere('name', 'ILIKE', "%{$search}%");
            });
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by item type
        if ($request->has('item_type')) {
            $query->whereHas('item', function ($q) use ($request) {
                $q->where('item_type', $request->item_type);
            });
        }

        // Filter by low stock
        if ($request->boolean('low_stock')) {
            $query->lowStock();
        }

        // Filter by out of stock
        if ($request->boolean('out_of_stock')) {
            $query->outOfStock();
        }

        $stocks = $query->paginate($request->get('per_page', 15));

        return $this->success([
            'stocks' => $stocks->items(),
            'store' => [
                'id' => $store->id,
                'name' => $store->name,
                'code' => $store->code,
            ],
            'pagination' => [
                'current_page' => $stocks->currentPage(),
                'last_page' => $stocks->lastPage(),
                'per_page' => $stocks->perPage(),
                'total' => $stocks->total(),
            ],
        ]);
    }

    /**
     * Store new stock item for a store
     */
    public function store(Request $request, Store $store)
    {
        $validated = $request->validate([
            'item_id' => 'required|uuid|exists:items,id',
            'quantity' => 'required|numeric|min:0',
            'min_quantity' => 'nullable|numeric|min:0',
            'max_quantity' => 'nullable|numeric|min:0',
            'reorder_point' => 'nullable|numeric|min:0',
            'location_code' => 'nullable|string|max:50',
            'location_description' => 'nullable|string|max:255',
            'current_cost' => 'nullable|numeric|min:0',
        ]);

        // Check if item already exists in this store
        $existingStock = StoreStock::where('store_id', $store->id)
            ->where('item_id', $validated['item_id'])
            ->first();

        if ($existingStock) {
            return $this->error('Item already exists in this store', 409);
        }

        $validated['store_id'] = $store->id;
        $validated['reserved_quantity'] = 0;
        $validated['status'] = StockStatus::HEALTHY;
        $validated['last_counted_at'] = now();
        $validated['last_counted_by'] = $request->user()->id;

        $stock = StoreStock::create($validated);
        $stock->updateStatus();
        $stock->load(['item:id,code,name,unit,item_type', 'store:id,name,code', 'lastCountedBy:id,name']);

        return $this->success($stock, 'Stock item added successfully', 201);
    }

    /**
     * Display specific stock item
     */
    public function show(Request $request, Store $store, Item $item)
    {
        $stock = StoreStock::with(['item:id,code,name,unit,item_type', 'store:id,name,code', 'lastCountedBy:id,name'])
            ->where('store_id', $store->id)
            ->where('item_id', $item->id)
            ->first();

        if (!$stock) {
            return $this->notFound('Stock item not found in this store');
        }

        return $this->success($stock);
    }

    /**
     * Update stock item
     */
    public function update(Request $request, Store $store, Item $item)
    {
        $stock = StoreStock::where('store_id', $store->id)
            ->where('item_id', $item->id)
            ->first();

        if (!$stock) {
            return $this->notFound('Stock item not found in this store');
        }

        $validated = $request->validate([
            'quantity' => 'sometimes|required|numeric|min:0',
            'min_quantity' => 'nullable|numeric|min:0',
            'max_quantity' => 'nullable|numeric|min:0',
            'reorder_point' => 'nullable|numeric|min:0',
            'location_code' => 'nullable|string|max:50',
            'location_description' => 'nullable|string|max:255',
            'current_cost' => 'nullable|numeric|min:0',
            'adjustment_reason' => 'required_with:quantity|string|max:255',
        ]);

        $oldQuantity = $stock->quantity;

        // If quantity is being updated, record the adjustment
        if (isset($validated['quantity']) && $validated['quantity'] != $oldQuantity) {
            $quantityDifference = $validated['quantity'] - $oldQuantity;
            $stock->adjustQuantity($quantityDifference, $request->user(), $validated['adjustment_reason'] ?? null);
        }

        // Update other fields
        $updateData = collect($validated)->except(['adjustment_reason', 'quantity'])->toArray();
        if (!empty($updateData)) {
            $stock->update($updateData);
        }

        // Update last counted info if quantity changed
        if (isset($validated['quantity'])) {
            $stock->update([
                'last_counted_at' => now(),
                'last_counted_by' => $request->user()->id,
            ]);
        }

        $stock->load(['item:id,code,name,unit,item_type', 'store:id,name,code', 'lastCountedBy:id,name']);

        return $this->success($stock, 'Stock item updated successfully');
    }

    /**
     * Remove stock item from store
     */
    public function destroy(Request $request, Store $store, Item $item)
    {
        $stock = StoreStock::where('store_id', $store->id)
            ->where('item_id', $item->id)
            ->first();

        if (!$stock) {
            return $this->notFound('Stock item not found in this store');
        }

        // Check if there are any reserved quantities
        if ($stock->reserved_quantity > 0) {
            return $this->error('Cannot remove stock item with reserved quantities', 409);
        }

        // Check if there's remaining stock
        if ($stock->quantity > 0) {
            return $this->error('Cannot remove stock item with remaining quantity. Adjust to zero first.', 409);
        }

        $stock->delete();

        return $this->success(null, 'Stock item removed successfully');
    }
}