import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:suco/history_order.dart';
import 'package:suco/kepala_gudang/status_pesanan.dart';
import 'package:suco/login.dart';
import 'package:suco/kepala_gudang/jadwal.dart';
import 'package:suco/kepala_gudang/dashboard.dart';
import 'package:suco/edit_profile.dart';
import 'package:suco/kepala_gudang/setting.dart';
import 'package:suco/kepala_gudang/stock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

final StreamController<void> _streamController =
    StreamController<void>.broadcast();

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({Key? key});

  @override
  State<SidebarDrawer> createState() => SidebarDrawerState();
}

class SidebarDrawerState extends State<SidebarDrawer> {
  String selectedLanguage = 'IDN';
  String userName = '';
  String userRoles = '';
  List _listData = [];
  List _filteredData = [];

  @override
  void initState() {
    super.initState();
    loadSelectedLanguage();
    loadUserInfo();
    _getData();
    _streamController.stream.listen((_) {
      _getData();
    });
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

  Future<void> _getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('access_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConfig.getfoto),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          _listData = [data['user']];
          _filteredData = _listData;
        });

        print(_filteredData);
        print(_filteredData.isNotEmpty
            ? _filteredData[0]['foto']
            : 'No photo available');
      }
    } catch (e) {
      print(e);
    }
  }

  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
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
        case 'ORDER STATUS':
          return 'STATUS PEMESANAN';
        case 'Head Of Warehouse':
          return 'Kepala Gudang';
        case 'ORDER HISTORY':
          return 'RIWAYAT PESANAN';

        default:
          return text;
      }
    } else {
      return text;
    }
  }

  Future<void> _clearUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedLanguage = prefs.getString('selectedLanguage') ?? 'IDN'; // Simpan bahasa yang dipilih
    bool isDarkTheme = prefs.getBool('isDarkTheme') ?? false; // Simpan preferensi tema
    await prefs.clear(); // Hapus semua data di SharedPreferences
    await prefs.setString('selectedLanguage', selectedLanguage); // Set kembali bahasa yang dipilih
    await prefs.setBool('isDarkTheme', isDarkTheme); // Set kembali preferensi tema
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
            leading: CircleAvatar(
              radius: 30.0,
              backgroundColor: Color(0xFF7839CD),
              child:
                  _filteredData.isNotEmpty && _filteredData[0]['foto'] != null
                      ? CircleAvatar(
                          radius: 28.0,
                          backgroundImage: NetworkImage(
                            '${ApiConfig.baseURL}/storage/foto/${_filteredData[0]['foto']}',
                          ),
                        )
                      : CircleAvatar(
                          radius: 28.0,
                          backgroundColor: Colors.grey,
                        ),
            ),
            title: Text(userName),
            subtitle: Text(userRoles),
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
                    builder: (context) => DashboardPageLeaderWarehouse()),
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
            leading: Icon(Icons.task),
            title: Text(getTranslatedText('ORDER STATUS')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatusPesanan()),
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
