import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:suco/kepala_gudang/sidebar.dart';
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


class DashboardPageLeaderWarehouse extends StatefulWidget {
  const DashboardPageLeaderWarehouse({Key? key}) : super(key: key);

  @override
  _Dashboard1WidgetState createState() => _Dashboard1WidgetState();
}

class _Dashboard1WidgetState extends State<DashboardPageLeaderWarehouse> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List _listdatastock = [];
  List _listdata = [];
  bool _isloading = true;
  Map<int, Color> colorMap = {}; // Menyimpan warna berdasarkan id_klien

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _listdatastock = [];
    _listdata = [];
    _getdatastok();
    _getdatapesanan();
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

  Color getColorForId(int id) {
    if (!colorMap.containsKey(id)) {
      // Jika id belum ada dalam map, tambahkan warna baru
      colorMap[id] = generateRandomColor();
    }

    return colorMap[id]!;
  }

  Color generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
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

  Future _getdatapesanan() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.pesanan_dashboard_supervisor),
      );
      print(response.body); // Cetak respons ke konsol

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Cetak data ke konsol
        setState(() {
          _listdata = data['pesanan'];
          _isloading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _updateProductAvailability(int index, int productId, int jumlahPesanan) async {
    final response = await http.post(
      Uri.parse(ApiConfig.kurangi_stok1),
      body: {
        'id_produk': productId.toString(),
        'jumlah_pesanan': jumlahPesanan.toString(),
      },
    );

    if (response.statusCode == 200) {
      // Berhasil mengurangkan jumlah_pesanan
      print('Jumlah pesanan berhasil diperbarui');

      // Update _filteredData secara langsung
      setState(() {
        for (int i = 0; i < _listdata.length; i++) {
          if (_listdata[i]['id_produk'] == productId) {
            _listdata[i]['jumlah_produk'] -= jumlahPesanan;
          }
        }
      });

      await _updateStatus(index, _listdata[index]['id_pemesanan'], 'Siap Diantar');
    } else {
      // Gagal mengurangkan jumlah_pesanan
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
              getTranslatedText('Insufficient stock quantity'),
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
      print('Gagal mengurangkan jumlah_pesanan');
    }
  }

  Future<void> _updateStatus(int index, int idPemesanan, String status_pesanan) async {
    final response = await http.post(
      Uri.parse(ApiConfig.status_pesanan),
      body: {
        'id_pemesanan': idPemesanan.toString(),
        'status_pesanan': status_pesanan.toString(),
      },
    );

    if (response.statusCode == 200) {
      // Status berhasil diperbarui
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
      await _getdatapesanan();
      await _getdatastok();
      print('Berhasil');


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
      print('gagal');
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
        case 'Available Items':
          return 'Ketersediaan Barang';
        case 'Product Name':
          return 'Nama Produk';
        case 'Stock':
          return 'Tersedia';
        case 'Price':
          return 'Harga';
        case 'See Detail':
          return 'Lihat Detail';
        case 'Not yet added':
          return 'Belum ditambahkan';
        case 'Successfully':
          return 'Berhasil';
        case 'Failed':
          return 'Gagal';
        case 'Close':
          return 'Tutup';
        case 'No Order':
          return 'Tidak ada pesanan';
        case 'No Stock':
          return 'Tidak ada stok';
        case 'Insufficient stock quantity':
          return 'Jumlah stok tidak mencukupi';
        case 'The order has been processed':
          return 'Pesanan sudah selesai diproses';
        case 'Ready To Be Delivered ?':
          return 'Siap Diantar ?';
        case 'Yes':
          return 'Ya';
        case 'No':
          return 'Tidak';
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
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFF094067), // warna latar Card
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 5, 16, 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                EdgeInsetsDirectional.fromSTEB(12, 9, 0, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _listdata.length
                                              .toString(), // Menggunakan panjang list sebagai teks
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(0xFFFFFFFE),
                                            fontSize: screenWidth *
                                                0.07, // Ukuran teks pada tombol
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 4, 0, 0),
                                      child: Text(
                                        getTranslatedText('Client Order List'),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFFFFFFFE),
                                          fontSize: screenWidth *
                                              0.05, // Ukuran teks pada tombol
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 4, 0, 0),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => StatusPesanan()));
                                          },
                                          child: Text(
                                            getTranslatedText('See Detail'),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Color(0xFFFFFFFE),
                                              fontSize: screenWidth *
                                                  0.03, // Ukuran teks pada tombol
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
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
                      SizedBox(
                        height: bodyHeight * 0.00,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFC3DCED),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                20.0), // Atur radius sudut kiri atas
                            topRight: Radius.circular(
                                20.0), // Atur radius sudut kanan atas
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding:
                          EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _isloading
                                  ? Center(
                                child: CircularProgressIndicator(),
                              )
                                  : _listdata.isEmpty
                                  ? Center(
                                child: Text(
                                    getTranslatedText('No Order')),
                              )
                                  : ListView.builder(
                                shrinkWrap: true,
                                physics:
                                NeverScrollableScrollPhysics(),
                                itemCount: _listdata.length,
                                itemBuilder: (context, index) {
                                  int idKlien = _listdata[index]['id_klien'];
                                  String statusPesanan =
                                  _listdata[index]['status_pesanan'];
                                  return GestureDetector(
                                    onTap: () async {
                                      if (_listdata[index]['status_pesanan'] == 'Menunggu') {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              title: Center(
                                                child: Text(getTranslatedText('The order has been processed')),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(getTranslatedText('Ready To Be Delivered ?')),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () async {
                                                    int productId = _listdata[index]['id_produk'];
                                                    int jumlahPesanan = int.parse(_listdata[index]['jumlah_pesanan']);
                                                    Navigator.of(context).pop();
                                                    // Panggil fungsi untuk mengurangi jumlah_produk di tabel ketersediaan_barang
                                                    await _updateProductAvailability(index, productId, jumlahPesanan);
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
                                      clipBehavior:
                                      Clip.antiAliasWithSaveLayer,
                                      color: Color(0xFF0A4F81),
                                      // warna latar Card
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        mainAxisSize:
                                        MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                            EdgeInsetsDirectional
                                                .fromSTEB(16, 10,
                                                16, 5),
                                            child: Column(
                                              mainAxisSize:
                                              MainAxisSize.max,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0,
                                                          4,
                                                          0,
                                                          0),
                                                      child: Text(
                                                        _listdata[
                                                        index]
                                                        [
                                                        'nama_produk'],
                                                        style:
                                                        TextStyle(
                                                          fontFamily:
                                                          'Inter',
                                                          color: Color(
                                                              0xFFFFFFFE),
                                                          fontSize:
                                                          screenWidth *
                                                              0.05,
                                                          // Ukuran teks pada tombol
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0,
                                                          4,
                                                          0,
                                                          0),
                                                      child: Text(
                                                        _listdata[
                                                        index]
                                                        [
                                                        'jumlah_pesanan'],
                                                        style:
                                                        TextStyle(
                                                          fontFamily:
                                                          'Inter',
                                                          color: Color(
                                                              0xFFFFFFFE),
                                                          fontSize:
                                                          screenWidth *
                                                              0.04,
                                                          // Ukuran teks pada tombol
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width:
                                                      mediaQueryWidth *
                                                          0.07,
                                                      height:
                                                      bodyHeight *
                                                          0.07,
                                                      decoration:
                                                      BoxDecoration(
                                                        color: getColorForId(idKlien),
                                                        shape: BoxShape
                                                            .circle,
                                                      ),
                                                      alignment:
                                                      AlignmentDirectional(
                                                          0.00,
                                                          0.00),
                                                      child: Text(
                                                        _listdata[index]
                                                        [
                                                        'id_klien']
                                                            .toString(),
                                                        style:
                                                        TextStyle(
                                                          fontFamily:
                                                          'Inter',
                                                          color: Colors
                                                              .white,
                                                          fontSize:
                                                          screenWidth *
                                                              0.03,
                                                          // Ukuran teks pada tombol
                                                          fontWeight:
                                                          FontWeight
                                                              .normal,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            12,
                                                            0,
                                                            0,
                                                            0),
                                                        child: Column(
                                                          mainAxisSize:
                                                          MainAxisSize
                                                              .max,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(
                                                                  _listdata[index]['nama_klien'],
                                                                  style:
                                                                  TextStyle(
                                                                    fontFamily: 'Inter',
                                                                    color: Color(0xFFFFFFFE),
                                                                    fontSize: screenWidth * 0.04,
                                                                    // Ukuran teks pada tombol
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0,
                                                          4,
                                                          0,
                                                          0),
                                                      child: Text(
                                                        getTranslatedDatabase(
                                                            _listdata[
                                                            index]
                                                            [
                                                            'status_pesanan']),
                                                        style:
                                                        TextStyle(
                                                          fontFamily:
                                                          'Inter',
                                                          color: Color(
                                                              0xFFFFFFFE),
                                                          fontSize:
                                                          screenWidth *
                                                              0.03,
                                                          // Ukuran teks pada tombol
                                                          fontWeight:
                                                          FontWeight
                                                              .w300,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0,
                                                          4,
                                                          0,
                                                          0),
                                                      child: Text(
                                                        DateFormat(
                                                            'dd-MM-yyyy')
                                                            .format(DateTime.parse(
                                                            _listdata[index]
                                                            [
                                                            'batas_tanggal'])),
                                                        style:
                                                        TextStyle(
                                                          fontFamily:
                                                          'Inter',
                                                          color: Color(
                                                              0xFFFFFFFE),
                                                          fontSize:
                                                          screenWidth *
                                                              0.03,
                                                          // Ukuran teks pada tombol
                                                          fontWeight:
                                                          FontWeight
                                                              .w300,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: bodyHeight *
                                                      0.01,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
            ],
          ),
        ),
      ),
    );
  }
}
