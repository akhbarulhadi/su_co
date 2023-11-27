import 'package:flutter/material.dart';
import 'package:suco/login.dart';
import 'package:suco/marketing/dashboard.dart';
import 'package:suco/marketing/data_client.dart';
import 'package:suco/edit_profile.dart';
import 'package:suco/marketing/history_order.dart';
import 'package:suco/marketing/laporan.dart';
import 'package:suco/admin/man_user.dart';
import 'package:suco/marketing/pesanan.dart';
import 'package:suco/marketing/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/marketing/stock.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({super.key});

  @override
  State<SidebarDrawer> createState() => SidebarDrawerState();
}

class SidebarDrawerState extends State<SidebarDrawer> {
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  String userName = '';
  String userRoles = '';

  @override
  void initState() {
    super.initState();
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    loadUserInfo(); // Memuat informasi pengguna saat halaman dimulai
  }

  void loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'IDN';
    });
  }

  void loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('nama') ?? '';
      userRoles = prefs.getString('roles') ?? '';
    });
  }

  // Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Main Page':
          return 'Halaman Utama';
        case 'ORDER STATUS':
          return 'STATUS PEMESANAN';
        case 'INPUT ORDER':
          return 'MASUKAN PESANAN';
        case 'SCHEDULE':
          return 'JADWAL';
        case 'USER MANAGEMENT':
          return 'MANAJEMEN PENGGUNA';
        case 'SETTINGS':
          return 'PENGATURAN';
        case 'LOG OUT':
          return 'KELUAR';
        case 'AVAILABLE ITEMS':
          return 'KETERSEDIAAN BARANG';
        case 'ORDER HISTORY':
          return 'RIWAYAT PEMESANAN';

        default:
          return text;
      }
    } else {
      // Teks dalam bahasa Inggris (default)
      return text;
    }
  }

  // Fungsi untuk membersihkan data di SharedPreferences
  Future<void> _clearUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 40.0,
          ),
          ListTile(
            leading: Image(
              image: AssetImage('lib/assets/user.png'),
            ),
            title: Text(userName), // Menampilkan nama pengguna
            subtitle: Text(userRoles), // Menampilkan peran pengguna
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text(getTranslatedText('Main Page')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardPageMarketing()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.task),
            title: Text(getTranslatedText('ORDER STATUS')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LaporanWidget()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.input_outlined),
            title: Text(getTranslatedText('INPUT ORDER')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Pesanan()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.production_quantity_limits),
            title: Text(getTranslatedText('AVAILABLE ITEMS')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Stock()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text(getTranslatedText('ORDER HISTORY')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryOrder()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(getTranslatedText('SETTINGS')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingWidget()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(getTranslatedText('LOG OUT')),
            onTap: () async {
              await _clearUserInfo();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
    );
  }
}
