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
        Schema::create('suppliers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name', 255);
            $table->string('company', 255);
            $table->string('contact_person', 255)->nullable();
            $table->string('phone', 50)->nullable();
            $table->string('email', 255)->nullable();
            $table->text('address')->nullable();
            $table->string('tax_number', 50)->nullable();
            
            // Business details
            $table->string('status', 20)->default('Active');
            $table->string('payment_terms', 100)->nullable();
            $table->decimal('credit_limit', 15, 2)->nullable();
            
            // Calculated balances (maintained via triggers)
            $table->decimal('outstanding_balance', 15, 2)->default(0.00);
            
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes
            $table->index('company');
            $table->index('status');
            $table->index('tax_number');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('suppliers');
    }
};