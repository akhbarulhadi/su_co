import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:suco/kepala_produksi/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suco/supervisor/kalender.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class DashboardPageLeaderProduction extends StatefulWidget {
  const DashboardPageLeaderProduction({Key? key}) : super(key: key);

  @override
  DashboardPageLeaderProductionState createState() => DashboardPageLeaderProductionState();
}

class DashboardPageLeaderProductionState extends State<DashboardPageLeaderProduction> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List<Map<String, dynamic>> produksiData = [];
  List<bool> isItemClicked = [];
    bool _isloading = true;

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    loadProduksi();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(dateTime);
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

  Future<void> loadProduksi() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.get_production_leader_dashboard));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Add this to see the response data in the console
        setState(() {
          produksiData = List.from(data['produksi']);
          isItemClicked = List.generate(produksiData.length, (index) => false);

          produksiData.forEach((item) {
            item['tanggal_produksi'] = _formatDate(item['tanggal_produksi']);
          });
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateStatus(
      BuildContext context, int idProduksi, String newStatus, int index) async {
    if (mounted) {
      // Check the previous status, must be "Sudah Dibuat" to change to "Sudah Sesuai"
      if (newStatus.toLowerCase() == 'sudah dibuat') {
        if (produksiData[index]['status_produksi'] != 'belum selesai') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Status must be "belum selesai" to change to "Sudah Dibuat".'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      final response = await http.post(
        Uri.parse(ApiConfig.status),
        body: {
          'id_produksi': idProduksi.toString(),
          'status_produksi': newStatus.toLowerCase(),
        },
      );

      if (response.statusCode == 200 && mounted) {
        Navigator.of(context).pop();
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
        // Update production data after successfully updating the status
        await loadProduksi();
        setState(() {
          isItemClicked[index] = true; // Set the item as clicked
          // Add necessary state updates after updating data
        });
      } else if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return GiffyDialog.image(
              Image.asset('lib/assets/failed.gif',
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
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, int idProduksi, String newStatus, int index) async {
    if (mounted) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          bool canUpdateStatus = !isItemClicked[index];
          return AlertDialog(
            title: Text(getTranslatedText('Confirmation')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(getTranslatedText(
                      'Are you sure you want to change the production status?')),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(getTranslatedText('Yes')),
                onPressed: () async {
                  if (canUpdateStatus) {
                    await _updateStatus(context, idProduksi, newStatus, index);
                  }
                },
              ),
              TextButton(
                child: Text(getTranslatedText('Cancle')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
        case 'Main Page':
          return 'Halaman Utama';
        case 'All':
          return 'Semua';
        case 'Daily':
          return 'Harian';
        case 'Weekly':
          return 'Mingguan';
        case 'Monthly':
          return 'Bulanan';
        case 'Yearly':
          return 'Tahunan';
        case 'Income':
          return 'Pemasukan';
        case 'Client Order List':
          return 'Daftar Pesanan Klien';
        case 'See Detail':
          return 'Lihat Detail';
        case 'Available Items':
          return 'Ketersediaan Barang';
        case 'Order History':
          return 'Riwayat Pesanan';
        case 'Completed on':
          return 'Selesai pada';
        case 'Change Status':
          return 'Ubah Status';
        case 'Finished':
          return 'Selesai';
        case 'Waiting':
          return 'Menunggu';
        case 'Edit':
          return 'Ubah';
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

  String getTranslatedDatabase(String status) {
    if (selectedLanguage == 'ENG') {
      // Teks dalam bahasa Indonesia
      switch (status) {
        case 'Selesai':
          return 'Finished';
        case 'Menunggu':
          return 'Waiting';
        case 'Siap Diantar':
          return 'Ready Delivered';
        case '':
          return '';
        case '':
          return '';
      // Tambahkan kases lain jika diperlukan
        default:
          return status;
      }
    } else {
      // Teks dalam bahasa Inggris (default)
      return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData =
    isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    final myAppBar = AppBar(
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
          getTranslatedText('Main Page'),
          style: TextStyle(
            fontSize: 25.0,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
      ),
      actions: <Widget>[
        SizedBox(
          width: 45.0,
        ),
      ],
    );
    final bodyHeight = mediaQueryHeight -
        myAppBar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    return MaterialApp(
      color: isDarkTheme ? Colors.black : Colors.white,
      theme: themeData, // Terapkan tema sesuai dengan preferensi tema gelap
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        drawer: SidebarDrawer(),
        appBar: myAppBar,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: bodyHeight * 0.01),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFC3DCED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslatedText('Activity'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize:
                            screenWidth * 0.05, // Ukuran teks pada tombol
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: bodyHeight * 0.01),
                        produksiData.isEmpty
                                ? Center(
                                    child: Text(
                                        getTranslatedText('No Production')),
                                  )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics:
                          NeverScrollableScrollPhysics(),
                          itemCount: produksiData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = produksiData[index];
                            return buildProductionItem(item, screenWidth, index);
                          },
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
    );
  }

  Widget buildProductionItem(Map<String, dynamic> item, double screenWidth, int index) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    if (item == null) {
      print('Error: Item is null');
      return Container();
    }

    print('Item: $item');
    return GestureDetector(
      onTap: () {
        if (!isItemClicked[index]) {
          if (item['status_produksi'].toLowerCase() == 'belum selesai') {
            print('Tapped index: $index');
            _showConfirmationDialog(
                context, item['id_produksi'], 'Sudah Dibuat', index);
          } else {
            print('Item sudah diklik dan status sudah sesuai');
          }
        } else {
          print('Item sudah diklik dan status sudah sesuai');
        }
      },
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: Color(0xFF094067),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 10, 16, 5),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          item['nama_produk'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFFFFFFFE),
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          item['tanggal_produksi'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFFFFFFFE),
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          item['kode_produksi'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFFFFFFFE),
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mediaQueryHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Icon(
                          Icons.pin_drop,
                          color: Color(0xFFFFFFFE),
                          size: 16,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          item['nama_ruangan'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFFFFFFFE),
                            fontSize: screenWidth * 0.025,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Container(
                          width: mediaQueryWidth * 0.04,
                          height: mediaQueryHeight * 0.04,
                          child: Image(
                            image: AssetImage('lib/assets/user.png'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: mediaQueryWidth * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          item['nama_user'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFFFFFFFE),
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          item['status_produksi'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFFFFFFFE),
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          item['jumlah_produksi'].toString(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFFFFFFFE),
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mediaQueryHeight * 0.01),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
