<?php

namespace App\Http\Controllers;

use App\Models\Klien;
use Illuminate\Http\Request;

class KlienController extends Controller
{
    public function showKlien()
    {
        $klien = Klien::select('data_klien.*')
            ->orderBy('created_at', 'desc')
            ->get();
        return response()->json(['message' => 'Success', 'klien' => $klien]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama_perusahaan' => 'required',
            'nama_klien' => 'required',
            'alamat' => 'required',
            'email' => 'required|email',
            'no_tlp' => 'required',
            'fax' => 'required',
            'no_bank' => 'required',
        ]);

        $klien = Klien::create($data);

        return response()->json(['message' => 'Data Klien berhasil dibuat', 'data' => $klien], 201);
    }
}
