<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pesanan extends Model
{
    use HasFactory;
    protected $table = 'pesanan';
    protected $primaryKey = 'id_pemesanan';
    protected $fillable = [
        'kode_pemesanan',
        'id_produk',
        'id_klien',
        'harga_total',
        'jenis_pembayaran',
        'jumlah_pesanan',
        'batas_tanggal',
        'status_pesanan',
        'created_at',
        'updated_at',
    ];
}
