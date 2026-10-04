<?php

namespace Tests\Feature;

use App\Models\Store;
use App\Models\User;
use Tests\TestCase;

class StoreManagementTest extends TestCase
{
    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::factory()->admin()->create();
        $this->actingAs($this->admin, 'sanctum');
    }

    public function test_store_crud_accepts_the_fields_used_by_the_store_form(): void
    {
        $payload = [
            'name' => 'Central Kitchen',
            'code' => 'CK-001',
            'description' => 'Main catering kitchen',
            'location' => 'Building A',
            'phone' => '+251-911-000000',
            'email' => 'central@example.com',
            'manager' => 'Marta Bekele',
            'store_type' => 'kitchen',
            'is_active' => true,
        ];

        $this->postJson('/api/stores', $payload)
            ->assertCreated()
            ->assertJsonPath('data.name', 'Central Kitchen')
            ->assertJsonPath('data.manager', 'Marta Bekele')
            ->assertJsonPath('data.manager_user', null)
            ->assertJsonPath('data.store_type', 'kitchen')
            ->assertJsonPath('data.is_active', true);

        $store = Store::where('code', 'CK-001')->firstOrFail();
        $this->assertSame('Marta Bekele', $store->manager_name);

        $this->patchJson("/api/stores/{$store->id}", [
            'manager' => 'Marta B.',
            'is_active' => false,
            'location' => 'Building B',
        ])
            ->assertOk()
            ->assertJsonPath('data.manager', 'Marta B.')
            ->assertJsonPath('data.is_active', false)
            ->assertJsonPath('data.location', 'Building B');

        $this->assertDatabaseHas('stores', [
            'id' => $store->id,
            'manager_name' => 'Marta B.',
            'is_active' => false,
            'location' => 'Building B',
        ]);
    }

    public function test_store_list_supports_frontend_search_filters_and_pagination_shape(): void
    {
        Store::create([
            'name' => 'Dry Goods Store',
            'code' => 'DG-001',
            'store_type' => Store::TYPE_DRY_FOOD,
            'store_level' => 0,
            'is_active' => true,
        ]);
        Store::create([
            'name' => 'Cold Room',
            'code' => 'CR-001',
            'store_type' => Store::TYPE_COLD_ROOM,
            'store_level' => 0,
            'is_active' => false,
        ]);

        $this->getJson('/api/stores?search=dry&type=dry_food&active=1&per_page=1')
            ->assertOk()
            ->assertJsonPath('data.items.0.name', 'Dry Goods Store')
            ->assertJsonPath('data.stores.0.code', 'DG-001')
            ->assertJsonPath('data.pagination.total', 1)
            ->assertJsonPath('data.pagination.current_page', 1);

        $this->getJson('/api/stores/types')
            ->assertOk()
            ->assertJsonPath('data.0.value', Store::TYPE_MAIN_WAREHOUSE);
    }

    public function test_store_hierarchy_assigns_child_level_and_prevents_cycles(): void
    {
        $parent = Store::create([
            'name' => 'Main Warehouse',
            'code' => 'MW-001',
            'store_type' => Store::TYPE_MAIN_WAREHOUSE,
            'store_level' => 0,
        ]);

        $this->postJson('/api/stores', [
            'name' => 'Dry Food Store',
            'code' => 'DF-001',
            'store_type' => Store::TYPE_DRY_FOOD,
            'parent_store_id' => $parent->id,
        ])
            ->assertCreated()
            ->assertJsonPath('data.parent_store_id', $parent->id)
            ->assertJsonPath('data.store_level', 1);

        $child = Store::where('code', 'DF-001')->firstOrFail();

        $this->patchJson("/api/stores/{$parent->id}", [
            'parent_store_id' => $child->id,
        ])->assertUnprocessable();

        $this->deleteJson("/api/stores/{$parent->id}")
            ->assertStatus(409);
    }

    public function test_reparenting_a_store_updates_all_descendant_levels(): void
    {
        $root = Store::create([
            'name' => 'Root',
            'code' => 'ROOT-001',
            'store_type' => Store::TYPE_MAIN_WAREHOUSE,
            'store_level' => 0,
        ]);
        $otherRoot = Store::create([
            'name' => 'Other Root',
            'code' => 'ROOT-002',
            'store_type' => Store::TYPE_MAIN_WAREHOUSE,
            'store_level' => 0,
        ]);
        $intermediate = Store::create([
            'name' => 'Intermediate',
            'code' => 'MID-001',
            'store_type' => Store::TYPE_GENERAL,
            'store_level' => 1,
            'parent_store_id' => $otherRoot->id,
        ]);
        $child = Store::create([
            'name' => 'Child',
            'code' => 'CHILD-001',
            'store_type' => Store::TYPE_GENERAL,
            'store_level' => 1,
            'parent_store_id' => $root->id,
        ]);
        $grandchild = Store::create([
            'name' => 'Grandchild',
            'code' => 'GRAND-001',
            'store_type' => Store::TYPE_GENERAL,
            'store_level' => 2,
            'parent_store_id' => $child->id,
        ]);

        $this->patchJson("/api/stores/{$root->id}", [
            'parent_store_id' => $intermediate->id,
        ])->assertOk()->assertJsonPath('data.store_level', 2);

        $this->assertSame(3, $child->fresh()->store_level);
        $this->assertSame(4, $grandchild->fresh()->store_level);
    }
}