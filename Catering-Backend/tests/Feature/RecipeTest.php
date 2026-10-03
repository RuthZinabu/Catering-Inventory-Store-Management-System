<?php

namespace Tests\Feature;

use App\Models\User;
use Tests\TestCase;

class RecipeTest extends TestCase
{
    public function test_user_can_create_list_and_update_a_recipe_with_calculated_costs(): void
    {
        $user = User::create([
            'name' => 'Recipe Admin',
            'email' => 'recipe-admin@example.test',
            'password' => 'test-password',
            'role' => User::ROLE_ADMIN,
        ]);
        $this->actingAs($user, 'sanctum');

        $created = $this->postJson('/api/recipes', [
            'name' => 'Vegetable Soup',
            'category' => 'Soup',
            'description' => 'Seasonal vegetables',
            'servings' => 4,
            'prep_time' => '25 min',
            'selling_price' => 20,
            'status' => 'Active',
            'ingredients' => [
                ['name' => 'Carrot', 'quantity' => 2, 'unit' => 'pcs', 'unit_cost' => 1.25],
                ['name' => 'Onion', 'quantity' => 1, 'unit' => 'pcs', 'unit_cost' => 0.75],
            ],
        ])->assertCreated()
            ->assertJsonPath('data.total_food_cost', 3.25)
            ->assertJsonPath('data.food_cost_percentage', 16.25)
            ->assertJsonPath('data.ingredients.0.name', 'Carrot');
        $recipeId = $created->json('data.id');

        $this->getJson('/api/recipes')
            ->assertOk()
            ->assertJsonPath('data.items.0.id', $recipeId);

        $this->putJson("/api/recipes/{$recipeId}", [
            'selling_price' => 10,
            'ingredients' => [
                ['name' => 'Carrot', 'quantity' => 4, 'unit' => 'pcs', 'unit_cost' => 1.25],
            ],
        ])->assertOk()
            ->assertJsonPath('data.total_food_cost', 5)
            ->assertJsonPath('data.food_cost_percentage', 50);

        $this->assertDatabaseCount('recipes', 1);
        $this->assertDatabaseCount('recipe_ingredients', 1);
    }

    public function test_recipe_writes_require_their_permissions(): void
    {
        $user = User::create([
            'name' => 'Recipe Reader',
            'email' => 'recipe-reader@example.test',
            'password' => 'test-password',
            'role' => User::ROLE_STOREKEEPER,
            'permissions' => ['recipes.view'],
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/recipes', [])
            ->assertForbidden();
    }
}