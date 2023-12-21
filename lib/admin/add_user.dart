import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/admin/man_user.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:giffy_dialog/giffy_dialog.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => AddUserState();
}

class AddUserState extends State<AddUser> {
  bool isDarkTheme = false;
  bool isSubmitPressed = false;
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
  bool isDataBenar = false;
  bool isNumeric(String value) {
    return int.tryParse(value) != null;
  }

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
        case 'User Name':
          return 'Nama Pengguna';
        case 'Address':
          return 'Alamat';
        case 'No Telephone':
          return 'No Telepon';
        case 'Man':
          return 'Laki-laki';
        case 'Women':
          return 'Perempuan';
        case 'Add':
          return 'Tambah';
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
      return text;
    }
  }

  Future<void> AddUser() async {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'id_staff': idStaffController.text,
        'password': idStaffController.text,
        'nama': namaController.text,
        'jenis_kelamin': jenis_kelaminController.text,
        'alamat': alamatController.text,
        'no_tlp': no_tlpController.text,
        'email': emailController.text,
        'status': 'aktif.',
        'roles': rolesController.text,
      }),
    );

    if (response.statusCode == 201) {
      print("User berhasil dibuat!");
      setState(() {
        isDataBenar = false; // Set data ke false
        emailController.clear(); // Kosongkan form
        namaController.clear();
        alamatController.clear();
        no_tlpController.clear();
        idStaffController.clear();
        jenis_kelaminController.clear();
        rolesController.clear();
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
                      Navigator.pop(context); // Close the current dialog
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserManagementPage()));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserManagementPage()));
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
      print("Gagal membuat user.");
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
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            filled: false,
                            labelText: getTranslatedText('Email'),
                          ),
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
                        TextFormField(
                          controller: namaController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            filled: false,
                            labelText: getTranslatedText('User Name'),
                          ),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            filled: false,
                            labelText: getTranslatedText('Address'),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Isi Datanya';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: no_tlpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            filled: false,
                            labelText: getTranslatedText('No Telephone'),
                          ),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Isi Datanya';
                            }
                            return null;
                          },
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'Laki-laki',
                              groupValue: jenis_kelaminController.text,
                              onChanged: (String? value) {
                                setState(() {
                                  jenis_kelaminController.text = value!;
                                });
                              },
                            ),
                            Text(getTranslatedText('Man')),
                            Radio(
                              value: 'Perempuan',
                              groupValue: jenis_kelaminController.text,
                              onChanged: (String? value) {
                                setState(() {
                                  jenis_kelaminController.text = value!;
                                });
                              },
                            ),
                            Text(getTranslatedText('Women')),
                          ],
                        ),
                        // Validasi Radio Buttons
                        if (isSubmitPressed &&
                            (jenis_kelaminController.text == null ||
                                jenis_kelaminController.text.isEmpty))
                          Padding(
                            padding: const EdgeInsets.only(left: 13.0),
                            child: Text(
                              'Pilih jenis kelamin',
                              style: TextStyle(color: Colors.red, fontSize: 12),
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
                            setState(() {
                              rolesController.text = newValue!;
                            });
                          },
                        ),
                        // Validasi Dropdown
                        if (isSubmitPressed &&
                            (rolesController.text == null ||
                                rolesController.text!.isEmpty))
                          Padding(
                            padding: const EdgeInsets.only(left: 14.0),
                            child: Text(
                              'Pilih role',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        SizedBox(height: 16.0),
                        Padding(
                          padding: EdgeInsets.only(top: 30, left: 160),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isSubmitPressed = true;
                              });
                              if (_formKey.currentState!.validate()) {
                                AddUser();
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
