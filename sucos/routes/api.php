<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\KlienController;
use App\Http\Controllers\PesananController;
use App\Http\Controllers\StockController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/user', [AuthController::class, 'user']);
Route::get('/users', [AuthController::class, 'index']);
Route::middleware('auth:sanctum')->post('/change-password', [AuthController::class, 'changePassword']);
Route::middleware('auth:sanctum')->get('/get-profile', [AuthController::class, 'getProfile']);
Route::middleware('auth:sanctum')->post('/edit-profile', [AuthController::class, 'editProfile']);

// untuk halaman pesanan
Route::get('/pesanan', [PesananController::class, 'showPesanan']);
Route::get('/pesanan/show-history', [PesananController::class, 'showHistory']);
Route::post('pesanan/update-status', [PesananController::class, 'updateStatus']);
Route::post('pesanan/update-status-siapdiantar', [PesananController::class, 'updateStatusSiapDiantar']);
Route::post('pesanan/tambah-pesanan', [PesananController::class, 'store']);

// untuk halaman stock
Route::get('/stock', [StockController::class, 'show']);
Route::post('stock/update-harga', [StockController::class, 'updateHarga']);
Route::post('/stock/add-stock', [StockController::class, 'store']);


// untuk halaman data klien
Route::post('/add/data-klien', [KlienController::class, 'store']);
Route::get('/klien', [KlienController::class, 'showKlien']);

// untuk halaman produksi


// Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);
