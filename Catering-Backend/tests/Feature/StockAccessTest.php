<?php

namespace Tests\Feature;

use App\Enums\ItemType;
use App\Enums\StockStatus;
use App\Models\Item;
use App\Models\Store;
use App\Models\StoreStock;
use App\Models\User;
use Tests\TestCase;

class StockAccessTest extends TestCase
{
    public function test_users_without_store_assignments_cannot_see_global_stock(): void
    {
        $user = User::create([
            'name' => 'Unassigned User',
            'email' => 'unassigned@example.test',
            'password' => 'test-password',
            'role' => User::ROLE_STOREKEEPER,
            'permissions' => ['inventory.view'],
        ]);
        $store = Store::create([
            'name' => 'Restricted Store',
            'code' => 'RESTRICTED-STORE',
            'store_type' => Store::TYPE_GENERAL,
        ]);
        $item = Item::create([
            'code' => 'RESTRICTED-ITEM',
            'name' => 'Restricted Item',
            'category' => 'Test',
            'item_type' => ItemType::FOOD,
            'unit' => 'kg',
            'created_by' => $user->id,
        ]);
        StoreStock::create([
            'item_id' => $item->id,
            'store_id' => $store->id,
            'quantity' => 5,
            'reserved_quantity' => 0,
            'status' => StockStatus::HEALTHY,
        ]);

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/stock')
            ->assertOk()
            ->assertJsonCount(0, 'data.items');

        $this->getJson('/api/stock/search?q=Restricted')
            ->assertOk()
            ->assertJsonCount(0, 'data.items');
    }
}