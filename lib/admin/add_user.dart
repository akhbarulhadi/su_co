import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/admin/man_user.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => AddUserState();
}

class AddUserState extends State<AddUser> {
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
  TextEditingController idStaffController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController jenis_kelaminController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController no_tlpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController rolesController = TextEditingController();
  bool _obscureText = true;

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
        case 'Add User':
          return 'Tambah Pengguna';
        case 'User Name':
          return 'Nama Pengguna';
        case 'Id Staff':
          return 'Id Staff';
        case 'User Type':
          return 'Tipe Pengguna';
        case 'Add':
          return 'Tambah';
        case 'Password':
          return 'Kata Sandi';
        case '':
          return '';
        case '':
          return '';
        default:
          return text;
      }
    } else {
      return text;
    }
  }

  Future<void> AddUser() async {
    try {
      final idStaff = idStaffController.text;
      final password = passwordController.text;
      final nama = namaController.text;
      final jenisKelamin = jenis_kelaminController.text;
      final alamat = alamatController.text;
      final noTlp = no_tlpController.text;
      final email = emailController.text;
      final status = statusController.text;
      final roles = rolesController.text;

      // Menggunakan package http untuk melakukan POST request ke API Laravel
      final response = await http.post(
        Uri.parse('http://192.168.100.8:8000/api/register'),
        body: {
          'id_staff': idStaff,
          'password': password,
          'nama': nama,
          'jenis_kelamin': jenisKelamin,
          'alamat': alamat,
          'no_tlp': noTlp,
          'email': email,
          'status': status,
          'roles': roles,
        },
      );

      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 302) {
        if (response.headers.containsKey('location')) {
          // Ada redirect, periksa URL tujuan
          final redirectUrl = response.headers['location']!;
          print('Redirected to: $redirectUrl');
          // Handle redirect sesuai kebutuhan
        } else {
          // Pengguna berhasil ditambahkan
          print('Pengguna berhasil ditambahkan');
        }
      } else {
        // Gagal menambahkan pengguna, tampilkan pesan kesalahan
        print('Gagal menambahkan pengguna: ${response.statusCode}');
        print('Detail Pesan: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Terjadi kesalahan: $e');
      print('StackTrace: $stackTrace');
      // Handle kesalahan lain yang mungkin muncul.
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
              getTranslatedText("Add User"),
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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          filled: false,
                          labelText: getTranslatedText('Email'),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          filled: false,
                          labelText: getTranslatedText('Password'),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: namaController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          filled: false,
                          labelText: getTranslatedText('Nama Lengkap'),
                        ),
                      ),
                      Row(
                        children: [
                          Radio(
                            value: getTranslatedText('Laki-laki'),
                            groupValue: jenis_kelaminController.text,
                            onChanged: (String? value) {
                              setState(() {
                                jenis_kelaminController.text = value!;
                              });
                            },
                          ),
                          Text(getTranslatedText('Laki-laki')),
                          Radio(
                            value: getTranslatedText('Perempuan'),
                            groupValue: jenis_kelaminController.text,
                            onChanged: (String? value) {
                              setState(() {
                                jenis_kelaminController.text = value!;
                              });
                            },
                          ),
                          Text(getTranslatedText('Perempuan')),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: alamatController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          filled: false,
                          labelText: getTranslatedText('Alamat '),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: no_tlpController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          filled: false,
                          labelText: getTranslatedText('No Telepon'),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: idStaffController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          filled: false,
                          labelText: getTranslatedText('Id Staff'),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: statusController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          filled: false,
                          labelText: getTranslatedText('Status'),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      DropdownSearch<String>(
                        popupProps: PopupProps.menu(
                          fit: FlexFit.loose,
                          menuProps: MenuProps(
                            backgroundColor:
                                isDarkTheme ? Colors.black : Colors.white,
                            elevation: 0,
                          ),
                          showSelectedItems: true,
                        ),
                        items: [
                          getTranslatedText('marketing'),
                          getTranslatedText('supervisor'),
                          getTranslatedText('leader'),
                          getTranslatedText('staff_gudang'),
                          getTranslatedText('kepala_gudang'),
                        ],
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            labelText: getTranslatedText('User Type'),
                          ),
                        ),
                        onChanged: print,
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: EdgeInsets.fromLTRB(60, 30, 60, 20),
                        child: ElevatedButton(
                          onPressed: () {
                            // Panggil fungsi AddUser untuk menambahkan pengguna
                            AddUser();

                            // Setelah berhasil menambahkan pengguna, Anda bisa navigasi atau melakukan tindakan lainnya
                            // Contoh navigasi ke halaman DataPesanan:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserManagementPage()),
                            );
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            primary: Color(0xFF3DA9FC),
                          ),
                        ),
                      ),
                    ],
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
