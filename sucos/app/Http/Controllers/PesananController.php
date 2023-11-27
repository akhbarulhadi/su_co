<?php

namespace App\Http\Controllers;

use App\Models\Pesanan;
use App\Models\Stock;
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

    public function updateStatusSiapDiantar(Request $request)
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

        // Kurangi jumlah_produk di tabel ketersediaan barang
        $this->updateProductAvailability($pesanan->id_produk, $pesanan->jumlah_pesanan);

        return response()->json(['message' => 'Status berhasil diperbarui']);
    }

    protected function updateProductAvailability($id_produk, $jumlah_pesanan)
    {
        $product = Stock::find($id_produk);

        if (!$product) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        // Kurangi jumlah_produk berdasarkan jumlah_pesanan
        if ($product->jumlah_produk >= $jumlah_pesanan) {
            // Kurangi jumlah_produk
            $product->jumlah_produk -= $jumlah_pesanan;
            $product->save();

            return response()->json(['message' => 'Jumlah produk berhasil diperbarui']);
        } else {
            return response()->json(['message' => 'Gagal mengurangkan jumlah_produk, stok tidak mencukupi'], 400);
        }
    }
}
