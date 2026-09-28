<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * Display a listing of users
     */
    public function index(Request $request)
    {
        $query = User::with(['stores:id,name,code']);

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ILIKE', "%{$search}%")
                  ->orWhere('email', 'ILIKE', "%{$search}%")
                  ->orWhere('phone', 'ILIKE', "%{$search}%");
            });
        }

        // Filter by role
        if ($request->has('role')) {
            $query->where('role', $request->role);
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by department
        if ($request->has('department')) {
            $query->where('department', $request->department);
        }

        $users = $query->paginate($request->get('per_page', 15));

        return $this->success([
            'users' => $users->items(),
            'pagination' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        ]);
    }

    /**
     * Store a newly created user
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'nullable|string|max:50',
            'role' => 'required|string|in:admin,store_manager,kitchen_supervisor,cashier,storekeeper,chef',
            'department' => 'nullable|string|max:100',
            'permissions' => 'nullable|array',
            'permissions.*' => 'string',
        ]);

        $validated['password'] = Hash::make($validated['password']);
        $validated['status'] = User::STATUS_ACTIVE;
        $validated['password_changed_at'] = now();

        $user = User::create($validated);
        $user->load(['stores:id,name,code']);

        return $this->success($user, 'User created successfully', 201);
    }

    /**
     * Display the specified user
     */
    public function show(User $user)
    {
        $user->load(['stores:id,name,code', 'storeAssignments:user_id,store_id,role_in_store,can_transfer_to,can_transfer_from']);

        return $this->success($user);
    }

    /**
     * Update the specified user
     */
    public function update(Request $request, User $user)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => ['sometimes', 'required', 'string', 'email', 'max:255', Rule::unique('users')->ignore($user->id)],
            'phone' => 'nullable|string|max:50',
            'role' => 'sometimes|required|string|in:admin,store_manager,kitchen_supervisor,cashier,storekeeper,chef',
            'department' => 'nullable|string|max:100',
            'status' => 'sometimes|required|string|in:Active,Inactive,Suspended',
            'permissions' => 'nullable|array',
            'permissions.*' => 'string',
        ]);

        // Handle password update separately
        if ($request->has('password')) {
            $request->validate([
                'password' => 'required|string|min:8|confirmed',
            ]);
            $validated['password'] = Hash::make($request->password);
            $validated['password_changed_at'] = now();
        }

        $user->update($validated);
        $user->load(['stores:id,name,code']);

        return $this->success($user, 'User updated successfully');
    }

    /**
     * Remove the specified user
     */
    public function destroy(User $user)
    {
        // Soft delete
        $user->delete();

        return $this->success(null, 'User deleted successfully');
    }

    /**
     * Get available roles
     */
    public function roles()
    {
        $roles = [
            ['value' => User::ROLE_ADMIN, 'label' => 'System Administrator'],
            ['value' => User::ROLE_STORE_MANAGER, 'label' => 'Store Manager'],
            ['value' => User::ROLE_KITCHEN_SUPERVISOR, 'label' => 'Kitchen Supervisor'],
            ['value' => User::ROLE_CASHIER, 'label' => 'Cashier'],
            ['value' => User::ROLE_STOREKEEPER, 'label' => 'Storekeeper'],
            ['value' => User::ROLE_CHEF, 'label' => 'Chef'],
        ];

        return $this->success($roles);
    }

    /**
     * Get available permissions
     */
    public function permissions()
    {
        $permissions = [
            'inventory.view', 'inventory.create', 'inventory.update', 'inventory.delete',
            'suppliers.view', 'suppliers.create', 'suppliers.update', 'suppliers.delete',
            'purchases.view', 'purchases.create', 'purchases.update', 'purchases.delete',
            'recipes.view', 'recipes.create', 'recipes.update', 'recipes.delete',
            'waste.view', 'waste.create', 'waste.update', 'waste.delete',
            'expiry.view', 'expiry.update',
            'users.view', 'users.create', 'users.update', 'users.delete',
            'reports.view', 'reports.export',
            'stores.view', 'stores.create', 'stores.update', 'stores.delete',
            'transfers.view', 'transfers.create', 'transfers.approve',
            'barcode.generate', 'barcode.scan',
            'dashboard.view',
        ];

        return $this->success($permissions);
    }
}