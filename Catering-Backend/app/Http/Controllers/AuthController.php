<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * User login
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Check if account is locked
        if ($user->isLocked()) {
            throw ValidationException::withMessages([
                'email' => ['Account is temporarily locked due to failed login attempts.'],
            ]);
        }

        // Check if account is active
        if ($user->status !== User::STATUS_ACTIVE) {
            throw ValidationException::withMessages([
                'email' => ['Account is not active.'],
            ]);
        }

        // Verify password
        if (!Hash::check($request->password, $user->password)) {
            $user->incrementLoginAttempts();
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Reset login attempts on successful password verification
        $user->resetLoginAttempts();

        // Complete the login process
        return $this->completeLogin($user, $request->device_name);
    }

    /**
     * Complete the login process and issue token
     */
    private function completeLogin(User $user, string $deviceName)
    {
        // Update last login
        $user->update(['last_login_at' => now()]);

        // Create token
        $token = $user->createToken($deviceName)->plainTextToken;

        // Load user relationships
        $user->load(['stores:id,name,code', 'storeAssignments:user_id,store_id,role_in_store,can_transfer_to,can_transfer_from']);

        return response()->json([
            'success' => true,
            'data' => [
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => config('sanctum.expiration', 1440) * 60,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'permissions' => $user->permissions ?? [],
                    'assigned_stores' => $user->stores->map(function ($store) {
                        $assignment = $store->pivot;
                        return [
                            'store_id' => $store->id,
                            'store_name' => $store->name,
                            'store_code' => $store->code,
                            'role_in_store' => $assignment->role_in_store,
                            'can_transfer_to' => $assignment->can_transfer_to,
                            'can_transfer_from' => $assignment->can_transfer_from,
                        ];
                    }),
                ],
            ],
        ]);
    }

    /**
     * User logout
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Successfully logged out',
        ]);
    }

    /**
     * Get authenticated user profile
     */
    public function profile(Request $request)
    {
        $user = $request->user();
        $user->load(['stores:id,name,code', 'storeAssignments:user_id,store_id,role_in_store,can_transfer_to,can_transfer_from']);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'role' => $user->role,
                'department' => $user->department,
                'status' => $user->status,
                'permissions' => $user->permissions ?? [],
                'assigned_stores' => $user->stores->map(function ($store) {
                    $assignment = $store->pivot;
                    return [
                        'store_id' => $store->id,
                        'store_name' => $store->name,
                        'store_code' => $store->code,
                        'role_in_store' => $assignment->role_in_store,
                        'can_transfer_to' => $assignment->can_transfer_to,
                        'can_transfer_from' => $assignment->can_transfer_from,
                    ];
                }),
                'last_login_at' => $user->last_login_at,
                'created_at' => $user->created_at,
            ],
        ]);
    }

    /**
     * Change the authenticated admin's own password.
     */
    public function changePassword(Request $request)
    {
        $user = $request->user();
        abort_unless(
            $user->role === User::ROLE_ADMIN,
            403,
            'Only administrators can change a password here.'
        );

        $validated = $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed|different:current_password',
        ]);

        if (! Hash::check($validated['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is incorrect.'],
            ]);
        }

        $user->password = $validated['new_password'];
        $user->password_changed_at = now();
        $user->must_change_password = false;
        $user->save();

        return $this->success(null, 'Password updated successfully.');
    }

    /**
     * Refresh token
     */
    public function refresh(Request $request)
    {
        // Delete current token
        $request->user()->currentAccessToken()->delete();

        // Create new token
        $token = $request->user()->createToken($request->header('User-Agent'))->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => config('sanctum.expiration', 1440) * 60,
            ],
        ]);
    }
}