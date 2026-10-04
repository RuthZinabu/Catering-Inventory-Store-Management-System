<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('production_runs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('store_id')->constrained('stores')->cascadeOnDelete();
            $table->foreignUuid('recipe_id')->constrained('recipes')->restrictOnDelete();
            $table->date('production_date');
            $table->decimal('produced_servings', 15, 3);
            $table->text('notes')->nullable();
            $table->foreignUuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->index(['store_id', 'production_date']);
        });

        Schema::create('production_run_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('production_run_id')->constrained('production_runs')->cascadeOnDelete();
            $table->foreignUuid('item_id')->nullable()->constrained('items')->nullOnDelete();
            $table->string('ingredient_name', 255);
            $table->string('unit', 20);
            $table->decimal('theoretical_quantity', 15, 3);
            $table->decimal('unit_cost', 15, 2)->nullable();
            $table->timestamps();
            $table->index(['item_id', 'unit']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('production_run_items');
        Schema::dropIfExists('production_runs');
    }
};