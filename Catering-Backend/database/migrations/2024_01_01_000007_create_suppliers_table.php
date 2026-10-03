<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('suppliers', function (Blueprint $table) {
            $table->uuid('id');

            $table->string('name', 255);
            $table->string('company', 255);
            $table->string('contact_person', 255)->nullable();
            $table->string('phone', 50)->nullable();
            $table->string('email', 255)->nullable();
            $table->text('address')->nullable();
            $table->string('tax_number', 50)->nullable();

            $table->string('status', 20)->default('Active');
            $table->string('payment_terms', 100)->nullable();
            $table->decimal('credit_limit', 15, 2)->nullable();

            $table->decimal('outstanding_balance', 15, 2)->default(0.00);

            $table->timestamps();
            $table->softDeletes();
        });

        Schema::table('suppliers', function (Blueprint $table) {
            $table->primary('id', 'suppliers_pkey');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('suppliers');
    }
};