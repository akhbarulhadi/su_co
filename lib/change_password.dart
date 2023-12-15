import 'dart:convert';
import 'package:suco/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class ChangePassWidget extends StatefulWidget {
  const ChangePassWidget({Key? key}) : super(key: key);

  @override
  State<ChangePassWidget> createState() => ChangePassState();
}

class ChangePassState extends State<ChangePassWidget> {
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  bool _obscureText3 = true;
  bool isDataBenar = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadThemePreference();
    loadSelectedLanguage();
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

  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
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
      return text;
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedToken = prefs.getString('access_token') ?? '';

    final response = await http.post(
      Uri.parse(ApiConfig.changePassword),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $storedToken',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      print('Password berhasil diperbarui');
      setState(() {
        isDataBenar = false; // Set data ke false
        currentPasswordController.clear(); // Kosongkan form
        newPasswordController.clear();
        confirmPasswordController.clear();
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GiffyDialog.image(
            Image.asset('lib/assets/success-tick-dribbble.gif',
              height: 200,
              fit: BoxFit.cover,
            ),
            title: Text(
              getTranslatedText('Successfully'),
              textAlign: TextAlign.center,
            ),
            content: Text(
              getTranslatedText(''),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(getTranslatedText('Tutup')),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 40),
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    } else {
      print('Gagal mengganti password: ${response.body}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GiffyDialog.image(
            Image.asset(
              'lib/assets/failed.gif',
              height: 200,
              fit: BoxFit.cover,
            ),
            title: Text(
              getTranslatedText('Failed'),
              textAlign: TextAlign.center,
            ),
            content: Text(
              getTranslatedText(''),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(getTranslatedText('Tutup')),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 40),
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData =
    isDarkTheme ? ThemeData.dark() : ThemeData.light();
    return MaterialApp(
      color: isDarkTheme ? Colors.black : Colors.white,
      theme: themeData,
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
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
                      color: isDarkTheme ? Colors.white10 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkTheme ? Colors.white70 : Colors.black,
                        width: 0.3,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
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
                                getTranslatedText(
                                    'Please enter your current password and new password below.'),
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            TextFormField(
                              controller: currentPasswordController,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Isi Datanya';
                                };
                              },
                              style: TextStyle(fontSize: 16),
                            ),
                            TextFormField(
                              controller: newPasswordController,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Isi Datanya';
                                } else if (value.length < 8) {
                                  return 'Minimal 8 karakter';
                                } else if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$')
                                    .hasMatch(value)) {
                                  return 'Password harus mengandung kombinasi huruf dan angka';
                                }
                                return null;
                              },
                              style: TextStyle(fontSize: 16),
                            ),
                            TextFormField(
                              obscureText: _obscureText3,
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                labelText:
                                getTranslatedText('Confirm New Password'),
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
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(50, 50, 50, 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (currentPasswordController.text.isNotEmpty &&
                                      newPasswordController.text.isNotEmpty && _formKey.currentState!.validate()) {
                                    changePassword(currentPasswordController.text,
                                        newPasswordController.text);
                                  } else {
                                    // Tampilkan pesan kesalahan atau lakukan sesuatu sesuai kebutuhan
                                  }
                                },
                                child: Text(
                                  getTranslatedText('Save Changes'),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
