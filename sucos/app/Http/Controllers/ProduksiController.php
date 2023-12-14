<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Produksi;
use App\Models\Stock;
use App\Models\User;

class ProduksiController extends Controller
{
    public function user()
    {
        try {
            // Ambil data leader dari tabel users dengan role 'leader'
            $leaders = User::select('users.id_user', 'users.nama')
                ->where('roles', 'leader')
                ->get();

            // Jika data ditemukan, kirimkan respons JSON
            return response()->json(['message' => 'Success', 'leaders' => $leaders], 200);
        } catch (\Exception $e) {
            // Jika terjadi kesalahan, kirimkan respons JSON dengan pesan kesalahan
            return response()->json(['message' => 'Error', 'error' => $e->getMessage()], 500);
        }
    }

    // Endpoint untuk mendapatkan data produksi
    public function getProduksi()
    {
        try {
            // Ambil data produksi dari tabel laporan_produksi dengan join ke tabel ketersediaan_barang dan users
            $produksi = Produksi::join('ketersediaan_barang', 'laporan_produksi.id_produk', '=', 'ketersediaan_barang.id_produk')
                ->join('users', 'laporan_produksi.id_user', '=', 'users.id_user') // Ubah id_user sesuai dengan nama kolom yang benar di tabel laporan_produksi
                ->select('laporan_produksi.*', 'ketersediaan_barang.nama_produk', 'users.nama as nama_user') // Gunakan as untuk memberi alias pada kolom users.nama
                ->get();

            // Jika data ditemukan, kirimkan respons JSON
            return response()->json(['message' => 'Success', 'produksi' => $produksi], 200);
        } catch (\Exception $e) {
            // Jika terjadi kesalahan, kirimkan respons JSON dengan pesan kesalahan
            return response()->json(['message' => 'Error', 'error' => $e->getMessage()], 500);
        }
    }

    public function updateStatus(Request $request)
    {
        // Validasi request sesuai kebutuhan Anda
        $request->validate([
            'id_produksi' => 'required|integer',
            'status_produksi' => 'required|string',
        ]);

        // Perbarui status pesanan di database
        $produksi = Produksi::find($request->id_produksi);

        if (!$produksi) {
            return response()->json(['message' => 'Produksi tidak ditemukan'], 404);
        }

        $produksi->status_produksi = $request->status_produksi;
        $produksi->save();

        return response()->json(['message' => 'Status berhasil diperbarui']);
    }

    public function updateJumlahProduk(Request $request)
    {
        $request->validate([
            'id_produk' => 'required|integer',
            'jumlah_produk' => 'required|integer',
        ]);
    
        // Temukan atau buat entri di tabel ketersediaan_barang berdasarkan id_produk
        $produk = Stock::firstOrNew(['id_produk' => $request->id_produk]);
    
        // Simpan jumlah_produk yang ada sebelum pembaruan
        $existingQuantity = $produk->jumlah_produk;
    
        // Tetapkan jumlah_produk yang baru
        $newQuantity = $request->jumlah_produk;
    
        // Update jumlah_produk dengan total
        $produk->jumlah_produk = $existingQuantity + $newQuantity;
    
        // Simpan perubahan
        $produk->save();
    
        return response()->json([
            'message' => 'Stock berhasil diperbarui',
            'data' => [
                'id_produk' => $produk->id_produk,
                'jumlah_produk' => $produk->jumlah_produk,
            ],
        ]);
    }
    

    public function store(Request $request)
    {
        $request->validate([
            'id_produk' => 'required|exists:ketersediaan_barang,id_produk',
            'id_user' => 'required|exists:users,id_user',
            'nama_ruangan' => 'required|string',
            'jumlah_produksi' => 'required|integer|min:1',
            'tanggal_produksi' => 'required|date',
        ]);

        // Generate kode produksi secara otomatis
        $kodeProduksi = 'PROD-' . date('YmdHis') . rand(1000, 9999);

        // Set status produksi ke "belum sesuai"
        $statusProduksi = 'belum selesai';

        // Simpan data ke database
        $laporanProduksi = new Produksi;
        $laporanProduksi->kode_produksi = $kodeProduksi;
        $laporanProduksi->id_produk = $request->id_produk;
        $laporanProduksi->jumlah_produksi = $request->jumlah_produksi;
        $laporanProduksi->id_user = $request->id_user;
        $laporanProduksi->nama_ruangan = $request->nama_ruangan;
        $laporanProduksi->status_produksi = $statusProduksi;
        $laporanProduksi->tanggal_produksi = $request->tanggal_produksi;
        $laporanProduksi->save();

        return response()->json(['message' => 'Jadwal produksi berhasil disimpan'], 201);
    }
}