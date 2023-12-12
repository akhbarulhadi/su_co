import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:suco/kepala_produksi/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPageLeaderProduction extends StatefulWidget {
  const DashboardPageLeaderProduction({Key? key}) : super(key: key);

  @override
  _Dashboard1WidgetState createState() => _Dashboard1WidgetState();
}

class _Dashboard1WidgetState extends State<DashboardPageLeaderProduction> {
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
   bool _isDisposed = false;
     String currentStatus = 'belum selesai';
  List<Map<String, dynamic>> produksiData = [];

  @override
  void initState() {
    super.initState();
    loadThemePreference();
    loadSelectedLanguage();
    loadProduksi();
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
      final response = await http.get(Uri.parse(ApiConfig.jadwal_produksi));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Tambahkan ini untuk melihat respons data di konsol
        setState(() {
          produksiData = List.from(data['produksi']);
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
    BuildContext context, int idProduksi, String newStatus) async {
  if (mounted) {
    // Add a check to prevent updating to "Sudah Dibuat" if already in that state
    if (newStatus == 'sudah dibuat') {
      // Periksa status sebelumnya, harus "Belum Selesai" untuk diubah menjadi "Sudah Dibuat"
      if (currentStatus != 'belum selesai') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status harus "Belum Selesai" untuk diubah menjadi "Sudah Dibuat".'),
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
        'status_produksi': newStatus,
      },
    );

    if (!_isDisposed && response.statusCode == 200 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diperbarui'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Perbarui data produksi setelah berhasil memperbarui status
      await loadProduksi();
      setState(() {
        // Tambahkan pembaruan state yang diperlukan setelah memperbarui data
      });
    } else if (!_isDisposed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
Future<void> _showConfirmationDialog(
    BuildContext context, int idProduksi, String newStatus) async {
  if (mounted) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (!_isDisposed) {
          return AlertDialog(
            title: Text('Konfirmasi'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Apakah Anda yakin ingin mengubah status produksi ini?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Ya'),
                onPressed: () async {
                  if (!_isDisposed) {
                    await _updateStatus(context, idProduksi, newStatus);
                    Navigator.of(context).pop();
                  }
                },
              ),
              TextButton(
                child: Text('Batal'),
                onPressed: () {
                  if (!_isDisposed) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        } else {
          return Offstage();
        }
      },
    );
  }
}


  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
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
        case 'Activity':
          return 'Kegiatan';
        default:
          return text;
      }
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    final ThemeData themeData =
        isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final myAppBar = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: isDarkTheme ? Colors.white : Colors.black,
      ),
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
      theme: themeData,
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        drawer: SidebarDrawer(),
        appBar: myAppBar,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: bodyHeight * 0.03),
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
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: bodyHeight * 0.01),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: produksiData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = produksiData[index];
                            return GestureDetector(
                              onTap: () {
                                print('Tapped index: $index');
                                _showConfirmationDialog(
                                    context, index, 'Sudah Dibuat');
                              },
                              child:
                                  buildProductionItem(item, screenWidth, index),
                            );
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

  Widget buildProductionItem(
      Map<String, dynamic> item, double screenWidth, int index) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    if (item == null) {
      print('Error: Item is null');
      return Container();
    }

    print('Item: $item');

    return GestureDetector(
      onTap: () {
        if (index >= 0 && index < produksiData.length) {
          _showConfirmationDialog(
              context, produksiData[index]['id_produksi'], 'Sudah Dibuat');
        } else {
          print('Error: Invalid index');
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
                        SizedBox(
                        width: mediaQueryWidth * 0.02,
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
