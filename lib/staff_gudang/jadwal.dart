import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:suco/staff_gudang/sidebar.dart';
import 'package:suco/staff_gudang/stock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class TableEventsExample extends StatefulWidget {
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
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
        print(data);
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

  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      switch (text) {
        case 'Schedule':
          return 'Jadwal';
        case 'Activity':
          return 'Aktivitas';
        default:
          return text;
      }
    } else {
      return text;
    }
  }

void _showConfirmationDialog(int idProduk, int jumlahProduksi) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Anda yakin ingin menambahkan stok?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _addStock(idProduk, jumlahProduksi);
            },
            child: Text('Ya, Tambahkan'),
          ),
        ],
      );
    },
  );
}

Future<void> _addStock(int idProduk, int jumlahProduksi) async {
  try {
    var request = http.Request('POST', Uri.parse(ApiConfig.tambah_jumlah_produk));
    request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    request.body = 'id_produk=$idProduk&jumlah_produk=$jumlahProduksi';

    var response = await http.Client().send(request);

    // Read the response stream and convert it to a String
    var responseBody = await response.stream.bytesToString();

    // Handle the initial response
    if (response.statusCode == 302) {
      // If it's a redirect, handle it manually
      var redirectedUrl = response.headers['location'];
      if (redirectedUrl != null) {
        var redirectedResponse = await http.get(Uri.parse(redirectedUrl));
        
        // Handle the response after the redirect
        if (redirectedResponse.statusCode == 200) {
          print('Stok berhasil ditambahkan!');
        } else {
          print('Error setelah redirect: ${redirectedResponse.statusCode}');
          print('Respon: ${redirectedResponse.body}');
        }
      } else {
        print('Error: Redirected URL tidak diberikan');
      }
    } else if (response.statusCode == 200) {
      print('Stok berhasil ditambahkan!');
    } else {
      print('Error: ${response.statusCode}');
      print('Respon: $responseBody');
    }
  } catch (e) {
    print('Error: $e');
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
          getTranslatedText('Schedule'),
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

                        // Added ListView.builder to display production data
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: produksiData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = produksiData[index];
                            return buildProductionItem(item, screenWidth);
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

  Widget buildProductionItem(Map<String, dynamic> item, double screenWidth) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    if (item == null) {
      print('Error: Item is null');
      return Container();
    }

    print('Item: $item');
    return InkWell(
      onTap: () {
         _showConfirmationDialog(item['id_produk'], item['jumlah_produksi']);
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

