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
        Schema::create('stock_movements', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('item_id');
            $table->uuid('store_id');
            
            $table->enum('type', ['Stock In', 'Stock Out', 'Transfer', 'Adjustment', 'Return', 'Correction']);
            $table->decimal('quantity', 15, 3);
            $table->string('unit', 20);
            
            // Before/after quantities for auditing
            $table->decimal('quantity_before', 15, 3);
            $table->decimal('quantity_after', 15, 3);
            
            // Movement details
            $table->string('reference_type', 50)->nullable(); // 'purchase_order', 'transfer', 'waste_record', 'manual'
            $table->uuid('reference_id')->nullable(); // ID of related record
            $table->text('note')->nullable();
            
            // Transfer-specific fields
            $table->uuid('from_store_id')->nullable();
            $table->uuid('to_store_id')->nullable();
            
            // Correction capabilities
            $table->boolean('is_correction')->default(false);
            $table->uuid('corrects_movement_id')->nullable();
            $table->text('correction_reason')->nullable();
            
            // Approval workflow
            $table->boolean('requires_approval')->default(false);
            $table->uuid('approved_by')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->text('rejection_reason')->nullable();
            
            // Soft delete
            $table->uuid('deleted_by')->nullable();
            $table->text('deletion_reason')->nullable();
            $table->softDeletes();
            
            // Offline sync support
            $table->uuid('offline_sync_id')->nullable()->unique();
            $table->timestamp('offline_created_at')->nullable();
            $table->string('sync_status', 20)->default('synced'); // 'synced', 'pending', 'conflict'
            
            // Audit
            $table->uuid('performed_by');
            $table->timestamps();
            
            // Foreign keys
            $table->foreign('item_id')->references('id')->on('items');
            $table->foreign('store_id')->references('id')->on('stores');
            $table->foreign('from_store_id')->references('id')->on('stores');
            $table->foreign('to_store_id')->references('id')->on('stores');
            $table->foreign('performed_by')->references('id')->on('users');
            $table->foreign('approved_by')->references('id')->on('users');
            $table->foreign('deleted_by')->references('id')->on('users');
            $table->foreign('corrects_movement_id')->references('id')->on('stock_movements');
            
            // Indexes
            $table->index(['item_id', 'store_id']);
            $table->index(['store_id', 'created_at']);
            $table->index('type');
            $table->index('performed_by');
            $table->index(['reference_type', 'reference_id']);
            $table->index('corrects_movement_id');
            $table->index('sync_status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stock_movements');
    }
};