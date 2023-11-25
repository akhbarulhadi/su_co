<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Klien extends Model
{
    use HasFactory;
    protected $table = 'data_klien';
    protected $primaryKey = 'id_klien';
    protected $fillable = [
        'nama_perusahaan',
        'nama_klien',
        'alamat',
        'email',
        'no_tlp',
        'fax',
        'no_bank',
    ];
}
