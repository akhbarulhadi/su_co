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

    public function showKepalaGudang()
    {
        $stock = Stock::select('ketersediaan_barang.*')
            ->take(5)
            ->get();
        return response()->json(['message' => 'Success', 'stock' => $stock]);
    }

    public function showDashbordMarketing()
    {
        $stock = Stock::select('ketersediaan_barang.*')
            ->take(5)
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
        $kodeProduk = 'DUCT-' . date('YmdHis') . rand(1000, 9999);

        $data = $request->validate([
            'nama_produk' => 'required',
            'jumlah_produk' => 'required',
            'jenis_produk' => 'required',
        ]);

        $data['kode_produk'] = $kodeProduk;

        $stock = Stock::create($data);

        return response()->json(['message' => 'Data Produk berhasil dibuat', 'data' => $stock], 201);
    }
}
