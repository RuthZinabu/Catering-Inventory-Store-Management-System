<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('suppliers', function (Blueprint $table) {
            $table->string('category', 100)->nullable()->after('tax_number');
            $table->string('registration_number', 100)->nullable()->after('category');
            $table->text('notes')->nullable()->after('registration_number');
            $table->string('logo_path')->nullable()->after('notes');
        });
    }

    public function down(): void
    {
        Schema::table('suppliers', function (Blueprint $table) {
            $table->dropColumn(['category', 'registration_number', 'notes', 'logo_path']);
        });
    }
};
