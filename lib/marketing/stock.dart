import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class Stock extends StatefulWidget {
  const Stock({Key? key}) : super(key: key);

  @override
  StockState createState() => StockState();
}

class StockState extends State<Stock> {
  late TextEditingController _textController;
  late FocusNode _unfocusNode;
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List _listdata = [];
  bool _isloading = true;
  List _filteredData = [];

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _textController = TextEditingController();
    _unfocusNode = FocusNode();
    _listdata = [];
    _filteredData = [];
    _getdata();
    super.initState();
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

  @override
  void dispose() {
    _textController.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }

  Future<void> _updatePrice(BuildContext context, int index, String newStatus) async {
    final response = await http.post(
     Uri.parse(ApiConfig.update_harga),
      body: {'id_produk': _listdata[index]['id_produk'].toString(), 'harga_produk': newStatus},
    );

    if (response.statusCode == 200) {
      // Status berhasil diperbarui
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diperbarui'),
          duration: Duration(seconds: 2),
        ),
      );

      // Perbarui harga langsung dalam _filteredData
      setState(() {
        _filteredData[index]['harga_produk'] = newStatus;
      });
      Navigator.pop(context);

    } else {
      // Gagal memperbarui status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future _getdata() async {
    try {
      final response = await http.get( Uri.parse(ApiConfig.stock));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listdata = data['stock'];
          _filteredData = _listdata; // Initially, filtered data is the same as the complete data
          _isloading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

// Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Available Items':
          return 'Ketersediaan Barang';
        case 'Search...':
          return 'Cari...';
        case 'Product Name':
          return 'Nama Produk';
        case 'Stock':
          return 'Tersedia';
        case 'Price':
          return 'Harga';
        case 'Time Period':
          return 'Jangka Waktu';
        case 'Search...':
          return 'Cari...';
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
        case 'Change Price':
          return 'Ubah Harga';
        case 'Save':
          return 'Simpan';
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
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final ThemeData themeData =
        isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final screenWidth = MediaQuery.of(context).size.width;
    final myAppBar = AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          FocusScope.of(context).unfocus(); // Menutup keyboard
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        },
      ),
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
          getTranslatedText("Available Items"),
          style: TextStyle(
            fontSize: screenWidth * 0.05, // Ukuran teks pada tombol
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
    return GestureDetector(
      onTap: () {
        if (_unfocusNode.canRequestFocus) {
          FocusScope.of(context).requestFocus(_unfocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      child: MaterialApp(
        color: isDarkTheme ? Colors.black : Colors.white,
        theme: themeData, // Terapkan tema sesuai dengan preferensi tema gelap
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
                      width: mediaQueryWidth * 0.9,
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
                                    : Color(0xFF8B9BA8),
                                size: 15,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: TextFormField(
                                  controller: _textController,
                                  onChanged: (query) {
                                    setState(() {
                                      _filteredData = _listdata.where((item) {
                                        // Customize this condition based on your search criteria
                                        return item['nama_produk']
                                            .toLowerCase()
                                            .contains(query.toLowerCase()) ||
                                            item['harga_produk']
                                                .toLowerCase()
                                                .contains(query.toLowerCase());
                                      }).toList();
                                    });
                                  },
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
                                    suffixIcon: null,
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Clash Display',
                                    color: isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
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
                  ],
                ),
              ),
              Expanded(
                child: _isloading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _filteredData.isEmpty
                    ? Center(
                  child: Text(getTranslatedText('No Stock')),
                )
                    : ListView.builder(
                        itemCount: _filteredData.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Menampilkan form edit harga saat Card ditekan
                              showDialog(
                                context: context,
                                builder: (context) {
                                  TextEditingController priceController =
                                      TextEditingController(
                                          text: _filteredData[index]['harga_produk']);

                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Ganti nilai sesuai keinginan Anda
                                    ),
                                    title: Center(
                                        child: Text(
                                            getTranslatedText('Change Price'))),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: priceController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              labelText:
                                                  getTranslatedText('Price')),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      Center(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Color(0xFF3DA9FC), // Ganti warna sesuai keinginan Anda
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  8), // Ganti nilai sesuai keinginan Anda
                                            ),
                                          ),
                                          onPressed: () async {
                                            await _updatePrice(context, index, priceController.text);
                                          },
                                          child: Text(
                                            getTranslatedText('Save'),
                                            style: TextStyle(
                                                color: Colors
                                                    .white), // Warna teks tombol
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              color: Color(0xFF094067), // warna latar Card
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16, 12, 16, 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 4, 0, 0),
                                              child: Text(
                                                getTranslatedText(
                                                    'Product Name'),
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFFFFFFFE),
                                                  fontSize: screenWidth *
                                                      0.04, // Ukuran teks pada tombol
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 4, 0, 0),
                                              child: Text(
                                                _filteredData[index]['nama_produk'],
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFFFFFFFE),
                                                  fontSize: screenWidth *
                                                      0.04, // Ukuran teks pada tombol
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: bodyHeight * 0.02),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 4, 0, 0),
                                              child: Text(
                                                getTranslatedText('Stock'),
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFFFFFFFE),
                                                  fontSize: screenWidth *
                                                      0.04, // Ukuran teks pada tombol
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 4, 0, 0),
                                              child: Text(
                                                _filteredData[index]['jumlah_produk'].toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFFFFFFFE),
                                                  fontSize: screenWidth *
                                                      0.04, // Ukuran teks pada tombol
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: bodyHeight * 0.02),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 4, 0, 0),
                                              child: Text(
                                                getTranslatedText('Price'),
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFFFFFFFE),
                                                  fontSize: screenWidth *
                                                      0.04, // Ukuran teks pada tombol
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 4, 0, 0),
                                              child: Text(
                                                _filteredData[index]['harga_produk'],
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFFFFFFFE),
                                                  fontSize: screenWidth *
                                                      0.04, // Ukuran teks pada tombol
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // Tambahkan aksi yang ingin ditampilkan pada tampilan pencarian
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Ikon yang ditampilkan di sebelah kiri pada AppBar
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Tampilkan hasil pencarian di sini (jika ada)
    return Center(
      child: Text('Hasil pencarian untuk: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Tampilkan saran pencarian saat pengguna mengetik
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Saran 1'),
          onTap: () {
            // Tindakan yang diambil ketika salah satu saran dipilih
            close(context, 'Saran 1');
          },
        ),
        ListTile(
          title: Text('Saran 2'),
          onTap: () {
            // Tindakan yang diambil ketika salah satu saran dipilih
            close(context, 'Saran 2');
          },
        ),
      ],
    );
  }
}
