<?php

namespace Tests\Feature;

use App\Enums\ItemType;
use App\Models\Item;
use App\Models\User;
use Tests\TestCase;

class ItemSearchTest extends TestCase
{
    public function test_item_search_preserves_leading_zeroes_and_returns_inventory_fields(): void
    {
        $user = User::create([
            'name' => 'Inventory Admin',
            'email' => 'barcode-search@example.test',
            'password' => 'test-password',
            'role' => User::ROLE_ADMIN,
        ]);
        Item::create([
            'code' => '0001234567890',
            'name' => 'Tracked Item',
            'category' => 'Dry Food',
            'item_type' => ItemType::FOOD,
            'unit' => 'each',
            'default_purchase_price' => 2.5,
            'created_by' => $user->id,
        ]);

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/items/search?q=0001234567890')
            ->assertOk()
            ->assertJsonPath('data.0.code', '0001234567890')
            ->assertJsonPath('data.0.category', 'Dry Food')
            ->assertJsonPath('data.0.default_purchase_price', 2.5)
            ->assertJsonPath('data.0.description', '');
    }
}