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
        Schema::create('data_klien', function (Blueprint $table) {
            $table->id('id_klien');
            $table->string('nama_perusahaan');
            $table->string('nama_klien');
            $table->string('alamat');
            $table->string('email')->unique();
            $table->string('no_tlp')->unique();
            $table->string('fax')->unique();
            $table->string('no_bank')->unique();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('data_klien');
    }
};
