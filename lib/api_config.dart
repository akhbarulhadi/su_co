
// yang perlu di tambahkan di codingan yang menggunakan url api
// import 'package:suco/api_config.dart';
// Uri.parse(ApiConfig.namaFile),
class ApiConfig {
  static const String baseUrl = 'http://10.170.2.246:8000/api'; // Ganti dengan URL API Anda
  static const String login = '$baseUrl/login';
  static const String getProfile = '$baseUrl/get-profile';
  static const String editProfile = '$baseUrl/edit-profile';
  static const String users = '$baseUrl/users';
  static const String register = '$baseUrl/register';
  static const String changePassword = '$baseUrl/change-password';
  // Tambahkan URL API lainnya sesuai kebutuhan
  static const String stock = '$baseUrl/stock';
  static const String client =  '$baseUrl/klien';
  static const String pesanan =  '$baseUrl/pesanan';
  static const String tambah_pesanan =  '$baseUrl/pesanan/tambah-pesanan';
  static const String status_update= '$baseUrl/pesanan/update-status';
  static const String update_harga =  '$baseUrl/stock/update-harga';
  static const String status_pesanan= '$baseUrl/pesanan/update-status-siapdiantar';
  static const String show_history= '$baseUrl/pesanan/show-history';
  static const String add_data_client= '$baseUrl/add/data-klien';
  static const String kurangi_stok = '$baseUrl/ketersediaan/update-availability';
  static const String add_product = '$baseUrl/stock/add-stock';
  static const String kurangi_stok1 = '$baseUrl/pesanan/updateProductAvailability';

}