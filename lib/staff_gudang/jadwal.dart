import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class TableEventsExample extends StatefulWidget {
  const TableEventsExample({Key? key}) : super(key: key);

  @override
  TableEventsExampleState createState() => TableEventsExampleState();
}

class TableEventsExampleState extends State<TableEventsExample> {
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


  Future<void> _updateProductAvailability(int index, int productId, int jumlahProduksi) async {
    final response = await http.post(
      Uri.parse(ApiConfig.produksi_selesai),
      body: {
        'id_produk': productId.toString(),
        'jumlah_produksi': jumlahProduksi.toString(),
      },
    );

    if (response.statusCode == 200) {
      // Berhasil mengurangkan jumlah_pesanan
      print('Jumlah pesanan berhasil diperbarui');
      await _updateStatus(index, _listdata[index]['id_produksi'], 'selesai');
    } else {
      // Gagal mengurangkan jumlah_pesanan
      print('Gagal menambahkan jumlah produk');

    }
  }

  Future<void> _updateStatus(int index, int idProduksi, String statusProduksi) async {
    final response = await http.post(
      Uri.parse(ApiConfig.update_status_produksi_selesai),
      body: {
        'id_produksi': idProduksi.toString(),
        'status_produksi': statusProduksi.toString(),
      },
    );

    if (response.statusCode == 200) {
      // Perbarui status langsung dalam _filteredData
      setState(() {
        _filteredData[index]['status_produksi'] = statusProduksi;
      });
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
    } else {
      // Gagal memperbarui status
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


  Future _getdata() async {
    try {
      final response =
      await http.get(Uri.parse(ApiConfig.get_production_staffgudang));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listdata = data['produksi'];
          _filteredData =
              _listdata; // Initially, filtered data is the same as the complete data
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
        case 'Production':
          return 'Produksi';
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
        case 'Select Status':
          return 'Pilih Status';
        case 'Ready To Deliver':
          return 'Siap Diantar';
        case 'Waiting':
          return 'Menunggu';
        case 'Change Status':
          return 'Ubah Status';
        case 'Save':
          return 'Simpan';
        case 'Client Name :':
          return 'Nama klien :';
        case 'Product Code :':
          return 'Kode Produk :';
        case 'Product Name :':
          return 'Nama Produk :';
        case 'Order Quantity :':
          return 'Jumlah Pesanan:';
        case 'Type Of Payment :':
          return 'Jenis Pembayaran :';
        case 'Price :':
          return 'Harga :';
        case 'Deadline :':
          return 'Batas Tanggal :';
        case 'No Production':
          return 'Tidak ada produksi';
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
          getTranslatedText("Production"),
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
                                  onChanged: (query) {
                                    setState(() {
                                      _filteredData = _listdata.where((item) {
                                        // Customize this condition based on your search criteria
                                        return item['nama_perusahaan']
                                            .toLowerCase()
                                            .contains(
                                            query.toLowerCase()) ||
                                            item['status_pesanan']
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
                        ),
                        items: [
                          getTranslatedText("All"),
                          getTranslatedText("Waiting"),
                          getTranslatedText('Ready To Deliver'),
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
              Expanded(
                child: _isloading
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : _filteredData.isEmpty
                    ? Center(
                  child: Text(getTranslatedText('No Production')),
                )
                    : ListView.builder(
                  itemCount: _filteredData.length,
                  itemBuilder: ((context, index) {
                    return GestureDetector(
                      onTap: () async {
                        if (_filteredData[index]['status_produksi'] == 'sudah sesuai') {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                title: Center(
                                  child: Text('Produksi sudah sesuai'),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Kirim Ke Stock ?'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      int productId = _filteredData[index]['id_produk'];
                                      int jumlahProduksi = _filteredData[index]['jumlah_produksi'];
                                      Navigator.of(context).pop();
                                      // Panggil fungsi untuk mengurangi jumlah_produk di tabel ketersediaan_barang
                                      await _updateProductAvailability(index, productId, jumlahProduksi);
                                    },
                                    child: Text(
                                      'Ya',
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Menutup dialog tanpa melakukan perubahan
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Tidak',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
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
                                          _filteredData[index]['nama_produk'],
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
                                          _filteredData[index]['tanggal_produksi'],
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
                                          _filteredData[index]['kode_produksi'],
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
                                          _filteredData[index]['nama_ruangan'],
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
                                          _filteredData[index]['nama_user'],
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
                                          _filteredData[index]['status_produksi'],
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
                                          _filteredData[index]['jumlah_produksi'].toString(),
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
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}