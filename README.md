<a><p align="center"><img src="https://github.com/akhbarulhadi/suco/blob/main/lib/assets/icon_suco.png" width="150" alt="Laravel Logo"></a></p>

<p style="font-size: 20px;" align="center">
SUCO
</p>

## Information

Aplikasi Suplai Controller (SUCO) memberikan berbagai manfaat signifikan bagi perusahaan dalam pengelolaan stok dan produksi. Dengan adanya SUCO, perusahaan dapat mencapai efisiensi operasional yang lebih tinggi, mengurangi waktu dan sumber daya yang dibutuhkan untuk manajemen stok dan produksi. Selain itu, aplikasi ini membantu meningkatkan produktivitas dengan memantau dan mengoptimalkan proses produksi secara akurat. Keputusan yang cepat dan tepat dapat diambil berkat data real-time yang diberikan oleh SUCO, memungkinkan manajemen untuk merespons perubahan pasar dengan lebih efektif.

## License

PBL_SUCO

## Git

1. git clone link github

1. git init,
2. git add nama_file/\*,
3. git commit -m "percobaan" (untuk comment/deskripsi),
4. git push -u origin (untuk dorong file dari directory lokal laptop ke repository github),

1. git pull origin main (untuk ambil dari repo github ke directory lokal).

## cara menjalankan aplikasi:

1. buka folder sucos
2. setelah itu 'composer install'/'composer update' di command prompt directory sucos
3. env.example copas dan jadikan .env
4. 'php artisan key:generate' di command prompt directory sucos
5. 'php artisan storage:link' di command prompt directory sucos
6. 'php artisan migrate' di command prompt directory sucos
7. hidupkan apache dan mysql
8. 'php artisan serve --host=IPv4 Address' di command prompt directory sucos
9. buka folder su_co dan pub get package flutter
10. setelah itu copy api server yg di jalankan di nomor 9 dan paste ke halaman lib/api_config.dart
11. jalankkan emulator setelah itu run debugging
