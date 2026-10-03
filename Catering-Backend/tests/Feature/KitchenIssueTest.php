<?php

namespace Tests\Feature;

use App\Enums\ItemType;
use App\Enums\StockStatus;
use App\Models\Item;
use App\Models\KitchenIssue;
use App\Models\Store;
use App\Models\StoreStock;
use App\Models\User;
use Tests\TestCase;

class KitchenIssueTest extends TestCase
{
    public function test_issue_request_is_approved_then_decrements_stock_once(): void
    {
        [$user, $store, $item] = $this->createContext('lifecycle');
        StoreStock::create([
            'item_id' => $item->id,
            'store_id' => $store->id,
            'quantity' => 10,
            'reserved_quantity' => 2,
            'status' => StockStatus::HEALTHY,
        ]);
        $this->actingAs($user, 'sanctum');

        $created = $this->postJson('/api/kitchen-issues', [
            'store_id' => $store->id,
            'department' => 'Banquet Hall',
            'kitchen' => 'Main Kitchen',
            'requested_date' => '2026-10-03',
            'items' => [['item_id' => $item->id, 'quantity_requested' => 3]],
        ])->assertCreated()->assertJsonPath('data.status', 'Pending Approval');
        $issueId = $created->json('data.id');
        $this->assertSame('10.000', StoreStock::where('store_id', $store->id)->firstOrFail()->quantity);

        $this->postJson("/api/kitchen-issues/{$issueId}/approve")
            ->assertOk()->assertJsonPath('data.status', 'Approved');
        $this->assertSame('10.000', StoreStock::where('store_id', $store->id)->firstOrFail()->quantity);

        $this->postJson("/api/kitchen-issues/{$issueId}/issue")
            ->assertOk()->assertJsonPath('data.status', 'Issued');
        $this->assertSame('7.000', StoreStock::where('store_id', $store->id)->firstOrFail()->quantity);
        $this->assertDatabaseCount('stock_movements', 1);
        $this->assertDatabaseHas('stock_movements', [
            'reference_type' => 'kitchen_issue',
            'reference_id' => $issueId,
            'type' => 'Stock Out',
            'quantity' => 3,
        ]);

        $this->postJson("/api/kitchen-issues/{$issueId}/issue")->assertStatus(409);
        $this->assertSame('7.000', StoreStock::where('store_id', $store->id)->firstOrFail()->quantity);
        $this->assertDatabaseCount('stock_movements', 1);
    }

    public function test_insufficient_available_stock_rolls_back_entire_issue(): void
    {
        [$user, $store, $item] = $this->createContext('insufficient');
        StoreStock::create([
            'item_id' => $item->id,
            'store_id' => $store->id,
            'quantity' => 4,
            'reserved_quantity' => 2,
            'status' => StockStatus::HEALTHY,
        ]);
        $this->actingAs($user, 'sanctum');
        $issueId = $this->postJson('/api/kitchen-issues', [
            'store_id' => $store->id,
            'department' => 'Banquet Hall',
            'kitchen' => 'Main Kitchen',
            'requested_date' => '2026-10-03',
            'items' => [['item_id' => $item->id, 'quantity_requested' => 3]],
        ])->assertCreated()->json('data.id');
        $this->postJson("/api/kitchen-issues/{$issueId}/approve")->assertOk();
        $this->postJson("/api/kitchen-issues/{$issueId}/issue")->assertUnprocessable();

        $this->assertSame('4.000', StoreStock::where('store_id', $store->id)->firstOrFail()->quantity);
        $this->assertSame('Approved', KitchenIssue::findOrFail($issueId)->status);
        $this->assertDatabaseCount('stock_movements', 0);
    }

    private function createContext(string $suffix): array
    {
        $user = User::create([
            'name' => 'Kitchen Admin',
            'email' => "kitchen-{$suffix}@example.test",
            'password' => 'test-password',
            'role' => User::ROLE_ADMIN,
        ]);
        $store = Store::create([
            'name' => 'Kitchen Source',
            'code' => "KITCHEN-SOURCE-{$suffix}",
            'store_type' => Store::TYPE_GENERAL,
        ]);
        $item = Item::create([
            'code' => "KITCHEN-ITEM-{$suffix}",
            'name' => 'Chicken',
            'category' => 'Meat',
            'item_type' => ItemType::FOOD,
            'unit' => 'kg',
            'created_by' => $user->id,
        ]);

        return [$user, $store, $item];
    }
}