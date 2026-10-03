<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kitchen_issues', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('number', 50)->unique();
            $table->foreignUuid('store_id')->constrained('stores');
            $table->string('department', 100);
            $table->string('kitchen', 100);
            $table->foreignUuid('requested_by')->constrained('users');
            $table->foreignUuid('approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignUuid('issued_by')->nullable()->constrained('users')->nullOnDelete();
            $table->date('requested_date');
            $table->string('status', 30)->default('Pending Approval');
            $table->text('notes')->nullable();
            $table->text('approval_notes')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->timestamp('issued_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->index(['store_id', 'status']);
            $table->index(['status', 'requested_date']);
        });

        Schema::create('kitchen_issue_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('kitchen_issue_id')->constrained('kitchen_issues')->cascadeOnDelete();
            $table->foreignUuid('item_id')->constrained('items');
            $table->decimal('quantity_requested', 15, 3);
            $table->decimal('quantity_issued', 15, 3)->nullable();
            $table->string('unit', 20);
            $table->timestamps();
            $table->unique(['kitchen_issue_id', 'item_id']);
            $table->index('item_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kitchen_issue_items');
        Schema::dropIfExists('kitchen_issues');
    }
};