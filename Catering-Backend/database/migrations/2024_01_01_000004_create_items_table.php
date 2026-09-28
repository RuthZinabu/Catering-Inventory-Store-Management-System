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
        Schema::create('items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 100)->unique();
            $table->string('name', 255);
            $table->text('description')->nullable();
            $table->string('category', 100);
            $table->enum('item_type', ['food', 'catering', 'electronics']);
            $table->string('unit', 20);
            
            // Default pricing
            $table->decimal('default_purchase_price', 15, 2)->nullable();
            
            // Food-specific canonical attributes
            $table->integer('shelf_life_days')->nullable();
            $table->boolean('requires_refrigeration')->default(false);
            
            // Catering-specific canonical attributes  
            $table->enum('catering_subtype', ['permanent', 'temporary'])->nullable();
            
            // Electronics-specific canonical attributes
            $table->string('brand', 100)->nullable();
            $table->string('model', 100)->nullable();
            $table->integer('warranty_period_months')->nullable();
            
            // Metadata
            $table->boolean('is_active')->default(true);
            $table->uuid('created_by');
            $table->timestamps();
            $table->softDeletes();
            
            // Foreign keys
            $table->foreign('created_by')->references('id')->on('users');
            
            // Indexes
            $table->index('code');
            $table->index(['item_type', 'category']);
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('items');
    }
};