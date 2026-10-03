<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recipes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name', 255);
            $table->string('category', 100);
            $table->text('description')->nullable();
            $table->unsignedInteger('servings')->default(1);
            $table->string('prep_time', 50)->nullable();
            $table->decimal('selling_price', 15, 2)->default(0);
            $table->string('status', 20)->default('Active');
            $table->decimal('total_food_cost', 15, 2)->default(0);
            $table->decimal('food_cost_percentage', 5, 2)->default(0);
            $table->foreignUuid('created_by')->constrained('users');
            $table->timestamps();
            $table->softDeletes();
            $table->index('category');
            $table->index('status');
        });

        Schema::create('recipe_ingredients', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('recipe_id')->constrained('recipes')->cascadeOnDelete();
            $table->foreignUuid('item_id')->nullable()->constrained('items')->nullOnDelete();
            $table->string('ingredient_name', 255);
            $table->decimal('quantity', 15, 3);
            $table->string('unit', 20);
            $table->decimal('unit_cost', 15, 2);
            $table->decimal('total_cost', 15, 2);
            $table->timestamps();
            $table->index('recipe_id');
            $table->index('item_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recipe_ingredients');
        Schema::dropIfExists('recipes');
    }
};