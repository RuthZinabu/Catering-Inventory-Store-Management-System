<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transfers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('transfer_number', 50)->unique();
            $table->foreignUuid('from_store_id')->constrained('stores');
            $table->foreignUuid('to_store_id')->constrained('stores');
            $table->string('status', 20)->default('pending');
            $table->string('priority', 20)->default('normal');
            $table->foreignUuid('requested_by')->constrained('users');
            $table->foreignUuid('approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignUuid('shipped_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignUuid('received_by')->nullable()->constrained('users')->nullOnDelete();
            $table->date('requested_date');
            $table->date('required_date')->nullable();
            $table->date('approved_date')->nullable();
            $table->date('shipped_date')->nullable();
            $table->date('received_date')->nullable();
            $table->text('notes')->nullable();
            $table->text('shipping_notes')->nullable();
            $table->timestamps();
            $table->index(['from_store_id', 'status']);
            $table->index(['to_store_id', 'status']);
            $table->index(['status', 'requested_date']);
        });

        Schema::create('transfer_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('transfer_id')->constrained('transfers')->cascadeOnDelete();
            $table->foreignUuid('item_id')->constrained('items');
            $table->decimal('quantity_requested', 15, 3);
            $table->decimal('quantity_approved', 15, 3)->nullable();
            $table->decimal('quantity_shipped', 15, 3)->nullable();
            $table->decimal('quantity_received', 15, 3)->nullable();
            $table->decimal('unit_cost', 15, 2)->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->unique(['transfer_id', 'item_id']);
            $table->index('item_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transfer_items');
        Schema::dropIfExists('transfers');
    }
};