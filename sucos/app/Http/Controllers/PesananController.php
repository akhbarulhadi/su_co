<?php

namespace App\Http\Controllers;

use App\Models\Pesanan;
use Illuminate\Http\Request;

class PesananController extends Controller
{
    public function showPesanan()
    {
        $pesanan = Pesanan::join('ketersediaan_barang', 'pesanan.id_produk', '=', 'ketersediaan_barang.id_produk')
            ->join('data_klien', 'data_klien.id_klien', '=', 'pesanan.id_klien')
            ->select('pesanan.*', 'ketersediaan_barang.nama_produk', 'ketersediaan_barang.jumlah_produk', 'data_klien.nama_klien', 'data_klien.alamat', 'data_klien.nama_perusahaan')
            ->whereNotIn('pesanan.status_pesanan', ['Selesai', 'Batal'])
            ->get();
        return response()->json(['message' => 'Success', 'pesanan' => $pesanan]);
    }

    public function updateStatus(Request $request)
    {
        // Validasi request sesuai kebutuhan Anda
        $request->validate([
            'id_pemesanan' => 'required|integer',
            'status_pesanan' => 'required|string',
        ]);

        // Perbarui status pesanan di database
        $pesanan = Pesanan::find($request->id_pemesanan);

        if (!$pesanan) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        $pesanan->status_pesanan = $request->status_pesanan;
        $pesanan->save();

        return response()->json(['message' => 'Status berhasil diperbarui']);
    }

    public function showHistory()
    {
        $pesanan = Pesanan::join('ketersediaan_barang', 'pesanan.id_produk', '=', 'ketersediaan_barang.id_produk')
            ->join('data_klien', 'data_klien.id_klien', '=', 'pesanan.id_klien')
            ->select('pesanan.*', 'ketersediaan_barang.nama_produk', 'data_klien.nama_klien', 'data_klien.alamat', 'data_klien.nama_perusahaan')
            ->whereNotIn('pesanan.status_pesanan', ['Menunggu', 'Siap Diantar'])
            ->get();
        return response()->json(['message' => 'Success', 'pesanan' => $pesanan]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'kode_pemesanan' => 'required',
            'id_produk' => 'required',
            'id_klien' => 'required',
            'harga_total' => 'required',
            'jenis_pembayaran' => 'required',
            'jumlah_pesanan' => 'required',
            'batas_tanggal' => 'required',
        ]);

        $pesanan = Pesanan::create($data);

        return response()->json(['message' => 'Data Pesanan berhasil dibuat', 'data' => $pesanan], 201);
    }
}
