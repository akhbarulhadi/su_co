<?php

namespace App\Http\Controllers;

use App\Models\Stock;
use Illuminate\Http\Request;

class StockController extends Controller
{
    public function show()
    {
        $stock = Stock::select('ketersediaan_barang.*')
            ->get();
        return response()->json(['message' => 'Success', 'stock' => $stock]);
    }

    public function updateHarga(Request $request)
    {
        // Validasi request sesuai kebutuhan Anda
        $request->validate([
            'id_produk' => 'required|integer',
            'harga_produk' => 'required|string',
        ]);

        // Perbarui status pesanan di database
        $stock = Stock::find($request->id_produk);

        if (!$stock) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        $stock->harga_produk = $request->harga_produk;
        $stock->save();

        return response()->json(['message' => 'Status berhasil diperbarui']);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'kode_produk' => 'required',
            'nama_produk' => 'required',
            'jumlah_produk' => 'required',
            'jenis_produk' => 'required',
        ]);

        $stock = Stock::create($data);

        return response()->json(['message' => 'Data Produk berhasil dibuat', 'data' => $stock], 201);
    }
}
