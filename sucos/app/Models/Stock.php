<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Stock extends Model
{
    use HasFactory;
    protected $table = 'ketersediaan_barang';
    protected $primaryKey = 'id_produk';
    protected $fillable = [
        'kode_produk',
        'nama_produk',
        'jumlah_produk',
        'jenis_produk',
        'harga_produk',
    ];
}
