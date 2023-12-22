<?php

namespace App\Http\Controllers;

use App\Models\Pesanan;
use App\Models\Stock;
use Carbon\Carbon;
use Illuminate\Http\Request;

class PesananController extends Controller
{
    public function showPesanan()
    {
        $pesanan = Pesanan::join('ketersediaan_barang', 'pesanan.id_produk', '=', 'ketersediaan_barang.id_produk')
            ->join('data_klien', 'data_klien.id_klien', '=', 'pesanan.id_klien')
            ->select('pesanan.*', 'ketersediaan_barang.nama_produk', 'ketersediaan_barang.kode_produk', 'ketersediaan_barang.jumlah_produk', 'data_klien.nama_klien', 'data_klien.alamat', 'data_klien.nama_perusahaan')
            ->whereNotIn('pesanan.status_pesanan', ['Selesai'])
            ->orderBy('pesanan.status_pesanan') // Urutkan berdasarkan status_pesanan (opsional)
            ->orderByDesc('pesanan.id_pemesanan') // Urutkan secara descending berdasarkan ID untuk menempatkan yang 'Batal' di paling terakhir
            ->get();

        return response()->json(['message' => 'Success', 'pesanan' => $pesanan]);
    }

    public function showPesananDashboardMarketing()
    {
        $pesanan = Pesanan::join('ketersediaan_barang', 'pesanan.id_produk', '=', 'ketersediaan_barang.id_produk')
            ->join('data_klien', 'data_klien.id_klien', '=', 'pesanan.id_klien')
            ->select('pesanan.*', 'ketersediaan_barang.nama_produk', 'ketersediaan_barang.jumlah_produk', 'data_klien.nama_klien', 'data_klien.alamat', 'data_klien.nama_perusahaan')
            ->whereNotIn('pesanan.status_pesanan', ['Selesai', 'Batal', 'Menunggu'])
            ->take(5)
            ->get();
        return response()->json(['message' => 'Success', 'pesanan' => $pesanan]);
    }

    public function showPesananDashboardSupervisor()
    {
        $pesanan = Pesanan::join('ketersediaan_barang', 'pesanan.id_produk', '=', 'ketersediaan_barang.id_produk')
            ->join('data_klien', 'data_klien.id_klien', '=', 'pesanan.id_klien')
            ->select('pesanan.*', 'ketersediaan_barang.nama_produk', 'ketersediaan_barang.jumlah_produk', 'data_klien.nama_klien', 'data_klien.alamat', 'data_klien.nama_perusahaan')
            ->whereNotIn('pesanan.status_pesanan', ['Selesai', 'Batal', 'Siap Diantar'])
            ->take(5)
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
            ->whereNotIn('pesanan.status_pesanan', ['Menunggu', 'Siap Diantar', 'Batal'])
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
        $idPemesanan = $request->input('id_pemesanan');

        try {
            // Temukan pesanan berdasarkan ID
            $pesanan = Pesanan::find($idPemesanan);

            // Perbarui status_pesanan menjadi 'Siap Diantar'
            $pesanan->status_pesanan = 'Siap Diantar';
            $pesanan->save();

            return response()->json(['message' => 'Status pesanan berhasil diperbarui'], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Gagal memperbarui status pesanan'], 500);
        }
    }

    public function updateProductAvailability(Request $request)
    {
        $productId = $request->input('id_produk');
        $jumlahPesanan = $request->input('jumlah_pesanan');

        try {
            // Temukan produk berdasarkan ID
            $product = Stock::find($productId);

            // Verifikasi apakah jumlah_produk cukup
            if ($product->jumlah_produk >= $jumlahPesanan) {
                // Perbarui jumlah_produk
                $product->jumlah_produk -= $jumlahPesanan;
                $product->save();

                return response()->json(['message' => 'Jumlah produk berhasil diperbarui'], 200);
            } else {
                return response()->json(['message' => 'Jumlah produk tidak mencukupi'], 400);
            }
        } catch (\Exception $e) {
            return response()->json(['message' => 'Gagal mengurangkan jumlah produk'], 500);
        }
    }


    public function showPemasukan(Request $request)
    {
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        $pesanan = Pesanan::select('pesanan.status_pesanan')
            ->whereNotIn('pesanan.status_pesanan', ['Menunggu', 'Siap Diantar', 'Batal'])
            ->whereDate('pesanan.updated_at', '>=', $startDate)
            ->whereDate('pesanan.updated_at', '<=', $endDate)
            ->get();

        $total_harga_selesai = Pesanan::where('status_pesanan', 'Selesai')
            ->whereDate('pesanan.updated_at', '>=', $startDate)
            ->whereDate('pesanan.updated_at', '<=', $endDate)
            ->sum('harga_total');


        return response()->json(['message' => 'Success', 'total_harga_selesai' => $total_harga_selesai]);
    }

    public function updateStatusBatal(Request $request)
    {
        // Validasi request sesuai kebutuhan Anda
        $request->validate([
            'id_pemesanan' => 'required|integer',
            'batas_tanggal' => 'required|string',
            'status_pesanan' => 'required|string',
        ]);

        // Perbarui status pesanan di database
        $pesanan = Pesanan::find($request->id_pemesanan);

        if (!$pesanan) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        $pesanan->status_pesanan = $request->status_pesanan;
        $pesanan->batas_tanggal = $request->batas_tanggal;
        $pesanan->save();

        return response()->json(['message' => 'Status berhasil diperbarui']);
    }
}
