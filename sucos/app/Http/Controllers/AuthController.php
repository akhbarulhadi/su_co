<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{
    public function index()
    {
        $users = User::where('roles', '!=', 'admin')->get();
        $users = $users->map(function ($user) {
            if (!$user['foto']) {
                $user['foto'] = asset('storage/public');
            }
            return $user;
        });

        return response()->json(['users' => $users]);
    }

    public function updateStatus(Request $request)
    {
        try {
            // Validasi request sesuai kebutuhan Anda
            $request->validate([
                'id_user' => 'required', // Sesuaikan dengan nama field ID pada model User
                'status' => 'required|in:aktif,tidak-aktif',
            ]);

            // Cari pengguna berdasarkan ID
            $user = User::find($request->id_user);

            if (!$user) {
                return response()->json(['message' => 'User not found'], 404);
            }

            // Perbarui status pengguna
            $user->update([
                'status' => $request->status,
            ]);

            return response()->json(['message' => 'Status pengguna berhasil diperbarui', 'user' => $user], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 500);
        }
    }

    public function getLoggedInUser()
    {
        $loggedInUser = auth()->user();

        if (!$loggedInUser) {
            return response()->json(['error' => 'User not authenticated'], 401);
        }

        // Mengubah foto ke default jika tidak ada
        if (!$loggedInUser['foto']) {
            $loggedInUser['foto'] = asset('storage/public/default-profile.jpg');
        }

        return response()->json(['user' => $loggedInUser]);
    }


    public function register(Request $request)
    {
        $request->validate([
            'id_staff' => 'required|string|unique:users',
            'password' => 'required|string',
            'nama' => 'required|string',
            'jenis_kelamin' => 'required|in:Laki-laki,Perempuan',
            'alamat' => 'required|string',
            'no_tlp' => 'required|string|min:10|unique:users',
            'email' => 'required|string|unique:users',
            'status' => 'required|in:aktif,tidak-aktif',
            'roles' => 'required|in:marketing,supervisor,leader,staff_gudang,kepala_gudang,admin',
        ]);

        // Inisialisasi variabel foto dengan default-profile.jpg
        $defaultFoto = 'default-profile.jpg';
        $foto = $defaultFoto;

        // Cek apakah ada file foto yang diunggah
        if ($request->hasFile('foto')) {
            // Jika ada, simpan foto di penyimpanan dan dapatkan nama filenya
            $foto = Str::random(10) . '.' . $request->file('foto')->getClientOriginalExtension();
            $path = $request->file('foto')->storeAs('public/foto', $foto);
        }

        // Buat pengguna baru dengan data yang diterima dan foto yang telah ditentukan
        $user = User::create([
            'id_staff' => $request->id_staff,
            'password' => Hash::make($request->password),
            'nama' => $request->nama,
            'jenis_kelamin' => $request->jenis_kelamin,
            'alamat' => $request->alamat,
            'no_tlp' => $request->no_tlp,
            'foto' => $foto,
            'email' => $request->email,
            'status' => $request->status,
            'roles' => $request->roles,
        ]);

        // Buat token untuk pengguna baru
        $token = $user->createToken('auth_token')->plainTextToken;

        // Kembalikan respons JSON dengan informasi pengguna dan token
        $response = ['user' => $user, 'token' => $token];
        return response()->json(['message' => 'Data User berhasil dibuat', 'data' => $user], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required', // Mengubah validasi untuk email
            'password' => 'required|string',
        ]);
    
        $credentials = $request->only('email', 'password');
    
        if (Auth::attempt($credentials)) {
            $user = Auth::user();
    
            // Pengecekan status pengguna
            if ($user->status === 'aktif') {
                // Cek role
                $allowedRoles = ['admin', 'marketing', 'supervisor', 'leader', 'staff_gudang', 'kepala_gudang'];
                
                if (in_array($user->roles, $allowedRoles)) {
                    $token = $user->createToken('authToken')->plainTextToken;
    
                    // Menggunakan 'roles' sebagai informasi peran dalam respons
                    return response()->json(['user' => $user, 'roles' => $user->roles, 'access_token' => $token]);
                } else {
                    Auth::logout(); // Logout jika role tidak diizinkan
                    return response()->json(['message' => 'Unauthorized role'], 403);
                }
            } else {
                Auth::logout(); // Logout jika status tidak aktif
                return response()->json(['message' => 'Inactive account'], 403);
            }
        } else {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }
    }
    

    public function getProfile(Request $request)
    {
        try {
            $user = auth()->user(); // Pastikan pengguna sudah diautentikasi
            if (!$user) {
                return response()->json(['error' => 'User tidak diautentikasi'], 401);
            }

            // Sesuaikan struktur data profil sesuai dengan model pengguna Anda
            $profileData = [
                'alamat' => $user->alamat,
                'no_tlp' => $user->no_tlp,
                // Tambahkan properti lain sesuai kebutuhan
            ];

            return response()->json(['data' => $profileData], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
    public function editProfile(Request $request)
    {
        try {
            $user = Auth::user();

            if (!$user) {
                return response()->json(['message' => 'User not found'], 404);
            }

            // Periksa apakah ada file gambar yang diunggah
            if ($request->hasFile('foto')) {
                // Validasi file gambar
                $request->validate([
                    'foto' => 'image|mimes:jpeg,png,jpg,gif',
                    'alamat' => 'required|string',
                    'no_tlp' => 'required|string',
                ]);

                // Simpan foto yang baru di storage
                $fotoPath = $request->file('foto')->store('public/foto');
                $fotoFileName = basename($fotoPath);

                // Periksa apakah ada foto lama
                if ($user->foto) {
                    // Jika ada, tambahkan nama foto yang baru ke daftar foto pengguna
                    $user->foto = $fotoFileName;
                } else {
                    // Jika tidak ada, update informasi pengguna dengan foto yang baru
                    $user->foto = $fotoFileName;
                }
            }

            // Update informasi pengguna dengan alamat dan nomor telepon baru
            $user->update([
                'alamat' => $request->alamat,
                'no_tlp' => $request->no_tlp,
            ]);

            return response()->json(['message' => 'Profil berhasil diperbarui', 'user' => $user], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 500);
        }
    }



    public function changePassword(Request $request)
    {
        try {
            $request->validate([
                'current_password' => 'required|string',
                'new_password' => 'required|string|min:8',
            ]);

            $user = Auth::user();

            if (!$user) {
                return response()->json(['message' => 'User not found'], 404);
            }

            if (!Hash::check($request->current_password, $user->password)) {
                return response()->json(['message' => 'Invalid current password'], 422);
            }

            // Menggunakan fungsi mutator untuk mengenkripsi password baru
            $user->password = bcrypt($request->new_password);
            $user->save();

            return response()->json(['message' => 'Password berhasil diperbarui'], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 500);
        }
    }


    public function user(Request $request)
    {
        return $request->user();
    }

    public function resetPassword(Request $request)
    {
        // Validasi request sesuai kebutuhan Anda
        $request->validate([
            'id_user' => 'required|integer',
            'password' => 'required|string',
        ]);

        // Perbarui status pesanan di database
        $user = User::find($request->id_user);

        if (!$user) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        $user->password = $request->password;
        $user->save();

        return response()->json(['message' => 'Status berhasil diperbarui']);
    }
}
