<?php

namespace App\Http\Controllers;

use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class StoreController extends Controller
{
    /**
     * Display a listing of stores
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Store::with(['manager:id,name,email', 'parentStore:id,name,code']);

        // If not admin, filter to user's accessible stores
        if ($user->role !== 'admin') {
            $userStoreIds = $user->stores->pluck('id')->toArray();
            $query->whereIn('id', $userStoreIds);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ILIKE', "%{$search}%")
                  ->orWhere('code', 'ILIKE', "%{$search}%")
                  ->orWhere('location', 'ILIKE', "%{$search}%");
            });
        }

        // Filter by type
        if ($request->has('type')) {
            $query->where('store_type', $request->type);
        }

        // Filter by status
        if ($request->has('active')) {
            $query->where('is_active', $request->boolean('active'));
        }

        // Filter by level
        if ($request->has('level')) {
            $query->where('store_level', $request->level);
        }

        $stores = $query->paginate($request->get('per_page', 15));

        return $this->success([
            'stores' => $stores->items(),
            'pagination' => [
                'current_page' => $stores->currentPage(),
                'last_page' => $stores->lastPage(),
                'per_page' => $stores->perPage(),
                'total' => $stores->total(),
            ],
        ]);
    }

    /**
     * Store a newly created store
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50|unique:stores',
            'description' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|string|email|max:255',
            'parent_store_id' => 'nullable|uuid|exists:stores,id',
            'store_level' => 'required|integer|min:0|max:5',
            'manager_id' => 'nullable|uuid|exists:users,id',
            'store_type' => 'required|string|in:main_warehouse,dry_food,cold_room,freezer,beverage,kitchen,electronics,general',
            'timezone' => 'nullable|string|max:50',
            'operating_hours' => 'nullable|array',
            'settings' => 'nullable|array',
            'is_active' => 'boolean',
        ]);

        $store = Store::create($validated);
        $store->load(['manager:id,name,email', 'parentStore:id,name,code']);

        return $this->success($store, 'Store created successfully', 201);
    }

    /**
     * Display the specified store
     */
    public function show(Request $request, Store $store)
    {
        // Check if user can access this store
        $user = $request->user();
        if ($user->role !== 'admin' && !$user->canAccessStore($store->id)) {
            return $this->forbidden('You do not have access to this store');
        }

        $store->load([
            'manager:id,name,email',
            'parentStore:id,name,code',
            'childStores:id,name,code,store_type',
            'users:id,name,email,role'
        ]);

        return $this->success($store);
    }

    /**
     * Update the specified store
     */
    public function update(Request $request, Store $store)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'code' => ['sometimes', 'required', 'string', 'max:50', Rule::unique('stores')->ignore($store->id)],
            'description' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|string|email|max:255',
            'parent_store_id' => 'nullable|uuid|exists:stores,id',
            'store_level' => 'sometimes|required|integer|min:0|max:5',
            'manager_id' => 'nullable|uuid|exists:users,id',
            'store_type' => 'sometimes|required|string|in:main_warehouse,dry_food,cold_room,freezer,beverage,kitchen,electronics,general',
            'timezone' => 'nullable|string|max:50',
            'operating_hours' => 'nullable|array',
            'settings' => 'nullable|array',
            'is_active' => 'boolean',
        ]);

        $store->update($validated);
        $store->load(['manager:id,name,email', 'parentStore:id,name,code']);

        return $this->success($store, 'Store updated successfully');
    }

    /**
     * Remove the specified store
     */
    public function destroy(Store $store)
    {
        // Check if store has children
        if ($store->childStores()->count() > 0) {
            return $this->error('Cannot delete store with child stores');
        }

        // Check if store has stock
        if ($store->stockItems()->count() > 0) {
            return $this->error('Cannot delete store with existing stock items');
        }

        $store->delete();

        return $this->success(null, 'Store deleted successfully');
    }

    /**
     * Get store types
     */
    public function types()
    {
        $types = [
            ['value' => Store::TYPE_MAIN_WAREHOUSE, 'label' => 'Main Warehouse'],
            ['value' => Store::TYPE_DRY_FOOD, 'label' => 'Dry Food Storage'],
            ['value' => Store::TYPE_COLD_ROOM, 'label' => 'Cold Room'],
            ['value' => Store::TYPE_FREEZER, 'label' => 'Freezer'],
            ['value' => Store::TYPE_BEVERAGE, 'label' => 'Beverage Storage'],
            ['value' => Store::TYPE_KITCHEN, 'label' => 'Kitchen'],
            ['value' => Store::TYPE_ELECTRONICS, 'label' => 'Electronics Storage'],
            ['value' => Store::TYPE_GENERAL, 'label' => 'General Storage'],
        ];

        return $this->success($types);
    }
}