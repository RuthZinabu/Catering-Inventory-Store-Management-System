<?php

namespace Tests\Feature;

use App\Enums\ItemType;
use App\Enums\StockStatus;
use App\Models\Item;
use App\Models\Store;
use App\Models\StoreStock;
use App\Models\User;
use App\Models\Transfer;
use Tests\TestCase;

class TransferTest extends TestCase
{
    public function test_transfer_request_approval_shipment_and_receipt_move_stock_once(): void
    {
        [$user, $fromStore, $toStore, $item] = $this->createContext('full');
        StoreStock::create([
            'item_id' => $item->id,
            'store_id' => $fromStore->id,
            'quantity' => 10,
            'reserved_quantity' => 2,
            'status' => StockStatus::HEALTHY,
        ]);

        $this->actingAs($user, 'sanctum');
        $created = $this->postJson('/api/transfers', [
            'from_store_id' => $fromStore->id,
            'to_store_id' => $toStore->id,
            'items' => [['item_id' => $item->id, 'quantity_requested' => 3]],
        ])->assertCreated()->assertJsonPath('data.status', 'pending');
        $transferId = $created->json('data.id');
        $this->assertSame('10.000', StoreStock::where('store_id', $fromStore->id)->firstOrFail()->quantity);

        $this->postJson("/api/transfers/{$transferId}/approve")
            ->assertOk()->assertJsonPath('data.status', 'approved');
        $this->postJson("/api/transfers/{$transferId}/ship")
            ->assertOk()->assertJsonPath('data.status', 'in_transit');
        $this->assertSame('7.000', StoreStock::where('store_id', $fromStore->id)->firstOrFail()->quantity);

        $this->postJson("/api/transfers/{$transferId}/receive", [])
            ->assertOk()->assertJsonPath('data.status', 'received');
        $this->assertSame('3.000', StoreStock::where('store_id', $toStore->id)->firstOrFail()->quantity);
        $this->assertDatabaseCount('stock_movements', 2);

        $this->postJson("/api/transfers/{$transferId}/receive", [])
            ->assertStatus(409);
        $this->assertDatabaseCount('stock_movements', 2);
    }

    public function test_insufficient_stock_rolls_back_shipment_and_leaves_transfer_approved(): void
    {
        [$user, $fromStore, $toStore, $item] = $this->createContext('insufficient');
        StoreStock::create([
            'item_id' => $item->id,
            'store_id' => $fromStore->id,
            'quantity' => 4,
            'reserved_quantity' => 2,
            'status' => StockStatus::HEALTHY,
        ]);

        $this->actingAs($user, 'sanctum');
        $transferId = $this->postJson('/api/transfers', [
            'from_store_id' => $fromStore->id,
            'to_store_id' => $toStore->id,
            'items' => [['item_id' => $item->id, 'quantity_requested' => 3]],
        ])->assertCreated()->json('data.id');
        $this->postJson("/api/transfers/{$transferId}/approve")->assertOk();
        $this->postJson("/api/transfers/{$transferId}/ship")->assertUnprocessable();

        $this->assertSame('4.000', StoreStock::where('store_id', $fromStore->id)->firstOrFail()->quantity);
        $this->assertSame('approved', Transfer::findOrFail($transferId)->status);
        $this->assertDatabaseCount('stock_movements', 0);
    }

    private function createContext(string $suffix): array
    {
        $user = User::create([
            'name' => 'Transfer Admin',
            'email' => "transfer-{$suffix}@example.test",
            'password' => 'test-password',
            'role' => User::ROLE_ADMIN,
        ]);
        $fromStore = Store::create([
            'name' => 'Source Store',
            'code' => "SOURCE-{$suffix}",
            'store_type' => Store::TYPE_GENERAL,
        ]);
        $toStore = Store::create([
            'name' => 'Destination Store',
            'code' => "DEST-{$suffix}",
            'store_type' => Store::TYPE_KITCHEN,
        ]);
        $item = Item::create([
            'code' => "TRANSFER-ITEM-{$suffix}",
            'name' => 'Transfer Item',
            'category' => 'Test',
            'item_type' => ItemType::FOOD,
            'unit' => 'kg',
            'created_by' => $user->id,
        ]);

        return [$user, $fromStore, $toStore, $item];
    }
}