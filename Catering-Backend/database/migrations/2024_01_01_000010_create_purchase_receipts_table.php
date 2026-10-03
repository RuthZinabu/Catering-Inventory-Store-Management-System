<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('purchase_receipts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('purchase_order_id');
            $table->uuid('received_by');
            $table->string('grn_number', 50)->unique();
            $table->date('delivery_date');
            $table->string('driver_name', 255)->nullable();
            $table->string('vehicle_number', 50)->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->foreign('purchase_order_id')->references('id')->on('purchase_orders');
            $table->foreign('received_by')->references('id')->on('users');
        });

        Schema::create('purchase_receipt_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('purchase_receipt_id');
            $table->uuid('purchase_order_item_id');
            $table->decimal('received_quantity', 15, 3);
            $table->decimal('accepted_quantity', 15, 3);
            $table->decimal('rejected_quantity', 15, 3)->default(0);
            $table->string('quality_status', 30)->default('Accepted');
            $table->text('rejection_reason')->nullable();
            $table->timestamps();
            $table->foreign('purchase_receipt_id')->references('id')->on('purchase_receipts')->cascadeOnDelete();
            $table->foreign('purchase_order_item_id')->references('id')->on('purchase_order_items');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('purchase_receipt_items');
        Schema::dropIfExists('purchase_receipts');
    }
};
