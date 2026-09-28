<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('store_stock', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('item_id');
            $table->uuid('store_id');
            
            // Quantities
            $table->decimal('quantity', 15, 3)->default(0);
            $table->decimal('reserved_quantity', 15, 3)->default(0);
            
            // Store-specific thresholds
            $table->decimal('min_quantity', 15, 3)->default(0);
            $table->decimal('max_quantity', 15, 3)->default(0);
            $table->decimal('reorder_point', 15, 3)->nullable();
            
            // Location within store
            $table->string('location_code', 50)->nullable();
            $table->string('location_description', 255)->nullable();
            
            // Store-specific pricing
            $table->decimal('current_cost', 15, 2)->nullable();
            $table->decimal('last_cost', 15, 2)->nullable();
            
            // Status & Tracking
            $table->enum('status', ['Healthy', 'Low Stock', 'Out of Stock', 'Expired', 'Expiring Soon'])->default('Healthy');
            $table->timestamp('last_counted_at')->nullable();
            $table->uuid('last_counted_by')->nullable();
            
            $table->timestamps();
            
            // Foreign keys
            $table->foreign('item_id')->references('id')->on('items');
            $table->foreign('store_id')->references('id')->on('stores');
            $table->foreign('last_counted_by')->references('id')->on('users');
            
            // Unique constraint
            $table->unique(['item_id', 'store_id']);
            
            // Indexes
            $table->index('store_id');
            $table->index('item_id');
            $table->index(['store_id', 'item_id']);
            $table->index(['store_id', 'status']);
            $table->index('location_code');
            
            // Generated column for available quantity
            $table->decimal('available_quantity', 15, 3)->storedAs('quantity - reserved_quantity');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('store_stock');
    }
};