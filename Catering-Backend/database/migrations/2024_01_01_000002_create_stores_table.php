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
        Schema::create('stores', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name', 255);
            $table->string('code', 50)->unique();
            $table->text('description')->nullable();
            $table->string('location', 255)->nullable();
            $table->string('phone', 50)->nullable();
            $table->string('email', 255)->nullable();
            
            // Store Hierarchy
            $table->uuid('parent_store_id')->nullable();
            $table->integer('store_level')->default(0);
            
            // Management
            $table->uuid('manager_id')->nullable();
            $table->string('store_type', 50);
            
            // Operations
            $table->string('timezone', 50)->default('UTC');
            $table->json('operating_hours')->nullable();
            $table->json('settings')->default('{}');
            
            // Status
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();
            
            // Foreign keys
            $table->foreign('parent_store_id')->references('id')->on('stores');
            $table->foreign('manager_id')->references('id')->on('users');
            
            // Indexes
            $table->index('code');
            $table->index('store_type');
            $table->index('parent_store_id');
            $table->index('store_level');
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stores');
    }
};