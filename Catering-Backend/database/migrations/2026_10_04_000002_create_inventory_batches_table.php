<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inventory_batches', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('store_id')->constrained('stores')->cascadeOnDelete();
            $table->foreignUuid('item_id')->constrained('items')->cascadeOnDelete();
            $table->foreignUuid('purchase_receipt_item_id')
                ->nullable()
                ->unique()
                ->constrained('purchase_receipt_items')
                ->nullOnDelete();
            $table->string('lot_number', 100)->nullable();
            $table->date('expires_on');
            $table->decimal('received_quantity', 15, 3);
            $table->decimal('quantity_remaining', 15, 3);
            $table->decimal('unit_cost', 15, 2)->nullable();
            $table->foreignUuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->index(['store_id', 'expires_on']);
            $table->index(['item_id', 'expires_on']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventory_batches');
    }
};