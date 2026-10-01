<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stock_movements', function (Blueprint $table) {
            $table->uuid('id')->primary();

            $table->uuid('item_id');
            $table->uuid('store_id');

            $table->enum('type', [
                'Stock In',
                'Stock Out',
                'Transfer',
                'Adjustment',
                'Return',
                'Correction',
            ]);

            $table->decimal('quantity', 15, 3);
            $table->string('unit', 20);
            $table->decimal('quantity_before', 15, 3);
            $table->decimal('quantity_after', 15, 3);

            $table->string('reference_type', 50)->nullable();
            $table->uuid('reference_id')->nullable();

            $table->text('note')->nullable();

            $table->uuid('from_store_id')->nullable();
            $table->uuid('to_store_id')->nullable();

            $table->boolean('is_correction')->default(false);

            $table->uuid('corrects_movement_id')->nullable();
            $table->text('correction_reason')->nullable();

            $table->boolean('requires_approval')->default(false);

            $table->uuid('approved_by')->nullable();
            $table->timestamp('approved_at')->nullable();

            $table->text('rejection_reason')->nullable();

            $table->uuid('deleted_by')->nullable();
            $table->text('deletion_reason')->nullable();

            $table->uuid('offline_sync_id')->nullable()->unique();
            $table->timestamp('offline_created_at')->nullable();

            $table->string('sync_status', 20)->default('synced');

            $table->uuid('performed_by');

            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_movements');
    }
};