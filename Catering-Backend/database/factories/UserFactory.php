<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'phone' => fake()->phoneNumber(),
            'role' => 'storekeeper',
            'department' => fake()->word(),
            'status' => 'Active',
            'permissions' => ['inventory.view', 'inventory.update'],
            'failed_login_attempts' => 0,
            'locked_until' => null,
            'password_changed_at' => now(),
            'must_change_password' => false,
            'last_login_at' => now(),
            'remember_token' => Str::random(10),
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }

    /**
     * Indicate that the user is an admin.
     */
    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'admin',
            'department' => 'Management',
            'permissions' => [
                'users.view', 'users.create', 'users.update', 'users.delete',
                'stores.view', 'stores.create', 'stores.update', 'stores.delete',
                'inventory.view', 'inventory.create', 'inventory.update', 'inventory.delete',
                'suppliers.view', 'suppliers.create', 'suppliers.update', 'suppliers.delete',
                'purchases.view', 'purchases.create', 'purchases.update', 'purchases.delete',
                'transfers.view', 'transfers.create', 'transfers.approve',
                'waste.view', 'waste.create', 'waste.update', 'waste.delete',
                'reports.view', 'reports.export',
                'dashboard.view',
            ],
        ]);
    }
}