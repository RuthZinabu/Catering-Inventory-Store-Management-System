<?php

namespace App\Http\Controllers;

use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class StoreController extends Controller
{
    /**
     * Display a listing of stores
     */
    public function index(Request $request)
    {
        $activeQuery = $request->query('active');
        if (is_string($activeQuery) && in_array(strtolower($activeQuery), ['true', 'false'], true)) {
            $request->query->set(
                'active',
                filter_var($activeQuery, FILTER_VALIDATE_BOOLEAN) ? '1' : '0'
            );
        }

        $filters = $request->validate([
            'search' => 'nullable|string|max:255',
            'type' => ['nullable', 'string', Rule::in($this->storeTypeValues())],
            'active' => 'nullable|boolean',
            'level' => 'nullable|integer|min:0|max:5',
            'parent_store_id' => 'nullable|uuid|exists:stores,id',
            'manager_id' => 'nullable|uuid|exists:users,id',
            'user_id' => 'nullable|uuid|exists:users,id',
            'per_page' => 'nullable|integer|min:1|max:100',
            'sort_by' => [
                'nullable',
                'string',
                Rule::in(['name', 'code', 'store_type', 'store_level', 'created_at', 'updated_at', 'is_active']),
            ],
            'sort_order' => ['nullable', 'string', Rule::in(['asc', 'desc'])],
        ]);

        $user = $request->user();
        $query = Store::with(['manager:id,name,email', 'parentStore:id,name,code']);

        if ($user->role !== 'admin') {
            $query->whereIn('id', $user->stores()->select('stores.id'));
            if (isset($filters['user_id']) && $filters['user_id'] !== $user->id) {
                return $this->forbidden('You may only list stores assigned to your account');
            }
        }

        if (!empty($filters['user_id'])) {
            $query->whereHas('users', fn ($users) => $users->where('users.id', $filters['user_id']));
        }

        if (!empty($filters['search'])) {
            $search = mb_strtolower($filters['search']);
            $query->where(function ($q) use ($search) {
                $pattern = "%{$search}%";
                $q->whereRaw('LOWER(name) LIKE ?', [$pattern])
                    ->orWhereRaw('LOWER(code) LIKE ?', [$pattern])
                    ->orWhereRaw('LOWER(COALESCE(location, \'\')) LIKE ?', [$pattern]);
            });
        }

        if (isset($filters['type'])) {
            $query->where('store_type', $filters['type']);
        }

        if (array_key_exists('active', $filters)) {
            $query->where('is_active', filter_var($filters['active'], FILTER_VALIDATE_BOOLEAN));
        }

        if (isset($filters['level'])) {
            $query->where('store_level', $filters['level']);
        }

        if (!empty($filters['parent_store_id'])) {
            $query->where('parent_store_id', $filters['parent_store_id']);
        }

        if (!empty($filters['manager_id'])) {
            $query->where('manager_id', $filters['manager_id']);
        }

        $stores = $query
            ->orderBy($filters['sort_by'] ?? 'name', $filters['sort_order'] ?? 'asc')
            ->paginate($filters['per_page'] ?? 15);
        $items = collect($stores->items())
            ->map(fn (Store $store) => $this->storePayload($store))
            ->values();

        return $this->success([
            // `items` is used by the Flutter paginated repository; `stores` is
            // kept for the existing search service's response parser.
            'items' => $items,
            'stores' => $items,
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
            'code' => 'required|string|max:50|unique:stores,code',
            'description' => 'nullable|string|max:5000',
            'location' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:255',
            'manager' => 'nullable|string|max:255',
            'parent_store_id' => 'nullable|uuid|exists:stores,id',
            'store_level' => 'nullable|integer|min:0|max:5',
            'manager_id' => 'nullable|uuid|exists:users,id',
            'store_type' => ['nullable', 'string', Rule::in($this->storeTypeValues())],
            'timezone' => 'nullable|timezone',
            'operating_hours' => 'nullable|array',
            'settings' => 'nullable|array',
            'is_active' => 'sometimes|boolean',
        ]);

        $this->validateParentStore($request, $validated['parent_store_id'] ?? null);
        $validated['store_type'] = $validated['store_type'] ?? Store::TYPE_MAIN_WAREHOUSE;
        $validated['store_level'] = $this->resolvedStoreLevel(
            $validated['parent_store_id'] ?? null,
            $validated['store_level'] ?? null
        );
        if (array_key_exists('manager', $validated)) {
            $validated['manager_name'] = $validated['manager'];
            unset($validated['manager']);
        }

        $store = Store::create($validated);
        $store->load(['manager:id,name,email', 'parentStore:id,name,code']);

        return $this->success($this->storePayload($store), 'Store created successfully', 201);
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
            'users:id,name,email,role',
        ]);

        return $this->success($this->storePayload($store));
    }

    /**
     * Update the specified store
     */
    public function update(Request $request, Store $store)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'code' => ['sometimes', 'required', 'string', 'max:50', Rule::unique('stores')->ignore($store->id)],
            'description' => 'nullable|string|max:5000',
            'location' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:255',
            'manager' => 'sometimes|nullable|string|max:255',
            'parent_store_id' => 'nullable|uuid|exists:stores,id',
            'store_level' => 'sometimes|integer|min:0|max:5',
            'manager_id' => 'nullable|uuid|exists:users,id',
            'store_type' => ['sometimes', 'nullable', 'string', Rule::in($this->storeTypeValues())],
            'timezone' => 'nullable|timezone',
            'operating_hours' => 'nullable|array',
            'settings' => 'nullable|array',
            'is_active' => 'sometimes|boolean',
        ]);

        if (array_key_exists('parent_store_id', $validated)) {
            $this->validateParentStore($request, $validated['parent_store_id'], $store);
            $validated['store_level'] = $this->resolvedStoreLevel(
                $validated['parent_store_id'],
                $validated['store_level'] ?? null
            );
        }

        if (array_key_exists('manager', $validated)) {
            $validated['manager_name'] = $validated['manager'];
            unset($validated['manager']);
            if (!array_key_exists('manager_id', $validated)) {
                $validated['manager_id'] = null;
            }
        }

        $syncDescendantLevels = array_key_exists('parent_store_id', $validated)
            || array_key_exists('store_level', $validated);

        DB::transaction(function () use ($store, $validated, $syncDescendantLevels): void {
            $store->update($validated);

            if ($syncDescendantLevels) {
                $this->syncDescendantLevels($store->fresh());
            }
        });

        $store->load(['manager:id,name,email', 'parentStore:id,name,code']);

        return $this->success($this->storePayload($store), 'Store updated successfully');
    }

    /**
     * Remove the specified store
     */
    public function destroy(Store $store)
    {
        // Check if store has children
        if ($store->childStores()->count() > 0) {
            return $this->error('Cannot delete store with child stores', 409);
        }

        // Check if store has stock
        if ($store->stockItems()->count() > 0) {
            return $this->error('Cannot delete store with existing stock items', 409);
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

    /**
     * Keep the store JSON compatible with the Flutter Store model, whose
     * `manager` field is a name string rather than the manager relationship.
     */
    private function storePayload(Store $store): array
    {
        $store->loadMissing('manager:id,name,email');
        $payload = $store->toArray();
        $payload['manager_user'] = $payload['manager'] ?? null;
        $payload['manager'] = $store->manager_name ?: ($store->manager?->name ?? '');

        return $payload;
    }

    private function storeTypeValues(): array
    {
        return [
            Store::TYPE_MAIN_WAREHOUSE,
            Store::TYPE_DRY_FOOD,
            Store::TYPE_COLD_ROOM,
            Store::TYPE_FREEZER,
            Store::TYPE_BEVERAGE,
            Store::TYPE_KITCHEN,
            Store::TYPE_ELECTRONICS,
            Store::TYPE_GENERAL,
        ];
    }

    private function validateParentStore(Request $request, ?string $parentStoreId, ?Store $store = null): void
    {
        if (! $parentStoreId) {
            return;
        }

        $parent = Store::findOrFail($parentStoreId);
        if ($store && ($parent->is($store) || $store->descendants()->contains('id', $parent->id))) {
            abort(422, 'A store cannot be its own parent or a descendant of itself.');
        }

        $user = $request->user();
        if ($user && $user->role !== 'admin' && ! $user->canAccessStore($parent->id)) {
            abort(403, 'You do not have access to the selected parent store.');
        }
    }

    private function resolvedStoreLevel(?string $parentStoreId, ?int $requestedLevel): int
    {
        if ($parentStoreId) {
            $level = Store::findOrFail($parentStoreId)->store_level + 1;
            abort_if($level > 5, 422, 'Store hierarchy cannot be deeper than five levels.');

            return $level;
        }

        return $requestedLevel ?? 0;
    }

    private function syncDescendantLevels(Store $parent): void
    {
        $children = $parent->childStores()->get();
        $childLevel = $parent->store_level + 1;

        abort_if($children->isNotEmpty() && $childLevel > 5, 422, 'Store hierarchy cannot be deeper than five levels.');

        foreach ($children as $child) {
            $child->update(['store_level' => $childLevel]);
            $this->syncDescendantLevels($child);
        }
    }
}