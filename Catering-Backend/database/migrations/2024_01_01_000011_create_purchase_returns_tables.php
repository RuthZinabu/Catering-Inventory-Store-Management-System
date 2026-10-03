<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('purchase_returns', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('number', 50)->unique();
            $table->uuid('purchase_order_id');
            $table->uuid('created_by');
            $table->uuid('reviewed_by')->nullable();
            $table->date('return_date');
            $table->string('status', 30)->default('Pending Review');
            $table->text('reason');
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();
            $table->foreign('purchase_order_id')->references('id')->on('purchase_orders');
            $table->foreign('created_by')->references('id')->on('users');
            $table->foreign('reviewed_by')->references('id')->on('users');
        });

        Schema::create('purchase_return_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('purchase_return_id');
            $table->uuid('purchase_order_item_id');
            $table->decimal('quantity', 15, 3);
            $table->decimal('unit_price', 15, 2);
            $table->timestamps();
            $table->foreign('purchase_return_id')->references('id')->on('purchase_returns')->cascadeOnDelete();
            $table->foreign('purchase_order_item_id')->references('id')->on('purchase_order_items');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('purchase_return_items');
        Schema::dropIfExists('purchase_returns');
    }
};
