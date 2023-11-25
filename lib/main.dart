import 'package:flutter/material.dart';
import 'package:suco/admin/man_user.dart';
import 'package:suco/kepala_gudang/dashboard.dart';
import 'package:suco/kepala_produksi/dashboard.dart';
import 'package:suco/login.dart';
import 'package:suco/marketing/dashboard.dart';
import 'package:suco/staff_gudang/dashboard.dart';
import 'package:suco/supervisor/dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login_Register_4342211023',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('lib/assets/icon_suco.png'),
            SizedBox(
              height: 40,
            ),
            Text(
              "Welcome to SuCo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Control supplies more efficiently and",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              "optimize supplies",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
              child: Text(
                "Log in",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
            MaterialButton(
              child: Text(
                "Marketing",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPageMarketing()),
                );
              },
            ),
            MaterialButton(
              child: Text(
                "Supervisor",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPageSupervisor()),
                );
              },
            ),
            MaterialButton(
              child: Text(
                "Leader",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPageLeaderProduction()),
                );
              },
            ),
            MaterialButton(
              child: Text(
                "Kepala Gudang",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPageLeaderWarehouse()),
                );
              },
            ),
            MaterialButton(
              child: Text(
                "Staff Gudang",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPageStaff()),
                );
              },
            ),
            MaterialButton(
              child: Text(
                "Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserManagementPage()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
