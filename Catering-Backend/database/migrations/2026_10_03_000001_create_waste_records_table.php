<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('waste_records', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('number', 50)->unique();

            // Keep item details as a snapshot so records remain readable even
            // when an item is renamed or is no longer in the catalog.
            $table->uuid('item_id')->nullable();
            $table->string('item', 255);
            $table->string('category', 100);
            $table->string('unit', 20);
            $table->decimal('quantity', 15, 3);
            $table->decimal('estimated_cost', 15, 2)->default(0);
            $table->string('reason', 255);
            $table->string('recorded_by', 255);
            $table->dateTime('date');
            $table->string('status', 30)->default('Confirmed');
            $table->text('notes')->nullable();

            $table->uuid('store_id')->nullable();
            $table->uuid('created_by');
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('item_id')->references('id')->on('items')->nullOnDelete();
            $table->foreign('store_id')->references('id')->on('stores')->nullOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();

            $table->index(['store_id', 'date']);
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('waste_records');
    }
};