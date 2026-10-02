<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Health check endpoint (no authentication required)
Route::get('health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Catering Inventory API is running',
        'timestamp' => now(),
        'version' => '1.0.0',
        'cors_enabled' => true,
    ]);
});

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Authentication routes with rate limiting
Route::prefix('auth')->middleware('throttle:auth')->group(function () {
    Route::post('login', [App\Http\Controllers\AuthController::class, 'login']);
    Route::post('logout', [App\Http\Controllers\AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::post('refresh', [App\Http\Controllers\AuthController::class, 'refresh'])->middleware('auth:sanctum');
    Route::get('profile', [App\Http\Controllers\AuthController::class, 'profile'])->middleware('auth:sanctum');
});

// Protected routes with permission checks
Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
    
    // Users - require user management permissions
    Route::middleware('permission:users.view')->group(function () {
        Route::get('users', [App\Http\Controllers\UserController::class, 'index']);
        Route::get('users/{user}', [App\Http\Controllers\UserController::class, 'show']);
        Route::get('users/roles', [App\Http\Controllers\UserController::class, 'roles']);
        Route::get('users/permissions', [App\Http\Controllers\UserController::class, 'permissions']);
    });
    
    Route::middleware('permission:users.create')->group(function () {
        Route::post('users', [App\Http\Controllers\UserController::class, 'store']);
    });
    
    Route::middleware('permission:users.update')->group(function () {
        Route::put('users/{user}', [App\Http\Controllers\UserController::class, 'update']);
        Route::post('users/{user}/stores', [App\Http\Controllers\UserStoreAssignmentController::class, 'assign']);
        Route::delete('users/{user}/stores/{store}', [App\Http\Controllers\UserStoreAssignmentController::class, 'remove']);
    });
    
    Route::middleware('permission:users.delete')->group(function () {
        Route::delete('users/{user}', [App\Http\Controllers\UserController::class, 'destroy']);
    });
    
    // Stores - require store management permissions
    Route::middleware('permission:stores.view')->group(function () {
        Route::get('stores', [App\Http\Controllers\StoreController::class, 'index']);
        Route::get('stores/{store}', [App\Http\Controllers\StoreController::class, 'show'])->middleware('store.access');
        Route::get('stores/types', [App\Http\Controllers\StoreController::class, 'types']);
    });
    
    Route::middleware('permission:stores.create')->group(function () {
        Route::post('stores', [App\Http\Controllers\StoreController::class, 'store']);
    });
    
    Route::middleware('permission:stores.update')->group(function () {
        Route::put('stores/{store}', [App\Http\Controllers\StoreController::class, 'update'])->middleware('store.access');
    });
    
    Route::middleware('permission:stores.delete')->group(function () {
        Route::delete('stores/{store}', [App\Http\Controllers\StoreController::class, 'destroy']);
    });
    
    // Items - require inventory permissions
    Route::middleware('permission:inventory.view')->group(function () {
        Route::get('items', [App\Http\Controllers\ItemController::class, 'index']);
        Route::get('items/{item}', [App\Http\Controllers\ItemController::class, 'show']);
        Route::get('items/search', [App\Http\Controllers\ItemController::class, 'search']);
        Route::get('items/categories', [App\Http\Controllers\ItemController::class, 'categories']);
    });
    
    Route::middleware('permission:inventory.create')->group(function () {
        Route::post('items', [App\Http\Controllers\ItemController::class, 'store']);
    });
    
    Route::middleware('permission:inventory.update')->group(function () {
        Route::put('items/{item}', [App\Http\Controllers\ItemController::class, 'update']);
    });
    
    Route::middleware('permission:inventory.delete')->group(function () {
        Route::delete('items/{item}', [App\Http\Controllers\ItemController::class, 'destroy']);
    });
    
    // Store Stock - require inventory permissions and store access
    Route::middleware(['permission:inventory.view', 'store.access'])->group(function () {
        Route::get('stores/{store}/stock', [App\Http\Controllers\StoreStockController::class, 'index']);
        Route::get('stores/{store}/stock/{item}', [App\Http\Controllers\StoreStockController::class, 'show']);
    });
    
    Route::middleware(['permission:inventory.update', 'store.access'])->group(function () {
        Route::post('stores/{store}/stock', [App\Http\Controllers\StoreStockController::class, 'store']);
        Route::put('stores/{store}/stock/{item}', [App\Http\Controllers\StoreStockController::class, 'update']);
    });
    
    Route::middleware(['permission:inventory.delete', 'store.access'])->group(function () {
        Route::delete('stores/{store}/stock/{item}', [App\Http\Controllers\StoreStockController::class, 'destroy']);
    });
    
    // Stock Movements - require inventory permissions
    Route::middleware('permission:inventory.view')->group(function () {
        Route::get('stock-movements', [App\Http\Controllers\StockMovementController::class, 'index']);
        Route::get('stock-movements/{movement}', [App\Http\Controllers\StockMovementController::class, 'show']);
    });
    
    Route::middleware('permission:inventory.update')->group(function () {
        Route::post('stock-movements', [App\Http\Controllers\StockMovementController::class, 'store']);
        Route::post('stock-movements/{movement}/correct', [App\Http\Controllers\StockMovementController::class, 'correct']);
    });
    
    // Transfers - require transfer permissions
    Route::middleware('permission:transfers.view')->group(function () {
        Route::get('transfers', [App\Http\Controllers\TransferController::class, 'index']);
        Route::get('transfers/{transfer}', [App\Http\Controllers\TransferController::class, 'show']);
    });
    
    Route::middleware('permission:transfers.create')->group(function () {
        Route::post('transfers', [App\Http\Controllers\TransferController::class, 'store']);
        Route::post('transfers/{transfer}/ship', [App\Http\Controllers\TransferController::class, 'ship']);
        Route::post('transfers/{transfer}/receive', [App\Http\Controllers\TransferController::class, 'receive']);
    });
    
    Route::middleware('permission:transfers.approve')->group(function () {
        Route::post('transfers/{transfer}/approve', [App\Http\Controllers\TransferController::class, 'approve']);
    });
    
    // Suppliers - require supplier permissions
    Route::middleware('permission:suppliers.view')->group(function () {
        Route::get('suppliers', [App\Http\Controllers\SupplierController::class, 'index']);
        Route::get('suppliers/{supplier}', [App\Http\Controllers\SupplierController::class, 'show']);
    });
    
    Route::middleware('permission:suppliers.create')->group(function () {
        Route::post('suppliers', [App\Http\Controllers\SupplierController::class, 'store']);
    });
    
    Route::middleware('permission:suppliers.update')->group(function () {
        Route::put('suppliers/{supplier}', [App\Http\Controllers\SupplierController::class, 'update']);
    });
    
    Route::middleware('permission:suppliers.delete')->group(function () {
        Route::delete('suppliers/{supplier}', [App\Http\Controllers\SupplierController::class, 'destroy']);
    });
    
    // Purchase Orders - require purchase permissions
    Route::middleware('permission:purchases.view')->group(function () {
        Route::get('purchase-orders', [App\Http\Controllers\PurchaseOrderController::class, 'index']);
        Route::get('purchase-orders/{purchaseOrder}', [App\Http\Controllers\PurchaseOrderController::class, 'show']);
    });
    
    Route::middleware('permission:purchases.create')->group(function () {
        Route::post('purchase-orders', [App\Http\Controllers\PurchaseOrderController::class, 'store']);
        Route::post('purchase-orders/{purchaseOrder}/receive', [App\Http\Controllers\PurchaseOrderController::class, 'receive']);
    });
    
    Route::middleware('permission:purchases.update')->group(function () {
        Route::put('purchase-orders/{purchaseOrder}', [App\Http\Controllers\PurchaseOrderController::class, 'update']);
        Route::post('purchase-orders/{purchaseOrder}/approve', [App\Http\Controllers\PurchaseOrderController::class, 'approve']);
    });
    
    Route::middleware('permission:purchases.delete')->group(function () {
        Route::delete('purchase-orders/{purchaseOrder}', [App\Http\Controllers\PurchaseOrderController::class, 'destroy']);
    });
    
    // Waste Records - require waste permissions
    Route::middleware('permission:waste.view')->group(function () {
        Route::get('waste-records', [App\Http\Controllers\WasteRecordController::class, 'index']);
        Route::get('waste-records/{wasteRecord}', [App\Http\Controllers\WasteRecordController::class, 'show']);
    });
    
    Route::middleware('permission:waste.create')->group(function () {
        Route::post('waste-records', [App\Http\Controllers\WasteRecordController::class, 'store']);
    });
    
    Route::middleware('permission:waste.update')->group(function () {
        Route::put('waste-records/{wasteRecord}', [App\Http\Controllers\WasteRecordController::class, 'update']);
        Route::post('waste-records/{wasteRecord}/approve', [App\Http\Controllers\WasteRecordController::class, 'approve']);
    });
    
    Route::middleware('permission:waste.delete')->group(function () {
        Route::delete('waste-records/{wasteRecord}', [App\Http\Controllers\WasteRecordController::class, 'destroy']);
    });
    
    // Notifications
    Route::get('notifications', [App\Http\Controllers\NotificationController::class, 'index']);
    Route::put('notifications/{notification}/read', [App\Http\Controllers\NotificationController::class, 'markAsRead']);
    
    // Sync (for offline support) - require authenticated user
    Route::prefix('sync')->group(function () {
        Route::post('upload', [App\Http\Controllers\SyncController::class, 'upload']);
        Route::get('download', [App\Http\Controllers\SyncController::class, 'download']);
        Route::post('register-device', [App\Http\Controllers\SyncController::class, 'registerDevice']);
    });
    
    // Reports - require report permissions
    Route::middleware('permission:reports.view')->group(function () {
        Route::prefix('reports')->group(function () {
            Route::get('dashboard/kpis', [App\Http\Controllers\ReportController::class, 'dashboardKpis']);
            Route::get('stock/current', [App\Http\Controllers\ReportController::class, 'currentStock']);
            Route::get('stock/low-stock', [App\Http\Controllers\ReportController::class, 'lowStock']);
        });
    });
});