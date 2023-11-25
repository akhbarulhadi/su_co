import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassWidget extends StatefulWidget {
  const ChangePassWidget({super.key});

  @override
  State<ChangePassWidget> createState() => ChangePassState();
}

class ChangePassState extends State<ChangePassWidget> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  bool _obscureText1 = true; // Untuk menentukan apakah teks tersembunyi
  bool _obscureText2 = true; // Untuk menentukan apakah teks tersembunyi
  bool _obscureText3 = true; // Untuk menentukan apakah teks tersembunyi



  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
  }
  void loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'IDN';
    });
  }

  void loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  // Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Change Password':
          return 'Ganti Kata Sandi';
        case 'Please enter your current password and new password below.':
          return 'Silakan masukkan kata sandi Anda saat ini dan kata sandi baru di bawah.';
        case 'Current Password':
          return 'Kata Sandi Saat Ini';
        case 'New Password':
          return 'Kata Sandi Baru';
        case 'Confirm New Password':
          return 'Konfirmasi Kata Sandi Baru';
        case 'Save Changes':
          return 'Simpan Perubahan';

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
    final ThemeData themeData = isDarkTheme ? ThemeData.dark() : ThemeData.light();
    return MaterialApp(
      color: isDarkTheme ? Colors.black : Colors.white,
      theme: themeData, // Terapkan tema sesuai dengan preferensi tema gelap
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
          ),
          backgroundColor: Colors.transparent, // Mengubah warna AppBar
          elevation: 0, // Menghilangkan efek bayangan di bawah AppBar
          iconTheme: IconThemeData(
              color: isDarkTheme ? Colors.white : Colors.black), // Mengatur ikon (misalnya, tombol back) menjadi hitam
          title: Align(
            alignment: Alignment.center,
            child: Text(
              getTranslatedText('Change Password'),
              style: TextStyle(
                fontSize: 20.0,
                color: isDarkTheme ? Colors.white : Colors.black,
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
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkTheme
                          ? Colors.white10
                          : Colors
                          .white, // Ganti dengan warna latar belakang yang sesuai
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkTheme
                            ? Colors.white70
                            : Colors.black, // Ganti dengan warna yang sesuai
                        width: 0.3,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslatedText('Change Password'),
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 16),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 12, bottom: 24),
                            child: Text(
                              getTranslatedText('Please enter your current password and new password below.'),
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          TextFormField(
                            obscureText: _obscureText1,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Current Password'),
                              contentPadding: EdgeInsets.all(24),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText1
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText1 = !_obscureText1;
                                  });
                                },
                              ),

                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          TextFormField(
                            obscureText: _obscureText2,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('New Password'),
                              contentPadding: EdgeInsets.all(24),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText2
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText2 = !_obscureText2;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          TextFormField(
                            obscureText: _obscureText3,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Confirm New Password'),
                              contentPadding: EdgeInsets.all(24),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText3
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText3 = !_obscureText3;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(50, 50, 50, 10),
                            child: ElevatedButton(
                              onPressed: () {
                                //Navigator.push(
                                //context, MaterialPageRoute(builder: (context) => DataPesanan()));
                              },
                              child: Text(
                                getTranslatedText('Save Changes'),
                                style: TextStyle(
                                  fontSize: 16,
                                ),),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(370, 44),
                                padding: EdgeInsets.all(0),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                primary: Color(0xFF3DA9FC),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
