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
        Schema::create('ketersediaan_barang', function (Blueprint $table) {
            $table->id('id_produk');
            $table->string('kode_produk')->unique();
            $table->string('nama_produk');
            $table->integer('jumlah_produk');
            $table->string('jenis_produk');
            $table->string('harga_produk');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ketersediaan_barang');
    }
};
