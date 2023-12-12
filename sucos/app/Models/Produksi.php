<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Produksi extends Model
{
    use HasFactory;

    protected $table = 'laporan_produksi';  // Sesuaikan dengan nama tabel yang benar
    protected $primaryKey = 'id_produksi';
    protected $fillable = [
        'kode_produksi',
        'id_produk',
        'jumlah_produksi',
        'id_user',
        'status_produksi',
        'tanggal_produksi',
    ];

    // Definisikan relasi dengan model User
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }

    // Jika diperlukan, tambahkan relasi dengan model Produk atau yang lainnya
}
