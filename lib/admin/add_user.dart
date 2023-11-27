import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/admin/man_user.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => AddUserState();
}

class AddUserState extends State<AddUser> {
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
  final _formKey = GlobalKey<FormState>();
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
    final response = await http.post(
    Uri.parse(ApiConfig.register),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'id_staff': idStaffController.text,
        'password': passwordController.text,
        'nama': namaController.text,
        'jenis_kelamin': jenis_kelaminController.text,
        'alamat': alamatController.text,
        'no_tlp': no_tlpController.text,
        'email': emailController.text,
        'status': statusController.text,
        'roles': rolesController.text,
      }),
    );

    if (response.statusCode == 201) {
      print("User berhasil dibuat!");
      print("Response: ${response.body}");
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserManagementPage()));
    } else {
      print("Gagal membuat user.");
      print("Response: ${response.body}");
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
                  child: Form(
                    key: _formKey,
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
                          onChanged: (String? newValue) {
                            // Handle dropdown value change
                            rolesController.text = newValue!;
                          },
                        ),
                        SizedBox(height: 16.0),
                       Padding(
                              padding: EdgeInsets.only(top: 30, left: 160),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    AddUser();
                                  }
                                },
                                child: Text(
                                  getTranslatedText('Continue'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
