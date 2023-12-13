import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:suco/staff_gudang/sidebar.dart';
import 'package:suco/staff_gudang/stock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:convert';

class TableEventsExample extends StatefulWidget {
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
  List<Map<String, dynamic>> produksiData = [];
  late TextEditingController _textController;
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    loadThemePreference();
    loadSelectedLanguage();
    loadProduksi();
    _textController = TextEditingController();
    bool _isloading = true;
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
          _isloading = false;
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
              onPressed: () async {
                Navigator.of(context).pop();
                await _addStock(idProduk, jumlahProduksi);
              },
              child: Text('Ya, Tambahkan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addStock(int idProduk, int jumlahProduksi) async {
    try {
      var request =
          http.Request('POST', Uri.parse(ApiConfig.tambah_jumlah_produk));
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
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
        appBar: myAppBar,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: mediaQueryWidth * 0.25,
                    height: bodyHeight * 0.048,
                    decoration: BoxDecoration(
                      color: isDarkTheme ? Colors.white24 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownSearch<String>(
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
                        getTranslatedText('All'),
                        getTranslatedText('Daily'),
                        getTranslatedText('Weekly'),
                        getTranslatedText('Monthly'),
                        getTranslatedText('Yearly'),
                      ],
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          labelText: getTranslatedText("Time Period"),
                          // hintText: "waktu in menu mode",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                      onChanged: print,
                      selectedItem: getTranslatedText("All"),
                    ),
                  ),
                  Container(
                    width: mediaQueryWidth * 0.4,
                    height: bodyHeight * 0.048,
                    decoration: BoxDecoration(
                      color: isDarkTheme ? Colors.white24 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkTheme ? Colors.white38 : Colors.black38,
                        width: 1, // Lebar garis tepi
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.search_rounded,
                              color: isDarkTheme
                                  ? Colors.white
                                  : Color(
                                      0xFF8B9BA8), // Ganti dengan warna yang sesuai
                              size: 15,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: TextFormField(
                                controller: _textController,
                                obscureText: false,
                                decoration: InputDecoration(
                                  hintText: getTranslatedText('Search...'),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4.0),
                                      topRight: Radius.circular(4.0),
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4.0),
                                      topRight: Radius.circular(4.0),
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  fontFamily: 'Clash Display',
                                  color:
                                      isDarkTheme ? Colors.white : Colors.black,
                                  fontSize: screenWidth *
                                      0.035, // Ukuran teks pada tombol
                                  fontWeight: FontWeight.normal,
                                ),
                                validator: (value) {
                                  // Validasi teks input
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: mediaQueryWidth * 0.25,
                    height: bodyHeight * 0.048,
                    decoration: BoxDecoration(
                      color: isDarkTheme ? Colors.white24 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.transparent, // Warna garis tepi
                        width: 0.5, // Lebar garis tepi
                      ),
                    ),
                    child: DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        fit: FlexFit.loose,
                        menuProps: MenuProps(
                          backgroundColor:
                              isDarkTheme ? Colors.black : Colors.white,
                          elevation: 0,
                        ),
                        showSelectedItems: true,
                        disabledItemFn: (String s) =>
                            s.startsWith(getTranslatedText('Finished')),
                      ),
                      items: [
                        getTranslatedText("All"),
                        getTranslatedText("Cancelled"),
                        getTranslatedText("Finished"),
                        getTranslatedText('Waiting'),
                      ],
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          labelText: getTranslatedText("Select Status"),
                          // hintText: "status in menu mode",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                      onChanged: print,
                      selectedItem: getTranslatedText("All"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: bodyHeight * 0.03),
            Expanded(
              child: _isloading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: produksiData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = produksiData[index];
                        return buildProductionItem(item, screenWidth);
                      },
                    ),
            ),
          ],
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
