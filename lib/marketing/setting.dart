import 'package:flutter/material.dart';
import 'package:suco/change_password.dart';
import 'package:suco/marketing/dashboard.dart';
import 'package:suco/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({Key? key}) : super(key: key);

  @override
  _SettingWidgetState createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  late bool switchListTileValueNotifications;
  late bool switchListTileValueTheme;

  bool isDarkTheme = false; // Tambahkan variabel tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    switchListTileValueNotifications = true;
    loadThemePreference(); // Muat preferensi tema saat aplikasi dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat aplikasi dimulai
  }

  // Fungsi untuk memuat preferensi tema dari shared_preferences
  void loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      switchListTileValueTheme =
          isDarkTheme; // Setel nilai switch sesuai preferensi tema
    });
  }

  // Fungsi untuk menyimpan preferensi tema ke shared_preferences
  void saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', value);
  }

  void loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'IDN';
    });
  }

  void saveSelectedLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedLanguage', language);
  }

  // Fungsi untuk menampilkan dialog pilihan bahasa
  Future<void> showLanguageDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslatedText(
              'Select Language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Bahasa Indonesia'),
                onTap: () {
                  setState(() {
                    selectedLanguage = 'IDN';
                  });
                  saveSelectedLanguage('IDN'); // Simpan bahasa yang dipilih
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('English'),
                onTap: () {
                  setState(() {
                    selectedLanguage = 'ENG';
                  });
                  saveSelectedLanguage('ENG'); // Simpan bahasa yang dipilih
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Settings':
          return 'Pengaturan';
        case 'Edit Profile':
          return 'Ubah Profil';
        case 'Change Password':
          return 'Ganti Kata Sandi';
        case 'Notification':
          return 'Notifikasi';
        case 'Other':
          return 'Lainnya';
        case 'Language':
          return 'Bahasa';
        case 'Dark Theme':
          return 'Tema Gelap';
        case 'Account':
          return 'Akun';
        case 'Select Language':
          return 'Pilih Bahasa';
        // Tambahkan teks lainnya sesuai kebutuhan
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
    return MaterialApp(
      theme: isDarkTheme
          ? ThemeData.dark()
          : ThemeData.light(), // Menyesuaikan tema sesuai isDarkTheme
      themeMode: ThemeMode.system,
      home: Scaffold(
        key: scaffoldKey,
        backgroundColor: isDarkTheme
            ? Colors.black
            : Colors.white, // Menyesuaikan latar belakang sesuai tema
        appBar: AppBar(
          backgroundColor:
              Colors.transparent, // Ubah warna latar belakang ke putih
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDarkTheme
                  ? Colors.white
                  : Colors.black, // Menyesuaikan latar belakang sesuai tema
              size: 24,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashboardPageMarketing()));
            },
          ),
          title: Align(
            alignment: Alignment.center,
            child: Text(
              getTranslatedText(
                  'Settings'), // Menggunakan fungsi getTranslatedText
              style: TextStyle(
                fontFamily: 'Outfit',
                color: isDarkTheme
                    ? Colors.white
                    : Colors.black, // Menyesuaikan latar belakang sesuai tema
              ),
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: 45.0,
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start, // Pindahkan ke kiri
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: Icon(
                        Icons.manage_accounts_sharp,
                        color: Color(0xFF0A4F81),
                        size: 24,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: Text(
                        getTranslatedText('Account'),
                        style: TextStyle(
                          fontFamily: 'Readex Pro',
                          fontSize: 20,
                          color: Color(0xFF0A4F81),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  getTranslatedText('Edit Profile'),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                  ),
                ),
                contentPadding: EdgeInsets.fromLTRB(24, 1, 24, 1),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 20,
                ),
                tileColor: isDarkTheme
                    ? Colors.black
                    : Colors.white, // Menyesuaikan latar belakang sesuai tema
                dense: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfile()),
                  );
                },
              ),
              ListTile(
                title: Text(
                  getTranslatedText('Change Password'),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                  ),
                ),
                contentPadding: EdgeInsets.fromLTRB(24, 1, 24, 1),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 20,
                ),
                tileColor: isDarkTheme
                    ? Colors.black
                    : Colors.white, // Menyesuaikan latar belakang sesuai tema
                dense: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePassWidget()),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: Icon(
                        Icons.notifications,
                        color: Color(0xFF0A4F81),
                        size: 24,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: Text(
                        getTranslatedText('Notification'),
                        style: TextStyle(
                          fontFamily: 'Readex Pro',
                          fontSize: 20,
                          color: Color(0xFF0A4F81),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                value: switchListTileValueNotifications,
                onChanged: (newValue) {
                  setState(() {
                    switchListTileValueNotifications = newValue;
                  });
                },
                title: Text(
                  getTranslatedText('Notification'),
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                  ),
                ),
                tileColor: isDarkTheme
                    ? Colors.black
                    : Colors.white, // Menyesuaikan latar belakang sesuai tema
                activeColor: Colors.white,
                activeTrackColor: Colors.green,
                dense: false,
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.fromLTRB(24, 1, 24, 1),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: Icon(
                          Icons.settings_suggest_outlined,
                          color: Color(0xFF0A4F81),
                          size: 24,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: Text(
                        getTranslatedText('Other'),
                        style: TextStyle(
                          fontFamily: 'Readex Pro',
                          fontSize: 20,
                          color: Color(0xFF0A4F81),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  getTranslatedText('Language'),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                  ),
                ),
                contentPadding: EdgeInsets.fromLTRB(24, 1, 24, 1),
                trailing: InkWell(
                  onTap: () {
                    showLanguageDialog(); // Tampilkan dialog pilihan bahasa
                  },
                  child: Container(
                    width: 76,
                    height: 22,
                    decoration: ShapeDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Color(0x443C3C3C)),
                      ),
                    ),
                    child: Text(
                      selectedLanguage == 'IDN' ? 'Bahasa' : 'English',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ),
                ),
                tileColor: isDarkTheme ? Colors.black : Colors.white,
                dense: false,
              ),
              SwitchListTile(
                value: switchListTileValueTheme,
                onChanged: (newValue) {
                  setState(() {
                    switchListTileValueTheme = newValue;
                    isDarkTheme =
                        newValue; // Mengganti tema gelap sesuai dengan nilai switch
                    saveThemePreference(newValue); // Simpan preferensi tema
                  });
                },
                title: Text(
                  getTranslatedText('Dark Theme'),
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                  ),
                ),
                tileColor: isDarkTheme
                    ? Colors.black
                    : Colors.white, // Menyesuaikan latar belakang sesuai tema
                activeColor: Colors.white,
                activeTrackColor: Colors.green,
                dense: false,
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.fromLTRB(24, 1, 24, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
