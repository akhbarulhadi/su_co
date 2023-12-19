import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/marketing/data_pesanan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:suco/marketing/pesanan.dart';

class DataClient extends StatefulWidget {
  const DataClient({super.key});

  @override
  State<DataClient> createState() => KlientPage();
}

class KlientPage extends State<DataClient> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  final _formKey = GlobalKey<FormState>();
  TextEditingController namaPerusahaanController = TextEditingController();
  TextEditingController namaKlienController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();
  TextEditingController faxController = TextEditingController();
  TextEditingController noBankController = TextEditingController();
  bool isDataBenar = false;
  bool isNumeric(String value) {
    return int.tryParse(value) != null;
  }

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

  Future<void> createKlien() async {
    final response = await http.post(
      Uri.parse(ApiConfig.add_data_client),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nama_perusahaan": namaPerusahaanController.text,
        "nama_klien": namaKlienController.text,
        "alamat": alamatController.text,
        "email": emailController.text,
        "no_tlp": noTelpController.text,
        "fax": faxController.text,
        "no_bank": noBankController.text,
      }),
    );

    if (response.statusCode == 201) {
      print("Data Klien berhasil dibuat!");
      print("Response: ${response.body}");
      setState(() {
        isDataBenar = false; // Set data ke false
        namaPerusahaanController.clear(); // Kosongkan form
        namaKlienController.clear();
        alamatController.clear();
        emailController.clear();
        noTelpController.clear();
        faxController.clear();
        noBankController.clear();
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GiffyDialog.image(
            Image.asset(
              'lib/assets/success-tick-dribbble.gif',
              height: 200,
              fit: BoxFit.cover,
            ),
            title: Text(
              getTranslatedText('Successfully'),
              textAlign: TextAlign.center,
            ),
            content: Text(
              getTranslatedText('Fill in the data again ?'),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Pesanan()));
                    },
                    child: Text(getTranslatedText('No')),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 40),
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(getTranslatedText('Yes')),
                    style: TextButton.styleFrom(
                      minimumSize: Size(100, 40),
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                        side: BorderSide(
                          color: Color(0xFF3DA9FC), // Warna border
                          width: 1.0, // Lebar border
                        ),
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
      print("Gagal membuat data Klien.");
      print("Response: ${response.body}");
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
              getTranslatedText('The data already exists'),
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
                    child: Text(getTranslatedText('Close')),
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

  // Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Client Data':
          return 'Data Klien';
        case 'Company Name':
          return 'Nama Perusahaan';
        case 'Client Name':
          return 'Nama Klien';
        case 'Address':
          return 'Alamat';
        case 'Add':
          return 'Tambahkan';
        case 'Successfully':
          return 'Berhasil';
        case 'Close':
          return 'Tutup';
        case 'Failed':
          return 'Gagal';
        case 'Fill in the data again ?':
          return 'Isi data lagi ?';
        case 'No':
          return 'Tidak';
        case 'The data already exists':
          return 'Data sudah ada';
        case 'Yes':
          return 'Ya';
        case '':
          return '';

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
    final ThemeData themeData =
    isDarkTheme ? ThemeData.dark() : ThemeData.light();
    return MaterialApp(
      color: isDarkTheme ? Colors.black : Colors.white,
      theme: themeData, // Terapkan tema sesuai dengan preferensi tema gelap
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
          ),
          backgroundColor: Colors.transparent, // Mengubah warna AppBar
          elevation: 0, // Menghilangkan efek bayangan di bawah AppBar
          iconTheme: IconThemeData(
              color: isDarkTheme
                  ? Colors.white
                  : Colors
                  .black), // Mengatur ikon (misalnya, tombol back) menjadi hitam
          title: Align(
            alignment: Alignment.center,
            child: Text(
              getTranslatedText("Client Data"),
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
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: namaPerusahaanController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: getTranslatedText('Company Name'),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 1,
                                ),
                                filled: false,
                              ),
                              style: TextStyle(fontSize: 16),
                              // Tambahkan validator sesuai kebutuhan
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Isi Datanya';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: namaKlienController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: getTranslatedText('Client Name'),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 1,
                                ),
                                filled: false,
                              ),
                              style: TextStyle(fontSize: 16),
                              // Tambahkan validator sesuai kebutuhan
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Isi Datanya';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: alamatController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: getTranslatedText('Address'),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 6,
                                ),
                                filled: false,
                              ),
                              style: TextStyle(fontSize: 16),
                              // Tambahkan validator sesuai kebutuhan
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Isi Datanya';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 6,
                                ),
                                filled: false,
                                labelText: getTranslatedText('Email'),
                              ),
                              style: TextStyle(fontSize: 16),
                              // Tambahkan validator sesuai kebutuhan
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Isi Datanya';
                                } else if (!value.contains('@')) {
                                  return 'Email harus mengandung karakter "@"';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: noTelpController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Telp',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 6,
                                      ),
                                      filled: false,
                                    ),
                                    style: TextStyle(fontSize: 16),
                                    // Tambahkan validator sesuai kebutuhan
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Isi Datanya';
                                      } else if (value.length < 10) {
                                        return 'Minimal 10 angka';
                                      } else if (!isNumeric(value)) {
                                        return 'Nomor telepon harus mengandung angka saja';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                    width: 16), // Jarak antara "Telp" dan "Fax"
                                Expanded(
                                  child: TextFormField(
                                    controller: faxController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Fax',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 6,
                                      ),
                                      filled: false,
                                    ),
                                    style: TextStyle(fontSize: 16),
                                    // Tambahkan validator sesuai kebutuhan
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Isi Datanya';
                                      } else if (value.length < 1) {
                                        return 'Minimal 1 angka';
                                      } else if (!isNumeric(value)) {
                                        return 'Harus mengandung angka saja';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: noBankController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'No Bank',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 6,
                                ),
                                filled: false,
                              ),
                              style: TextStyle(fontSize: 16),
                              // Tambahkan validator sesuai kebutuhan
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Isi Datanya';
                                } else if (value.length < 1) {
                                  return 'Minimal 1 angka';
                                } else if (!isNumeric(value)) {
                                  return 'Harus mengandung angka saja';
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 30, left: 160),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    createKlien();
                                  }
                                },
                                child: Text(
                                  getTranslatedText('Add'),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(170, 44),
                                  padding: EdgeInsets.all(0),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
