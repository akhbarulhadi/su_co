import 'package:flutter/material.dart';
import 'package:suco/login.dart';
import 'package:suco/staff_gudang/jadwal.dart';
import 'package:suco/staff_gudang/dashboard.dart';
import 'package:suco/edit_profile.dart';
import 'package:suco/staff_gudang/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/staff_gudang/stock.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({super.key});

  @override
  State<SidebarDrawer> createState() => SidebarDrawerState();
}

class SidebarDrawerState extends State<SidebarDrawer> {
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih

  @override
  void initState() {
    super.initState();
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
  }

  void loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'IDN';
    });
  }

  // Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Main Page':
          return 'Halaman Utama';
        case 'REPORT':
          return 'LAPORAN';
        case 'INPUT':
          return 'INPUT';
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 40.0,),
            ListTile(
              leading: Image(
                image: AssetImage('lib/assets/user.png'),
              ),
              title: Text('Damar'),
              subtitle: Text('Staff Gudang'),
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
                MaterialPageRoute(builder: (context) => DashboardPageStaff()),
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
            leading: Icon(Icons.event),
            title: Text(getTranslatedText('SCHEDULE')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TableEventsExample()),
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
            onTap: () {
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
