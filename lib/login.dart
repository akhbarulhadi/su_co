import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/marketing/dashboard.dart';
import 'package:suco/supervisor/dashboard.dart';
import 'package:suco/kepala_produksi/dashboard.dart';
import 'package:suco/staff_gudang/dashboard.dart';
import 'package:suco/kepala_gudang/dashboard.dart';
import 'package:suco/admin/man_user.dart';
import 'package:suco/role_middleware.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String selectedLanguage = 'IDN';
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _passwordVisibility = true;
  bool isDataBenar = false;
  bool isNumeric(String value) {
    return int.tryParse(value) != null;
  }
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

 Future<void> _signIn() async {
  try {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        setState(() {
          isDataBenar = false; // Set data ke false
          _emailController.clear();
          _passwordController.clear();
        });
        if (data != null) {
          final String roles = data['roles'] ?? '';
          final String token = data['access_token'] ?? '';
          final String name = data['user']?['nama'] ?? '';
          final String userStatus = data['user']?['status'] ?? '';
          final int id_user = data['user']?['id_user'] ?? 0;

          if (userStatus == 'aktif.') {
            // Simpan informasi login ke shared_preferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token', token);
            prefs.setString('nama', name);
            prefs.setInt('id_user', id_user);
            prefs.setString('roles', roles);

            // Pengecekan apakah token dan informasi lainnya telah berhasil disimpan
            String storedToken = prefs.getString('access_token') ?? '';
            String storedName = prefs.getString('nama') ?? '';
            String storedIdUser = prefs.getInt('id_user').toString() ?? '';
            String storedRoles = prefs.getString('roles') ?? '';

            print('Token: $storedToken');
            print('Nama: $storedName');
            print('id_user: $storedIdUser');
            print('Roles: $storedRoles');

            // Handle navigasi sesuai dengan roles
            navigateBasedOnRoles(roles);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(getTranslatedText('Inactive account. Please contact support.')),
              ),
            );
          }
        } else {
          print('Error: Response data is null');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getTranslatedText('Invalid credentials or inactive account.')),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getTranslatedText('Email and password must be filled.')),
        ),
      );
    }
  } catch (e) {
    print("Login error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getTranslatedText('Login failed. Check your email and password.')),
      ),
    );
  }
}


    void navigateBasedOnRoles(String roles) {
        RoleMiddleware roleMiddleware = RoleMiddleware(allowedRoles: [
            'admin',
            'marketing',
            'supervisor',
            'leader',
            'staff_gudang',
            'kepala_gudang'
          ]);
          roleMiddleware.handle(context, roles);

          // Check the user's role and navigate accordingly
          switch (roles) {
            case 'admin':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManagementPage()),
              );
              break;
            case 'marketing':
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardPageMarketing()),
              );
              break;
            case 'supervisor':
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardPageSupervisor()),
              );
              break;
            case 'leader':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPageLeaderProduction()),
              );
              break;
            case 'staff_gudang':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPageStaff()),
              );
              break;
            case 'kepala_gudang':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPageLeaderWarehouse()),
              );
              break;
          }
    }

  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Welcome':
          return 'Selamat Datang';
        case 'Fill out the information below to access your account.':
          return 'Isi informasi di bawah ini untuk mengakses akun Anda.';
        case 'Sign In':
          return 'Masuk';
        case 'Password':
          return 'Kata Sandi';
        case 'Inactive account. Please contact support.':
          return 'Akun tidak aktif. Silakan hubungi dukungan.';
        case 'Invalid credentials or inactive account.':
          return 'Kredensial tidak valid atau akun tidak aktif.';
        case 'Email and password must be filled.':
          return 'Email dan kata sandi harus diisi.';
        case 'Login failed. Check your email and password.':
          return 'Gagal masuk. Periksa email dan kata sandi Anda.';
        case 'Select Language':
          return 'Pilih Bahasa';
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF094067),
                Colors.white,
              ],
              stops: [0, 1],
              begin: AlignmentDirectional(0.87, -1),
              end: AlignmentDirectional(-0.87, 1),
            ),
          ),
          alignment: AlignmentDirectional(0.00, -1.00),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ListTile(
                //   title: Text(
                //     getTranslatedText(''),
                //     style: TextStyle(
                //       fontFamily: 'Outfit',
                //       fontSize: 16,
                //     ),
                //   ),
                //   contentPadding: EdgeInsets.fromLTRB(24, 1, 24, 1),
                //   trailing: InkWell(
                //     onTap: () {
                //       showLanguageDialog(); // Tampilkan dialog pilihan bahasa
                //     },
                //     child: Container(
                //       width: 76,
                //       height: 22,
                //       decoration: ShapeDecoration(
                //         color: Color(0xFFF5F5F5),
                //         shape: RoundedRectangleBorder(
                //           side: BorderSide(width: 1, color: Color(0x443C3C3C)),
                //         ),
                //       ),
                //       child: Text(
                //         selectedLanguage == 'IDN' ? 'Bahasa' : 'English',
                //         textAlign: TextAlign.center,
                //         style: TextStyle(
                //           color: Color(0xFF999999),
                //           fontSize: 14,
                //           fontFamily: 'Lato',
                //           fontWeight: FontWeight.w700,
                //           height: 0,
                //         ),
                //       ),
                //     ),
                //   ),
                //   dense: false,
                // ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 70, 0, 32),
                  child: Container(
                    width: 200,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: AlignmentDirectional(0.00, 0.00),
                    child: Text(
                      'SUCO',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: 570,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x33000000),
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0.00, 0.00),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(32, 32, 32, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getTranslatedText('Welcome'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                              child: Text(
                                getTranslatedText('Fill out the information below to access your account.'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _emailController,
                                  autofocus: true,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _passwordController,
                                  autofocus: true,
                                  obscureText: _passwordVisibility,
                                  decoration: InputDecoration(
                                    labelText: getTranslatedText('Password'),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: InkWell(
                                      onTap: () => setState(
                                            () => _passwordVisibility =
                                        !_passwordVisibility,
                                      ),
                                      child: Icon(
                                        _passwordVisibility
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: ElevatedButton(
                                onPressed: _signIn,
                                child: Text(getTranslatedText('Sign In')),
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
