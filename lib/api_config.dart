
// yang perlu di tambahkan di codingan yang menggunakan url api
// import 'package:suco/api_config.dart';
// Uri.parse(ApiConfig.namaFile),
class ApiConfig {
  static const String baseURL = 'http://192.168.38.100:8000'; // Ganti dengan URL API Anda
  static const String baseUrl = '$baseURL/api'; // Ganti dengan URL API Anda
  static const String login = '$baseUrl/login';
  static const String getProfile = '$baseUrl/get-profile';
  static const String editProfile = '$baseUrl/edit-profile';
  static const String users = '$baseUrl/users';
  static const String getfoto = '$baseUrl/get-foto';
  static const String register = '$baseUrl/register';
  static const String changePassword = '$baseUrl/change-password';
  // Tambahkan URL API lainnya sesuai kebutuhan
  static const String stock = '$baseUrl/stock';
  static const String stock_kepala_gudang = '$baseUrl/stock/kepala-gudang';
  static const String client =  '$baseUrl/klien';
  static const String pesanan =  '$baseUrl/pesanan';
  static const String pesanan_dashboard_marketing =  '$baseUrl/pesanan/dashboard-marketing';
  static const String pesanan_dashboard_supervisor =  '$baseUrl/pesanan/dashboard-supervisor';
  static const String tambah_pesanan =  '$baseUrl/pesanan/tambah-pesanan';
  static const String status_update= '$baseUrl/pesanan/update-status';
  static const String status_update_batal= '$baseUrl/pesanan/update-status-batal';
  static const String update_harga =  '$baseUrl/stock/update-harga';
  static const String status_pesanan= '$baseUrl/pesanan/update-status-siapdiantar';
  static const String show_history= '$baseUrl/pesanan/show-history';
  static const String add_data_client= '$baseUrl/add/data-klien';
  static const String kurangi_stok = '$baseUrl/ketersediaan/update-availability';
  static const String add_product = '$baseUrl/stock/add-stock';
  static const String kurangi_stok1 = '$baseUrl/pesanan/updateProductAvailability';
  static const String produksi = '$baseUrl/produksi';
  static const String leaders = '$baseUrl/roles-leader';
  static const String jadwal_produksi= '$baseUrl/jadwal';
  static const String status= '$baseUrl/produksi/update-status';
  static const String tambah_jumlah_produk= '$baseUrl/produksi/update-stock';
  static const String reset_password= '$baseUrl/resetpassword';
  static const String pemasukan= '$baseUrl/pesanan/pemasukan';
  static const String produksi_selesai= '$baseUrl/produksi/update-product';
  static const String update_status_produksi_selesai= '$baseUrl/produksi/update-status-selesai';
  static const String get_production_staffgudang= '$baseUrl/produksi/production-staffgudang';
  static const String get_production_supervisor= '$baseUrl/produksi/production-supervisor';
  static const String get_production_supervisor_dashboard= '$baseUrl/produksi/production-supervisor-dashboard';
  static const String get_production_leader= '$baseUrl/produksi/production-leader';
  static const String get_production_history= '$baseUrl/produksi/production-history';
  static const String stock_dashboard = '$baseUrl/stock/dashboard-marketing';
  static const String get_production_leader_dashboard = '$baseUrl/produksi/production-leader-dashboard';
  static const String get_production_staff_dashboard = '$baseUrl/produksi/production-staff-dashboard';
  static const String status_user = '$baseUrl/update-status-user';
  static const String pemasukan_produksi= '$baseUrl/produksi/pemasukan-produksi';

}