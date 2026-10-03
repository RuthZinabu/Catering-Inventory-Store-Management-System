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

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Authentication routes
Route::prefix('auth')->group(function () {
    Route::post('login', [App\Http\Controllers\AuthController::class, 'login']);
    Route::post('logout', [App\Http\Controllers\AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::post('refresh', [App\Http\Controllers\AuthController::class, 'refresh'])->middleware('auth:sanctum');
    Route::get('profile', [App\Http\Controllers\AuthController::class, 'profile'])->middleware('auth:sanctum');
    
    // 2FA routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('2fa/setup', [App\Http\Controllers\TwoFactorController::class, 'setup']);
        Route::post('2fa/verify', [App\Http\Controllers\TwoFactorController::class, 'verify']);
        Route::post('2fa/disable', [App\Http\Controllers\TwoFactorController::class, 'disable']);
    });
});

// Protected routes
Route::middleware(['auth:sanctum'])->group(function () {
    
    // Users
    Route::apiResource('users', App\Http\Controllers\UserController::class);
    Route::post('users/{user}/stores', [App\Http\Controllers\UserStoreAssignmentController::class, 'assign']);
    Route::delete('users/{user}/stores/{store}', [App\Http\Controllers\UserStoreAssignmentController::class, 'remove']);
    
    // Stores
    Route::apiResource('stores', App\Http\Controllers\StoreController::class);
    
    // Canonical Items
    Route::apiResource('items', App\Http\Controllers\ItemController::class);
    Route::get('items/search', [App\Http\Controllers\ItemController::class, 'search']);
    
    // Store Stock
    Route::get('stores/{store}/stock', [App\Http\Controllers\StoreStockController::class, 'index']);
    Route::post('stores/{store}/stock', [App\Http\Controllers\StoreStockController::class, 'store']);
    Route::get('stores/{store}/stock/{item}', [App\Http\Controllers\StoreStockController::class, 'show']);
    Route::put('stores/{store}/stock/{item}', [App\Http\Controllers\StoreStockController::class, 'update']);
    Route::delete('stores/{store}/stock/{item}', [App\Http\Controllers\StoreStockController::class, 'destroy']);
    
    // Stock Movements
    Route::apiResource('stock-movements', App\Http\Controllers\StockMovementController::class);
    Route::post('stock-movements/{movement}/correct', [App\Http\Controllers\StockMovementController::class, 'correct']);
    
    // Transfers
    Route::apiResource('transfers', App\Http\Controllers\TransferController::class);
    Route::post('transfers/{transfer}/approve', [App\Http\Controllers\TransferController::class, 'approve']);
    Route::post('transfers/{transfer}/ship', [App\Http\Controllers\TransferController::class, 'ship']);
    Route::post('transfers/{transfer}/receive', [App\Http\Controllers\TransferController::class, 'receive']);
    
    // Suppliers
    Route::apiResource('suppliers', App\Http\Controllers\SupplierController::class);
    Route::post('suppliers/{supplier}/logo', [App\Http\Controllers\SupplierController::class, 'uploadLogo']);
    
    // Purchase Orders
    Route::apiResource('purchase-orders', App\Http\Controllers\PurchaseOrderController::class);
    Route::post('purchase-orders/{purchaseOrder}/approve', [App\Http\Controllers\PurchaseOrderController::class, 'approve']);
    Route::post('purchase-orders/{purchaseOrder}/receive', [App\Http\Controllers\PurchaseOrderController::class, 'receive']);
    Route::post('purchase-orders/{purchaseOrder}/returns', [App\Http\Controllers\PurchaseOrderController::class, 'storeReturn']);
    Route::post('purchase-orders/{purchaseOrder}/returns/{purchaseReturn}/approve', [App\Http\Controllers\PurchaseOrderController::class, 'approveReturn']);
    
    // Waste Records
    Route::apiResource('waste-records', App\Http\Controllers\WasteRecordController::class);
    Route::post('waste-records/{wasteRecord}/approve', [App\Http\Controllers\WasteRecordController::class, 'approve']);
    
    // Notifications
    Route::get('notifications', [App\Http\Controllers\NotificationController::class, 'index']);
    Route::put('notifications/{notification}/read', [App\Http\Controllers\NotificationController::class, 'markAsRead']);
    
    // Sync (for offline support)
    Route::prefix('sync')->group(function () {
        Route::post('upload', [App\Http\Controllers\SyncController::class, 'upload']);
        Route::get('download', [App\Http\Controllers\SyncController::class, 'download']);
        Route::post('register-device', [App\Http\Controllers\SyncController::class, 'registerDevice']);
    });
    
    // Reports
    Route::prefix('reports')->group(function () {
        Route::get('dashboard/kpis', [App\Http\Controllers\ReportController::class, 'dashboardKpis']);
        Route::get('stock/current', [App\Http\Controllers\ReportController::class, 'currentStock']);
        Route::get('stock/low-stock', [App\Http\Controllers\ReportController::class, 'lowStock']);
    });
});