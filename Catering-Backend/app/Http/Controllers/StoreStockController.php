<?php

namespace App\Http\Controllers;

use App\Models\Store;
use App\Models\Item;
use App\Models\StoreStock;
use App\Models\StockMovement;
use App\Services\OperationalNotificationService;
use App\Enums\StockStatus;
use App\Enums\MovementType;
use App\Enums\ItemType;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

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
            'items' => $stocks->items(),
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

    public function createItem(Request $request, Store $store)
    {
        $validated = $request->validate([
            'item' => 'required|array',
            'item.code' => 'required|string|max:100|unique:items,code',
            'item.name' => 'required|string|max:255',
            'item.description' => 'nullable|string',
            'item.category' => 'required|string|max:100',
            'item.item_type' => 'required|string|in:food,catering,electronics',
            'item.unit' => 'required|string|max:20',
            'item.default_purchase_price' => 'nullable|numeric|min:0',
            'item.supplier_id' => [
                'nullable',
                'uuid',
                Rule::exists('suppliers', 'id')->where('status', 'Active'),
            ],
            'item.shelf_life_days' => 'nullable|integer|min:1',
            'item.requires_refrigeration' => 'nullable|boolean',
            'item.catering_subtype' => ['nullable', Rule::in(['permanent', 'temporary'])],
            'item.brand' => 'nullable|string|max:100',
            'item.model' => 'nullable|string|max:100',
            'item.warranty_period_months' => 'nullable|integer|min:0',
            'quantity' => 'required|numeric|min:0',
            'min_quantity' => 'nullable|numeric|min:0',
            'max_quantity' => 'nullable|numeric|min:0',
            'location_description' => 'nullable|string|max:255',
        ]);

        $itemData = $validated['item'];
        $itemType = ItemType::from($itemData['item_type']);
        if ($itemType === ItemType::FOOD && (isset($itemData['catering_subtype']) || isset($itemData['brand']) || isset($itemData['model']))) {
            return $this->validationError(['item.item_type' => 'Food items cannot include catering or electronics details.']);
        }
        if ($itemType === ItemType::CATERING && (isset($itemData['shelf_life_days']) || isset($itemData['brand']) || isset($itemData['model']))) {
            return $this->validationError(['item.item_type' => 'Catering items cannot include food or electronics details.']);
        }
        if ($itemType === ItemType::ELECTRONICS && (isset($itemData['shelf_life_days']) || isset($itemData['catering_subtype']))) {
            return $this->validationError(['item.item_type' => 'Electronics items cannot include food or catering details.']);
        }

        $stock = DB::transaction(function () use ($request, $store, $validated, $itemData) {
            $item = Item::create([
                ...$itemData,
                'created_by' => $request->user()->id,
            ]);
            $quantity = (float) $validated['quantity'];
            $stock = StoreStock::create([
                'item_id' => $item->id,
                'store_id' => $store->id,
                'quantity' => $quantity,
                'reserved_quantity' => 0,
                'min_quantity' => $validated['min_quantity'] ?? 0,
                'max_quantity' => $validated['max_quantity'] ?? 0,
                'location_description' => $validated['location_description'] ?? null,
                'current_cost' => $itemData['default_purchase_price'] ?? 0,
                'last_cost' => $itemData['default_purchase_price'] ?? 0,
                'status' => StockStatus::HEALTHY,
                'last_counted_at' => now(),
                'last_counted_by' => $request->user()->id,
            ]);
            $stock->updateStatus();

            if ($quantity > 0) {
                StockMovement::create([
                    'item_id' => $item->id,
                    'store_id' => $store->id,
                    'type' => MovementType::STOCK_IN,
                    'quantity' => $quantity,
                    'unit' => $item->unit,
                    'quantity_before' => 0,
                    'quantity_after' => $quantity,
                    'reference_type' => StockMovement::REFERENCE_MANUAL,
                    'note' => 'Opening stock',
                    'performed_by' => $request->user()->id,
                ]);
            }

            return $stock;
        });

        $stock->load(['item.supplier', 'store', 'lastCountedBy:id,name']);
        app(OperationalNotificationService::class)->notifyUsersWithPermission(
            'inventory.view',
            $request->user(),
            'New inventory item',
            "{$stock->item->name} ({$stock->item->code}) was added to the item catalog.",
            'inventory',
            'item',
            $stock->item->id
        );

        return $this->success($stock, 'Stock item created successfully', 201);
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

        $stock = DB::transaction(function () use ($stock, $validated, $request) {
            $stock = StoreStock::whereKey($stock->id)->lockForUpdate()->first();
            if (!$stock) {
                return null;
            }

            if (array_key_exists('quantity', $validated)) {
                $targetQuantity = (float) $validated['quantity'];
                if ($targetQuantity < (float) $stock->reserved_quantity) {
                    return false;
                }

                $quantityDifference = $targetQuantity - (float) $stock->quantity;
                if ($quantityDifference !== 0.0) {
                    $stock->adjustQuantity(
                        $quantityDifference,
                        $request->user(),
                        $validated['adjustment_reason'] ?? null
                    );
                }

                $stock->update([
                    'last_counted_at' => now(),
                    'last_counted_by' => $request->user()->id,
                ]);
            }

            $updateData = collect($validated)->except(['adjustment_reason', 'quantity'])->toArray();
            if (!empty($updateData)) {
                $stock->update($updateData);
            }

            return $stock;
        });

        if ($stock === null) {
            return $this->notFound('Stock item not found in this store');
        }
        if ($stock === false) {
            return $this->error('Quantity cannot be lower than reserved stock', 422);
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