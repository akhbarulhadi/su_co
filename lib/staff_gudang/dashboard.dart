import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:suco/staff_gudang/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:suco/kepala_gudang/status_pesanan.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:giffy_dialog/giffy_dialog.dart';


class DashboardPageStaff extends StatefulWidget {
  const DashboardPageStaff({Key? key}) : super(key: key);

  @override
  DashboardPageStaffState createState() => DashboardPageStaffState();
}

class DashboardPageStaffState extends State<DashboardPageStaff> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List _listdatastock = [];
  List _listdata = [];
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _listdatastock = [];
    _listdata = [];
    _getdatastok();
    _getdata();
  }

  @override
  void dispose() {
    super.dispose();
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
      await _updateStatus(index, _listdata[index]['id_produksi'], 'selesai.');
    } else {
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
        _listdata[index]['status_produksi'] = statusProduksi;
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
      await _getdata();
      await _getdatastok();
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


  Future _getdata() async {
    try {
      final response =
      await http.get(Uri.parse(ApiConfig.get_production_staff_dashboard));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listdata = data['produksi'];
          _isloading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future _getdatastok() async {
    try {
      final response =
      await http.get(Uri.parse(ApiConfig.stock_kepala_gudang),);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listdatastock = data['stock'];
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
        case 'Available Items':
          return 'Ketersediaan Barang';
        case 'Order History':
          return 'Riwayat Pesanan';
        case 'Completed on':
          return 'Selesai pada';
        case 'Schedule':
          return 'Jadwal';
        case 'Date':
          return 'Tanggal';
        case 'Activity':
          return 'Aktivitas';
        case 'Order Status':
          return 'Status Pemesanan';
        case 'Client Name :':
          return 'Nama klien :';
        case 'Product Code :':
          return 'Kode Produk :';
        case 'Product Name :':
          return 'Nama Produk :';
        case 'Total Product :':
          return 'Jumlah Produk:';
        case 'Type Of Payment :':
          return 'Jenis Pembayaran :';
        case 'Price :':
          return 'Harga :';
        case 'Product Name':
          return 'Nama Produk';
        case 'Stock':
          return 'Tersedia';
        case 'Price':
          return 'Harga';
        case 'Production':
          return 'Produksi';
        case 'Not yet added':
          return 'Belum ditambahkan';
        case 'Production is in order':
          return 'Produksi sudah sesuai';
        case 'Send to Stock ?':
          return 'Kirim Ke Stock ?';
        case 'Yes':
          return 'Ya';
        case 'No':
          return 'Tidak';
        case 'No Production':
          return 'Tidak ada produksi';
        case 'No Stock':
          return 'Tidak ada stok';
        case 'Successfully':
          return 'Berhasil';
        case 'Close':
          return 'Tutup';
        case 'Failed':
          return 'Gagal';
        case '':
          return '';
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
        case 'sudah dibuat':
          return 'already made';
        case 'belum selesai':
          return 'not finished yet';
        case 'sudah sesuai':
          return 'already appropriate';
        case 'selesai':
          return 'finished';
        case '':
          return '';
        case '':
          return '';
        case '':
          return '';
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
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    final ThemeData themeData = isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final myAppBar = AppBar(
      backgroundColor: Colors.transparent, // Mengubah warna AppBar
      elevation: 0, // Menghilangkan efek bayangan di bawah AppBar
      iconTheme: IconThemeData(color: isDarkTheme ? Colors.white : Colors.black), // Mengatur ikon (misalnya, tombol back) menjadi hitam
      title: Align(
        alignment: Alignment.center,
        child: Text(
          getTranslatedText(
              'Main Page'),
          style: TextStyle(
            fontSize: 25.0,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
      ),
      actions: <Widget>[
        SizedBox(width: 45.0,),
      ],
    );
    final bodyHeight = mediaQueryHeight - myAppBar.preferredSize.height - MediaQuery.of(context).padding.top;
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
              SizedBox(height: bodyHeight * 0.03),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFC3DCED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslatedText(
                              'Available Items'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize: screenWidth *
                                0.05, // Ukuran teks pada tombol
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: bodyHeight * 0.01,),
                        _isloading
                            ? Center(
                          child: CircularProgressIndicator(),
                        )
                            : _listdatastock.isEmpty
                            ? Center(
                          child: Text(getTranslatedText('No Stock')),
                        )
                            : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _listdatastock.length,
                            itemBuilder: (context, index) {
                              return Card(
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
                                                    fontWeight:
                                                    FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  _listdatastock[index]
                                                  ['nama_produk'],
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFFFFFFFE),
                                                    fontSize: screenWidth *
                                                        0.04, // Ukuran teks pada tombol
                                                    fontWeight:
                                                    FontWeight.normal,
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
                                                    fontWeight:
                                                    FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  _listdatastock[index]
                                                  ['jumlah_produk']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFFFFFFFE),
                                                    fontSize: screenWidth *
                                                        0.04, // Ukuran teks pada tombol
                                                    fontWeight:
                                                    FontWeight.normal,
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
                                                    fontWeight:
                                                    FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  _listdatastock[index]['harga_produk'] != null
                                                      ? 'Rp ${NumberFormat.decimalPattern('id_ID').format(int.parse(_listdatastock[index]['harga_produk']))}'
                                                      : getTranslatedText('Not yet added'),
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFFFFFFFE),
                                                    fontSize: screenWidth *
                                                        0.04, // Ukuran teks pada tombol
                                                    fontWeight:
                                                    FontWeight.normal,
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
                              );
                            }),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFC3DCED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslatedText(
                              'Production'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize: screenWidth *
                                0.05, // Ukuran teks pada tombol
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: bodyHeight * 0.01,),
                        _isloading
                            ? Center(
                          child: CircularProgressIndicator(),
                        )
                            : _listdata.isEmpty
                            ? Center(
                          child: Text(getTranslatedText('No Production')),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics:
                          NeverScrollableScrollPhysics(),
                          itemCount: _listdata.length,
                          itemBuilder: ((context, index) {
                            return GestureDetector(
                              onTap: () async {
                                if (_listdata[index]['status_produksi'] == 'sudah sesuai') {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        title: Center(
                                          child: Text(getTranslatedText('Production is in order')),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(getTranslatedText('Send to Stock ?')),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              int productId = _listdata[index]['id_produk'];
                                              int jumlahProduksi = _listdata[index]['jumlah_produksi'];
                                              Navigator.of(context).pop();
                                              // Panggil fungsi untuk mengurangi jumlah_produk di tabel ketersediaan_barang
                                              await _updateProductAvailability(index, productId, jumlahProduksi);
                                            },
                                            child: Text(
                                              getTranslatedText('Yes'),
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
                                              getTranslatedText('No'),
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
                                                  _listdata[index]['nama_produk'],
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
                                                  DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                                      _listdata[index]['tanggal_produksi'])),
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
                                                  _listdata[index]['kode_produksi'],
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
                                                  _listdata[index]['nama_ruangan'],
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
                                                  _listdata[index]['nama_user'],
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
                                                  getTranslatedDatabase(_listdata[index]['status_produksi']),
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
                                                  _listdata[index]['jumlah_produksi'].toString(),
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
}
