import 'package:flutter/material.dart';
import 'package:suco/login.dart';
import 'package:suco/edit_profile.dart';
import 'package:suco/admin/man_user.dart';
import 'package:suco/admin/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({super.key});

  @override
  State<SidebarDrawer> createState() => SidebarDrawerState();
}

class SidebarDrawerState extends State<SidebarDrawer> {
  String selectedLanguage = 'IDN';
  String userName = '';
  String userRoles = '';

  @override
  void initState() {
    super.initState();
    loadSelectedLanguage();
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
        case 'USER MANAGEMENT':
          return 'MANAJEMEN PENGGUNA';
        case 'SETTINGS':
          return 'PENGATURAN';
        case 'LOG OUT':
          return 'KELUAR';

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
          SizedBox(height: 40.0,),
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
            leading: Icon(Icons.settings_accessibility_outlined),
            title: Text(getTranslatedText('USER MANAGEMENT')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManagementPage()),
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
