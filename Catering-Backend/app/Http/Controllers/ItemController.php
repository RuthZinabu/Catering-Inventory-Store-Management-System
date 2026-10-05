<?php

namespace App\Http\Controllers;

use App\Enums\ItemType;
use App\Models\Item;
use App\Services\OperationalNotificationService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ItemController extends Controller
{
    /**
     * Display a listing of items
     */
    public function index(Request $request)
    {
        $query = Item::with(['creator:id,name']);

        // Search
        if ($request->has('search')) {
            $query->search($request->search);
        }

        // Filter by type
        if ($request->has('type')) {
            $itemType = ItemType::tryFrom($request->type);
            if ($itemType) {
                $query->ofType($itemType);
            }
        }

        // Filter by category
        if ($request->has('category')) {
            $query->ofCategory($request->category);
        }

        // Filter by active status
        if ($request->has('active')) {
            if ($request->boolean('active')) {
                $query->active();
            } else {
                $query->where('is_active', false);
            }
        }

        // Default to active items only
        if (!$request->has('active')) {
            $query->active();
        }

        $items = $query->paginate($request->get('per_page', 15));

        // Transform items to include stock information for Flutter compatibility
        $transformedItems = $items->getCollection()->map(function ($item) {
            return [
                'id' => $item->id,
                'code' => $item->code,
                'name' => $item->name,
                'description' => $item->description ?? '',
                'category' => $item->category,
                'unit' => $item->unit,
                'default_purchase_price' => $item->default_purchase_price ? (float) $item->default_purchase_price : 0.0,
                'item_type' => $item->item_type?->value ?? $item->item_type ?? 'unknown',
                'shelf_life_days' => $item->shelf_life_days,
                'requires_refrigeration' => $item->requires_refrigeration ?? false,
                'catering_subtype' => $item->catering_subtype,
                'brand' => $item->brand,
                'model' => $item->model,
                'warranty_period_months' => $item->warranty_period_months,
                'is_active' => $item->is_active ?? true,
                
                // Stock information for Flutter compatibility (defaulted for now)
                'stock_on_hand' => 0,
                'min_stock' => 0,
                'max_stock' => 0,
                'internal_cost' => $item->default_purchase_price ? (float) $item->default_purchase_price : 0.0,
                'reorder_point' => 0,
                
                // Timestamps
                'created_at' => $item->created_at,
                'updated_at' => $item->updated_at,
            ];
        });

        return $this->success([
            'items' => $transformedItems,
            'pagination' => [
                'current_page' => $items->currentPage(),
                'last_page' => $items->lastPage(),
                'per_page' => $items->perPage(),
                'total' => $items->total(),
            ],
        ]);
    }

    /**
     * Store a newly created item
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'code' => 'required|string|max:100|unique:items',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'required|string|max:100',
            'item_type' => 'required|string|in:food,catering,electronics',
            'unit' => 'required|string|max:20',
            'default_purchase_price' => 'nullable|numeric|min:0',
            
            // Food-specific fields
            'shelf_life_days' => 'nullable|integer|min:1',
            'requires_refrigeration' => 'boolean',
            
            // Catering-specific fields
            'catering_subtype' => 'nullable|string|in:permanent,temporary',
            
            // Electronics-specific fields
            'brand' => 'nullable|string|max:100',
            'model' => 'nullable|string|max:100',
            'warranty_period_months' => 'nullable|integer|min:0',
        ]);

        $validated['created_by'] = $request->user()->id;

        // Validate type-specific fields
        $itemType = ItemType::from($validated['item_type']);
        
        if ($itemType === ItemType::FOOD) {
            if (isset($validated['catering_subtype']) || isset($validated['brand']) || isset($validated['model'])) {
                return $this->validationError([
                    'item_type' => 'Food items cannot have catering or electronics specific fields'
                ]);
            }
        } elseif ($itemType === ItemType::CATERING) {
            if (isset($validated['shelf_life_days']) || isset($validated['brand']) || isset($validated['model'])) {
                return $this->validationError([
                    'item_type' => 'Catering items cannot have food or electronics specific fields'
                ]);
            }
        } elseif ($itemType === ItemType::ELECTRONICS) {
            if (isset($validated['shelf_life_days']) || isset($validated['catering_subtype'])) {
                return $this->validationError([
                    'item_type' => 'Electronics items cannot have food or catering specific fields'
                ]);
            }
        }

        $item = Item::create($validated);
        $item->load(['creator:id,name']);

        app(OperationalNotificationService::class)->notifyUsersWithPermission(
            'inventory.view',
            $request->user(),
            'New inventory item',
            "{$item->name} ({$item->code}) was added to the item catalog.",
            'inventory',
            'item',
            $item->id
        );

        return $this->success($item, 'Item created successfully', 201);
    }

    /**
     * Display the specified item
     */
    public function show(Item $item)
    {
        $item->load([
            'creator:id,name',
            'storeStock' => function ($query) {
                $query->with('store:id,name,code')->where('quantity', '>', 0);
            }
        ]);

        // Add total stock information
        $item->total_stock = $item->total_stock;
        $item->available_stock = $item->available_stock;

        return $this->success($item);
    }

    /**
     * Update the specified item
     */
    public function update(Request $request, Item $item)
    {
        $validated = $request->validate([
            'code' => ['sometimes', 'required', 'string', 'max:100', Rule::unique('items')->ignore($item->id)],
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'sometimes|required|string|max:100',
            'unit' => 'sometimes|required|string|max:20',
            'default_purchase_price' => 'nullable|numeric|min:0',
            
            // Food-specific fields
            'shelf_life_days' => 'nullable|integer|min:1',
            'requires_refrigeration' => 'boolean',
            
            // Catering-specific fields
            'catering_subtype' => 'nullable|string|in:permanent,temporary',
            
            // Electronics-specific fields
            'brand' => 'nullable|string|max:100',
            'model' => 'nullable|string|max:100',
            'warranty_period_months' => 'nullable|integer|min:0',
            
            'is_active' => 'boolean',
        ]);

        // Validate type-specific fields based on existing item type
        if ($item->item_type === ItemType::FOOD) {
            if (isset($validated['catering_subtype']) || isset($validated['brand']) || isset($validated['model'])) {
                return $this->validationError([
                    'item_type' => 'Food items cannot have catering or electronics specific fields'
                ]);
            }
        } elseif ($item->item_type === ItemType::CATERING) {
            if (isset($validated['shelf_life_days']) || isset($validated['brand']) || isset($validated['model'])) {
                return $this->validationError([
                    'item_type' => 'Catering items cannot have food or electronics specific fields'
                ]);
            }
        } elseif ($item->item_type === ItemType::ELECTRONICS) {
            if (isset($validated['shelf_life_days']) || isset($validated['catering_subtype'])) {
                return $this->validationError([
                    'item_type' => 'Electronics items cannot have food or catering specific fields'
                ]);
            }
        }

        $item->update($validated);
        $item->load(['creator:id,name']);

        return $this->success($item, 'Item updated successfully');
    }

    /**
     * Remove the specified item
     */
    public function destroy(Item $item)
    {
        // Check if item has stock in any store
        if ($item->storeStock()->where('quantity', '>', 0)->exists()) {
            return $this->error('Cannot delete item with existing stock');
        }

        // Check if item is used in any recipes
        if ($item->recipeIngredients()->exists()) {
            return $this->error('Cannot delete item that is used in recipes');
        }

        $item->delete();

        return $this->success(null, 'Item deleted successfully');
    }

    /**
     * Search items
     */
    public function search(Request $request)
    {
        $request->validate([
            'q' => 'required|string|min:2',
            'type' => 'nullable|string|in:food,catering,electronics',
            'category' => 'nullable|string',
            'limit' => 'nullable|integer|min:1|max:50',
        ]);

        $query = Item::search($request->q)->active();

        if ($request->has('type')) {
            $itemType = ItemType::tryFrom($request->type);
            if ($itemType) {
                $query->ofType($itemType);
            }
        }

        if ($request->has('category')) {
            $query->ofCategory($request->category);
        }

        $items = $query
            ->orderByRaw('CASE WHEN code = ? THEN 0 ELSE 1 END', [$request->q])
            ->limit($request->get('limit', 20))
            ->get([
                'id',
                'code',
                'name',
                'category',
                'unit',
                'item_type',
                'default_purchase_price',
                'description',
                'is_active',
                'shelf_life_days',
                'requires_refrigeration',
                'created_at',
                'updated_at',
            ])
            ->map(fn (Item $item) => [
                'id' => $item->id,
                'code' => $item->code,
                'name' => $item->name,
                'category' => $item->category,
                'unit' => $item->unit,
                'item_type' => $item->item_type?->value ?? $item->item_type,
                'default_purchase_price' => (float) ($item->default_purchase_price ?? 0),
                'description' => $item->description ?? '',
                'is_active' => (bool) $item->is_active,
                'shelf_life_days' => $item->shelf_life_days,
                'requires_refrigeration' => (bool) $item->requires_refrigeration,
                'created_at' => $item->created_at,
                'updated_at' => $item->updated_at,
            ])
            ->values();

        return $this->success($items);
    }

    /**
     * Get item types
     */
    public function types()
    {
        $types = collect(ItemType::cases())->map(fn($type) => [
            'value' => $type->value,
            'label' => $type->label(),
        ]);

        return $this->success($types);
    }

    /**
     * Get categories by type
     */
    public function categories(Request $request)
    {
        $request->validate([
            'type' => 'nullable|string|in:food,catering,electronics',
        ]);

        $query = Item::select('category')->distinct()->active();

        if ($request->has('type')) {
            $itemType = ItemType::tryFrom($request->type);
            if ($itemType) {
                $query->ofType($itemType);
            }
        }

        $categories = $query->pluck('category')->sort()->values();

        return $this->success($categories);
    }
}