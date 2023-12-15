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

  Future<void> _signIn() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      if (email.isNotEmpty && password.isNotEmpty) {
        // API call for login using email
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

            // Simpan informasi login ke shared_preferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token', token);
            prefs.setString('nama', name);
            prefs.setString('roles', roles);

            // Pengecekan apakah token dan informasi lainnya telah berhasil disimpan
            String storedToken = prefs.getString('access_token') ?? '';
            String storedName = prefs.getString('nama') ?? '';
            String storedRoles = prefs.getString('roles') ?? '';

            print('Token: $storedToken');
            print('Nama: $storedName');
            print('Roles: $storedRoles');

            // Handle navigasi sesuai dengan roles
            navigateBasedOnRoles(roles);
          } else {
            // Handle kasus ketika data null
            print('Error: Response data is null');
          }
        } else {
          // Handle kasus status code selain 200
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed. Check your email and password.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email and password must be filled.'),
          ),
        );
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Check your email and password.'),
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
                Color(0xFF9766FF),
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
                              'Welcome',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                              child: Text(
                                'Fill out the information below to access your account.',
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
                                    labelText: 'Password',
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
                                child: Text('Sign In'),
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
