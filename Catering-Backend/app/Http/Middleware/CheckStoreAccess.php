<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckStoreAccess
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        $storeId = $request->route('store');

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Authentication required'
            ], 401);
        }

        // Admins have access to all stores
        if ($user->role === 'admin') {
            return $next($request);
        }

        // Check if user has access to the specific store
        if ($storeId && !$user->canAccessStore($storeId)) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied to this store'
            ], 403);
        }

        return $next($request);
    }
}