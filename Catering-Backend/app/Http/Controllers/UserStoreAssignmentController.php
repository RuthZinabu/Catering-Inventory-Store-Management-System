<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Store;
use App\Models\UserStoreAssignment;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class UserStoreAssignmentController extends Controller
{
    /**
     * Assign a user to a store
     */
    public function assign(Request $request, User $user)
    {
        $validated = $request->validate([
            'store_id' => 'required|uuid|exists:stores,id',
            'role_in_store' => [
                'required', 
                'string',
                Rule::in([
                    UserStoreAssignment::ROLE_MANAGER,
                    UserStoreAssignment::ROLE_SUPERVISOR,
                    UserStoreAssignment::ROLE_STAFF
                ])
            ],
            'can_transfer_to' => 'boolean',
            'can_transfer_from' => 'boolean',
        ]);

        // Check if store exists
        $store = Store::find($validated['store_id']);
        if (!$store) {
            return $this->notFound('Store not found');
        }

        // Check if assignment already exists
        $existingAssignment = UserStoreAssignment::where('user_id', $user->id)
            ->where('store_id', $validated['store_id'])
            ->first();

        if ($existingAssignment) {
            return $this->error('User is already assigned to this store', 409);
        }

        // Create the assignment
        $assignment = UserStoreAssignment::create([
            'user_id' => $user->id,
            'store_id' => $validated['store_id'],
            'role_in_store' => $validated['role_in_store'],
            'can_transfer_to' => $validated['can_transfer_to'] ?? false,
            'can_transfer_from' => $validated['can_transfer_from'] ?? false,
        ]);

        // Load relationships
        $assignment->load(['user:id,name,email', 'store:id,name,code']);

        return $this->success([
            'assignment' => [
                'id' => $assignment->id,
                'user_id' => $assignment->user_id,
                'store_id' => $assignment->store_id,
                'role_in_store' => $assignment->role_in_store,
                'can_transfer_to' => $assignment->can_transfer_to,
                'can_transfer_from' => $assignment->can_transfer_from,
                'created_at' => $assignment->created_at,
                'user' => [
                    'id' => $assignment->user->id,
                    'name' => $assignment->user->name,
                    'email' => $assignment->user->email,
                ],
                'store' => [
                    'id' => $assignment->store->id,
                    'name' => $assignment->store->name,
                    'code' => $assignment->store->code,
                ],
            ],
        ], 'User assigned to store successfully', 201);
    }

    /**
     * Remove a user's assignment from a store
     */
    public function remove(Request $request, User $user, Store $store)
    {
        // Find the assignment
        $assignment = UserStoreAssignment::where('user_id', $user->id)
            ->where('store_id', $store->id)
            ->first();

        if (!$assignment) {
            return $this->notFound('User assignment to this store not found');
        }

        // Delete the assignment
        $assignment->delete();

        return $this->success(null, 'User assignment removed successfully');
    }
}