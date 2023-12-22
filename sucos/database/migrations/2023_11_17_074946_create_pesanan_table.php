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
        Schema::create('pesanan', function (Blueprint $table) {
            $table->id('id_pemesanan');
            $table->string('kode_pemesanan')->unique();
            $table->unsignedBigInteger('id_produk');
            $table->foreign('id_produk')->references('id_produk')->on('ketersediaan_barang');
            $table->unsignedBigInteger('id_klien');
            $table->foreign('id_klien')->references('id_klien')->on('data_klien');
            $table->decimal('harga_total', 10, 0);
            $table->string('jenis_pembayaran');
            $table->string('jumlah_pesanan');
            $table->date('batas_tanggal');
            $table->enum('status_pesanan', ['Menunggu', 'Siap Diantar', 'Selesai', 'Batal']);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pesanan');
    }
};
