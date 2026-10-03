<?php

namespace Tests\Feature;

use App\Enums\ItemType;
use App\Enums\StockStatus;
use App\Models\Item;
use App\Models\Store;
use App\Models\StoreStock;
use App\Models\User;
use Tests\TestCase;

class StockMovementTest extends TestCase
{
    public function test_adjustments_are_atomic_and_cannot_consume_reserved_stock(): void
    {
        $user = User::create([
            'name' => 'Inventory Admin',
            'email' => 'inventory-admin@example.test',
            'password' => 'test-password',
            'role' => User::ROLE_ADMIN,
        ]);
        $store = Store::create([
            'name' => 'Test Store',
            'code' => 'TEST-STORE',
            'store_type' => Store::TYPE_GENERAL,
        ]);
        $item = Item::create([
            'code' => 'TEST-ITEM',
            'name' => 'Test Item',
            'category' => 'Test',
            'item_type' => ItemType::FOOD,
            'unit' => 'kg',
            'created_by' => $user->id,
        ]);
        $stock = StoreStock::create([
            'item_id' => $item->id,
            'store_id' => $store->id,
            'quantity' => 10,
            'reserved_quantity' => 0,
            'status' => StockStatus::HEALTHY,
        ]);

        $movementResponse = $this->actingAs($user, 'sanctum')
            ->postJson('/api/stock-movements', [
                'item_id' => $item->id,
                'store_id' => $store->id,
                'type' => 'Adjustment',
                'quantity' => -2,
            ])
            ->assertCreated();
        $movementId = $movementResponse->json('data.id');

        $this->assertSame('8.000', $stock->fresh()->quantity);
        $this->assertDatabaseCount('stock_movements', 1);

        $this->postJson("/api/stock-movements/{$movementId}/correct", [
            'correction_quantity' => 1,
            'reason' => 'Correction test',
        ])->assertCreated();

        $this->assertSame('9.000', $stock->fresh()->quantity);
        $this->assertDatabaseCount('stock_movements', 2);

        $stock = $stock->fresh();
        $stock->update(['quantity' => 10, 'reserved_quantity' => 9]);
        $this->assertSame('10.000', $stock->fresh()->quantity);
        $this->assertSame('9.000', $stock->fresh()->reserved_quantity);

        $this->postJson("/api/stock-movements/{$movementId}/correct", [
            'correction_quantity' => -2,
            'reason' => 'Reserved quantity test',
        ])->assertUnprocessable();

        $this->assertSame('10.000', $stock->fresh()->quantity);
        $this->assertDatabaseCount('stock_movements', 2);

        $this->putJson("/api/stores/{$store->id}/stock/{$item->id}", [
            'quantity' => 8,
            'adjustment_reason' => 'Count correction',
        ])->assertUnprocessable();

        $this->assertSame('10.000', $stock->fresh()->quantity);
        $this->assertDatabaseCount('stock_movements', 2);

        $this->postJson('/api/stock-movements', [
            'item_id' => $item->id,
            'store_id' => $store->id,
            'type' => 'Adjustment',
            'quantity' => -2,
        ])->assertUnprocessable();

        $this->assertSame('10.000', $stock->fresh()->quantity);
        $this->assertDatabaseCount('stock_movements', 2);
    }
}