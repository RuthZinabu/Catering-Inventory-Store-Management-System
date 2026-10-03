<?php

namespace Tests\Feature;

use App\Models\Store;
use App\Models\User;
use Tests\TestCase;

class StockItemCreationTest extends TestCase
{
    public function test_upload_creates_item_stock_and_opening_movement_together(): void
    {
        $user = User::create([
            'name' => 'Stock Admin',
            'email' => 'stock-admin@example.test',
            'password' => 'test-password',
            'role' => User::ROLE_ADMIN,
        ]);
        $store = Store::create([
            'name' => 'Upload Store',
            'code' => 'UPLOAD-STORE',
            'store_type' => Store::TYPE_GENERAL,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/stores/{$store->id}/stock/items", [
                'item' => [
                    'code' => 'UPLOAD-ITEM',
                    'name' => 'Rice',
                    'category' => 'Dry Food',
                    'item_type' => 'food',
                    'unit' => 'kg',
                    'default_purchase_price' => 2.5,
                ],
                'quantity' => 8,
                'min_quantity' => 2,
                'max_quantity' => 20,
                'location_description' => 'Aisle 1',
            ])
            ->assertCreated()
            ->assertJsonPath('data.item.name', 'Rice')
            ->assertJsonPath('data.quantity', '8.000');

        $this->assertDatabaseCount('items', 1);
        $this->assertDatabaseCount('store_stock', 1);
        $this->assertDatabaseHas('stock_movements', [
            'type' => 'Stock In',
            'quantity' => 8,
            'quantity_before' => 0,
            'quantity_after' => 8,
            'note' => 'Opening stock',
        ]);
    }

    public function test_invalid_item_details_do_not_create_partial_records(): void
    {
        $user = User::create([
            'name' => 'Stock Admin',
            'email' => 'invalid-stock-admin@example.test',
            'password' => 'test-password',
            'role' => User::ROLE_ADMIN,
        ]);
        $store = Store::create([
            'name' => 'Upload Store',
            'code' => 'INVALID-UPLOAD-STORE',
            'store_type' => Store::TYPE_GENERAL,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/stores/{$store->id}/stock/items", [
                'item' => [
                    'code' => 'INVALID-UPLOAD-ITEM',
                    'name' => 'Rice',
                    'category' => 'Dry Food',
                    'item_type' => 'food',
                    'unit' => 'kg',
                    'brand' => 'Food items cannot have brands',
                ],
                'quantity' => 8,
            ])
            ->assertUnprocessable();

        $this->assertDatabaseCount('items', 0);
        $this->assertDatabaseCount('store_stock', 0);
        $this->assertDatabaseCount('stock_movements', 0);
    }

    public function test_upload_requires_both_item_creation_and_stock_update_permissions(): void
    {
        $user = User::create([
            'name' => 'Stock Updater',
            'email' => 'stock-updater@example.test',
            'password' => 'test-password',
            'role' => User::ROLE_STOREKEEPER,
            'permissions' => ['inventory.update'],
        ]);
        $store = Store::create([
            'name' => 'Permission Store',
            'code' => 'PERMISSION-STORE',
            'store_type' => Store::TYPE_GENERAL,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/stores/{$store->id}/stock/items", [])
            ->assertForbidden();
    }
}