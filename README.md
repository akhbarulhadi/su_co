<a><p align="center"><img src="https://github.com/akhbarulhadi/suco/blob/main/lib/assets/icon_suco.png" width="150" alt="Laravel Logo"></a></p>

<p style="font-size: 20px;" align="center">
SUCO
</p>

## Information

Aplikasi Suplai Controller Ini (SUCO) adalah sebuah aplikasi yang bertujuan untuk memudahkan proses suplai barang dari produksi ke gudang.

Keuntungan menggunakan aplikasi suplai controller (SUCO) adalah memudahkan Pengguna dalam melihat jumlah barang yang tersedia, barang yang berhasil di produksi harga satuan, Dll.

## License

PBL_SUCO

## Cara pakai Git

1. git init,
2. git add nama_file/\*,
3. git commit -m "percobaan" (untuk comment/deskripsi),
4. git push -u origin (untuk dorong file dari directory lokal laptop ke repository github),
5. git pull origin main (untuk ambil dari repo github ke directory lokal).

## cara menjalankan aplikasi:

1. git clone link github
2. buka folder sucos
3. setelah itu 'composer install'/'composer update' di command prompt directory sucos
4. env.example copas dan jadikan .env
5. 'php artisan key:generate' di command prompt directory sucos
6. 'php artisan storage:link' di command prompt directory sucos
7. 'php artisan migrate' di command prompt directory sucos
8. hidupkan apache dan mysql
9. 'php artisan serve --host=IPv4 Address' di command prompt directory sucos
10. buka folder su_co dan pub get package flutter
11. setelah itu copy api server yg di jalankan di nomor 9 dan paste ke halaman lib/api_config.dart
12. jalankkan emulator setelah itu run debugging
