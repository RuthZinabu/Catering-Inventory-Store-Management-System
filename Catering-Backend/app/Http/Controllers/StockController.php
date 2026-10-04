<?php

namespace App\Http\Controllers;

use App\Models\StoreStock;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class StockController extends Controller
{
    /**
     * Display a listing of stock across all accessible stores.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            
            // Get stores accessible to the user
            $accessibleStoreIds = $user->storeAssignments()->pluck('store_id');
            
            if ($user->role === 'admin') {
                // Admin can see all stores
                $accessibleStoreIds = Store::pluck('id');
            }
            
            $query = StoreStock::with(['item.supplier', 'store']);
            
            // An empty store scope must return no stock for non-admin users.
            if ($user->role !== 'admin') {
                $query->whereIn('store_id', $accessibleStoreIds);
            }
            
            // Apply filters
            if ($request->filled('search')) {
                $search = $request->search;
                $query->whereHas('item', function($q) use ($search) {
                    $q->where('name', 'LIKE', "%{$search}%")
                      ->orWhere('code', 'LIKE', "%{$search}%");
                });
            }
            
            if ($request->filled('category')) {
                $query->whereHas('item', function($q) use ($request) {
                    $q->where('category', $request->category);
                });
            }
            
            if ($request->filled('store_id')) {
                $query->where('store_id', $request->store_id);
            }
            
            if ($request->filled('low_stock') && $request->boolean('low_stock')) {
                $query->whereRaw('quantity <= min_quantity');
            }
            
            // Apply sorting
            $sortBy = $request->get('sort_by', 'updated_at');
            $sortOrder = $request->get('sort_order', 'desc');
            
            if ($sortBy === 'item_name') {
                $query->join('items', 'store_stock.item_id', '=', 'items.id')
                      ->orderBy('items.name', $sortOrder)
                      ->select('store_stock.*');
            } else {
                $query->orderBy($sortBy, $sortOrder);
            }
            
            // Paginate results
            $perPage = min($request->get('per_page', 15), 100);
            $stockItems = $query->paginate($perPage);
            
            // Transform the data
            $data = $stockItems->getCollection()->map(function ($stock) {
                return [
                    'id' => $stock->id,
                    'code' => $stock->item->code ?? '',
                    'name' => $stock->item->name ?? '',
                    'category' => $stock->item->category ?? '',
                    'stock_category' => $stock->item->item_type?->value ?? $stock->item->item_type ?? 'food',
                    'unit' => $stock->item->unit ?? '',
                    'purchase_price' => $stock->current_cost ? (float) $stock->current_cost : 0.0,
                    'quantity' => $stock->quantity ? (float) $stock->quantity : 0.0,
                    'min_quantity' => $stock->min_quantity ? (float) $stock->min_quantity : 0.0,
                    'max_quantity' => $stock->max_quantity ? (float) $stock->max_quantity : 0.0,
                    'location' => $stock->location_description ?? $stock->store->name ?? '',
                    'supplier' => $stock->item->supplier?->company
                        ?: ($stock->item->supplier?->name ?? 'Unknown'),
                    'status' => $stock->status?->value ?? 'Unknown',
                    'description' => $stock->item->description ?? '',
                    'last_updated' => $stock->updated_at,
                    
                    // Additional fields for compatibility
                    'item_id' => $stock->item_id,
                    'store_id' => $stock->store_id,
                    'available_quantity' => $stock->available_quantity ? (float) $stock->available_quantity : 0.0,
                    'reserved_quantity' => $stock->reserved_quantity ? (float) $stock->reserved_quantity : 0.0,
                    'reorder_point' => $stock->reorder_point ? (float) $stock->reorder_point : 0.0,
                    
                    // Store details
                    'store' => [
                        'id' => $stock->store->id,
                        'name' => $stock->store->name ?? '',
                        'code' => $stock->store->code ?? '',
                        'store_type' => $stock->store->store_type ?? 'general',
                    ],
                    
                    // Timestamps
                    'created_at' => $stock->created_at,
                    'updated_at' => $stock->updated_at,
                ];
            });
            
            return response()->json([
                'success' => true,
                'data' => [
                    'items' => $data,
                    'pagination' => [
                        'current_page' => $stockItems->currentPage(),
                        'last_page' => $stockItems->lastPage(),
                        'per_page' => $stockItems->perPage(),
                        'total' => $stockItems->total(),
                        'from' => $stockItems->firstItem(),
                        'to' => $stockItems->lastItem(),
                    ],
                ],
            ]);
            
        } catch (\Exception $e) {
            \Log::error('StockController@index error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch stock items',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
            ], 500);
        }
    }
    
    /**
     * Display the specified stock item.
     */
    public function show(Request $request, string $id): JsonResponse
    {
        try {
            $user = $request->user();
            
            $stockItem = StoreStock::with(['item.supplier', 'store'])->findOrFail($id);
            
            // Check if user can access this store
            if ($user->role !== 'admin') {
                $accessibleStoreIds = $user->storeAssignments()->pluck('store_id');
                if (!$accessibleStoreIds->contains($stockItem->store_id)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'You do not have access to this store',
                    ], 403);
                }
            }
            
            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $stockItem->id,
                    'code' => $stockItem->item->code ?? '',
                    'name' => $stockItem->item->name ?? '',
                    'category' => $stockItem->item->category ?? '',
                    'stock_category' => $stockItem->item->item_type?->value ?? $stockItem->item->item_type ?? 'food',
                    'unit' => $stockItem->item->unit ?? '',
                    'purchase_price' => $stockItem->current_cost ? (float) $stockItem->current_cost : 0.0,
                    'quantity' => $stockItem->quantity ? (float) $stockItem->quantity : 0.0,
                    'min_quantity' => $stockItem->min_quantity ? (float) $stockItem->min_quantity : 0.0,
                    'max_quantity' => $stockItem->max_quantity ? (float) $stockItem->max_quantity : 0.0,
                    'location' => $stockItem->location_description ?? $stockItem->store->name ?? '',
                    'supplier' => $stockItem->item->supplier?->company
                        ?: ($stockItem->item->supplier?->name ?? 'Unknown'),
                    'status' => $stockItem->status?->value ?? 'Unknown',
                    'description' => $stockItem->item->description ?? '',
                    'last_updated' => $stockItem->updated_at,
                    
                    // Additional fields for compatibility
                    'item_id' => $stockItem->item_id,
                    'store_id' => $stockItem->store_id,
                    'available_quantity' => $stockItem->available_quantity ? (float) $stockItem->available_quantity : 0.0,
                    'reserved_quantity' => $stockItem->reserved_quantity ? (float) $stockItem->reserved_quantity : 0.0,
                    'reorder_point' => $stockItem->reorder_point ? (float) $stockItem->reorder_point : 0.0,
                    
                    // Store details
                    'store' => [
                        'id' => $stockItem->store->id,
                        'name' => $stockItem->store->name ?? '',
                        'code' => $stockItem->store->code ?? '',
                        'store_type' => $stockItem->store->store_type ?? 'general',
                    ],
                    
                    // Recent stock movements (get from stockMovements relationship)
                    'recent_movements' => $stockItem->stockMovements()
                        ->latest()
                        ->take(10)
                        ->get()
                        ->map(function ($movement) {
                            return [
                                'id' => $movement->id,
                                'type' => $movement->movement_type?->value ?? $movement->movement_type ?? 'unknown',
                                'quantity' => $movement->quantity ? (float) $movement->quantity : 0.0,
                                'reference' => $movement->reference_number ?? '',
                                'notes' => $movement->notes ?? '',
                                'performed_by' => $movement->performedBy->name ?? 'System',
                                'date' => $movement->movement_date ?? $movement->created_at,
                                'created_at' => $movement->created_at,
                            ];
                        }),
                    
                    // Timestamps
                    'created_at' => $stockItem->created_at,
                    'updated_at' => $stockItem->updated_at,
                ],
            ]);
            
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Stock item not found',
            ], 404);
        } catch (\Exception $e) {
            \Log::error('StockController@show error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch stock item',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
            ], 500);
        }
    }
    
    /**
     * Search stock items across all accessible stores.
     */
    public function search(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'q' => 'required|string|min:2|max:100',
                'limit' => 'sometimes|integer|min:1|max:50',
                'store_id' => 'sometimes|uuid',
                'category' => 'sometimes|string',
            ]);
            
            $user = $request->user();
            $query = $request->q;
            $limit = $request->get('limit', 20);
            
            $stockQuery = StoreStock::with(['item.supplier', 'store']);
            
            // An empty store scope must return no stock for non-admin users.
            if ($user->role !== 'admin') {
                $accessibleStoreIds = $user->storeAssignments()->pluck('store_id');
                $stockQuery->whereIn('store_id', $accessibleStoreIds);
            }
            
            $stockQuery->whereHas('item', function($q) use ($query) {
                $q->where('name', 'LIKE', "%{$query}%")
                  ->orWhere('code', 'LIKE', "%{$query}%")
                  ->orWhere('description', 'LIKE', "%{$query}%");
            });
            
            // Apply additional filters
            if ($request->filled('store_id')) {
                $stockQuery->where('store_id', $request->store_id);
            }
            
            if ($request->filled('category')) {
                $stockQuery->whereHas('item', function($q) use ($request) {
                    $q->where('category', $request->category);
                });
            }
            
            $stockItems = $stockQuery->limit($limit)->get();
            
            $data = $stockItems->map(function ($stock) {
                return [
                    'id' => $stock->id,
                    'code' => $stock->item->code ?? '',
                    'name' => $stock->item->name ?? '',
                    'category' => $stock->item->category ?? '',
                    'stock_category' => $stock->item->item_type?->value ?? $stock->item->item_type ?? 'food',
                    'unit' => $stock->item->unit ?? '',
                    'purchase_price' => $stock->current_cost ? (float) $stock->current_cost : 0.0,
                    'quantity' => $stock->quantity ? (float) $stock->quantity : 0.0,
                    'min_quantity' => $stock->min_quantity ? (float) $stock->min_quantity : 0.0,
                    'max_quantity' => $stock->max_quantity ? (float) $stock->max_quantity : 0.0,
                    'location' => $stock->location_description ?? $stock->store->name ?? '',
                    'supplier' => $stock->item->supplier?->company
                        ?: ($stock->item->supplier?->name ?? 'Unknown'),
                    'status' => $stock->status?->value ?? 'Unknown',
                    'description' => $stock->item->description ?? '',
                    'last_updated' => $stock->updated_at,
                    'item_id' => $stock->item_id,
                    'store' => [
                        'id' => $stock->store->id,
                        'name' => $stock->store->name ?? '',
                        'code' => $stock->store->code ?? '',
                    ],
                ];
            });
            
            return response()->json([
                'success' => true,
                'data' => ['items' => $data],
            ]);
            
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid search parameters',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            \Log::error('StockController@search error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Search failed',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
            ], 500);
        }
    }
}