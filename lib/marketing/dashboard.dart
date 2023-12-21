import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suco/marketing/laporan.dart';
import 'package:suco/marketing/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:suco/api_config.dart';
import 'dart:math';
import 'package:giffy_dialog/giffy_dialog.dart';

class DashboardPageMarketing extends StatefulWidget {
  const DashboardPageMarketing({Key? key}) : super(key: key);

  @override
  _Dashboard1WidgetState createState() => _Dashboard1WidgetState();
}

class _Dashboard1WidgetState extends State<DashboardPageMarketing> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  String _totalHargaSelesai = '';
  TextEditingController textController = TextEditingController();
  List _listdata = [];
  List _listdatastok = [];
  bool _isloading = true;
  Map<int, Color> colorMap = {}; // Menyimpan warna berdasarkan id_klien
  final _formKey = GlobalKey<FormState>();
  bool isNumeric(String value) {
    return int.tryParse(value) != null;
  }

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _getdatapemasukan('', ''); // Isi tanggal sesuai kebutuhan
    textController = TextEditingController();
    _listdata = [];
    _listdatastok = [];
    _getdatapesanan();
    _getdatastok();
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

  Future<void> _getdatapemasukan(String startDate, String endDate) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.pemasukan}?startDate=$startDate&endDate=$endDate'),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          _totalHargaSelesai = data['total_harga_selesai'].toString();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future _getdatapesanan() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.pesanan_dashboard_marketing),
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

  Future _getdatastok() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.stock_dashboard));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listdatastok = data['stock'];
          _isloading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // update status pesanan dashboard
  Future<void> _updateStatus(
      BuildContext context, int index, String newStatus) async {
    final response = await http.post(
      Uri.parse(ApiConfig.status_update),
      body: {
        'id_pemesanan': _listdata[index]['id_pemesanan'].toString(),
        'status_pesanan': newStatus
      },
    );

    if (response.statusCode == 200) {
      // Status berhasil diperbarui
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GiffyDialog.image(
            Image.asset(
              'lib/assets/success-tick-dribbble.gif',
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
      print('Berhasil');
      // Perbarui status langsung dalam _filteredData
      setState(() {
        _listdata[index]['status_pesanan'] = newStatus;
      });
      await _getdatapesanan();
      print('berhasil');
    } else {
      // Gagal memperbarui status
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GiffyDialog.image(
            Image.asset(
              'lib/assets/failed.gif',
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

  // update harga stok dashboard
  Future<void> _updatePrice(
      BuildContext context, int index, String newStatus) async {
    final response = await http.post(
      Uri.parse(ApiConfig.update_harga),
      body: {
        'id_produk': _listdatastok[index]['id_produk'].toString(),
        'harga_produk': newStatus
      },
    );

    if (response.statusCode == 200) {
      // Status berhasil diperbarui
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GiffyDialog.image(
            Image.asset(
              'lib/assets/success-tick-dribbble.gif',
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
      print('berhasil');
      // Perbarui harga langsung dalam _filteredData
      setState(() {
        _listdatastok[index]['harga_produk'] = newStatus;
      });
    } else {
      // Gagal memperbarui status
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GiffyDialog.image(
            Image.asset(
              'lib/assets/failed.gif',
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
        case 'See Detail':
          return 'Lihat Detail';
        case 'Available Items':
          return 'Ketersediaan Barang';
        case 'Order History':
          return 'Riwayat Pesanan';
        case 'Completed on':
          return 'Selesai pada';
        case 'There isnt any yet':
          return 'Belum Ada';
        case 'Input Date':
          return 'Masukkan Tanggal';
        case 'Product Name':
          return 'Nama Produk';
        case 'Stock':
          return 'Tersedia';
        case 'Price':
          return 'Harga';
        case 'Not yet added':
          return 'Belum ditambahkan';
        case 'Change Price':
          return 'Ubah Harga';
        case 'Save':
          return 'Simpan';
        case 'No Order':
          return 'Tidak ada pesanan';
        case 'No Stock':
          return 'Tidak ada stok';
        case 'Change Price':
          return 'Ubah Harga';
        case 'Save':
          return 'Simpan';
        case 'Successfully':
          return 'Berhasil';
        case 'Failed':
          return 'Gagal';
        case 'Close':
          return 'Tutup';
        case 'Order has been processed':
          return 'Pesanan telah diproses';
        case 'Move to history?':
          return 'Pindahkan ke riwayat';
        case 'Yes':
          return 'Ya';
        case 'No':
          return 'Tidak';
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
    final ThemeData themeData =
        isDarkTheme ? ThemeData.dark() : ThemeData.light();
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
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: mediaQueryWidth * 0.5,
                      height: bodyHeight * 0.08,
                      decoration: BoxDecoration(
                        color:
                            Color(0xFF094067), // Ganti warna sesuai kebutuhan
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Color(
                                0XFF53D258), // Ganti warna sesuai kebutuhan
                            size: 38,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 11, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  getTranslatedText('Income'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  _totalHargaSelesai != ''
                                      ? 'Rp ${NumberFormat.decimalPattern('id_ID').format(int.parse(_totalHargaSelesai))}'
                                      : getTranslatedText('There isnt any yet'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: mediaQueryWidth * 0.4,
                      height: bodyHeight * 0.060,
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
                                Icons.calendar_today,
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
                                  controller: textController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    hintText: getTranslatedText('Input Date'),
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
                                    color: isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: screenWidth *
                                        0.030, // Ukuran teks pada tombol
                                    fontWeight: FontWeight.normal,
                                  ),
                                  readOnly: true,
                                  //set it true, so that user will not able to edit text
                                  onTap: () async {
                                    DateTimeRange? pickedDateRange =
                                        await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            primaryColor: isDarkTheme
                                                ? Color(0xFF8B9BA8)
                                                : Colors
                                                    .blue, // Warna pilihan tanggal saat ditekan
                                            hintColor: isDarkTheme
                                                ? Color(0xFF8B9BA8)
                                                : Colors
                                                    .blue, // Warna pilihan tanggal yang dipilih
                                            colorScheme: ColorScheme.light(
                                                primary: isDarkTheme
                                                    ? Color(0xFF8B9BA8)
                                                    : Colors.blue),
                                            buttonTheme: ButtonThemeData(
                                                textTheme:
                                                    ButtonTextTheme.primary),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (pickedDateRange != null) {
                                      print(pickedDateRange
                                          .start); // Tanggal awal
                                      print(
                                          pickedDateRange.end); // Tanggal akhir

                                      String formattedStartDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDateRange.start!);
                                      String formattedEndDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDateRange.end!);
                                      print(
                                          'startDate: $formattedStartDate, endDate: $formattedEndDate'); // Tambahkan ini

                                      setState(() {
                                        textController.text =
                                            '$formattedStartDate/$formattedEndDate';
                                        _getdatapemasukan(formattedStartDate,
                                            formattedEndDate);
                                      });
                                    }
                                  },
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
              SizedBox(height: bodyHeight * 0.01),
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
                                                    builder: (context) =>
                                                        LaporanWidget()));
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
                                            int idKlien =
                                                _listdata[index]['id_klien'];
                                            return GestureDetector(
                                              onTap: () {
                                                if (_listdata[index]
                                                        ['status_pesanan'] ==
                                                    'Siap Diantar') {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        title: Center(
                                                          child: Text(
                                                              getTranslatedText(
                                                                  'Order has been processed')),
                                                        ),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(getTranslatedText(
                                                                'Move to history?')),
                                                          ],
                                                        ),
                                                        actions: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  // Mengubah status pesanan menjadi 'Selesai'
                                                                  await _updateStatus(
                                                                      context,
                                                                      index,
                                                                      'Selesai');
                                                                },
                                                                child: Text(
                                                                  getTranslatedText(
                                                                      'Yes'),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  // Menutup dialog tanpa melakukan perubahan
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  getTranslatedText(
                                                                      'No'),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                              ),
                                                            ],
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
                                                                  color: getColorForId(
                                                                      idKlien),
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
                    padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslatedText('Available Items'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize:
                                screenWidth * 0.05, // Ukuran teks pada tombol
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _isloading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : _listdatastok.isEmpty
                                ? Center(
                                    child: Text(getTranslatedText('No Stock')),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _listdatastok.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          // Menampilkan form edit harga saat Card ditekan
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              TextEditingController
                                                  priceController =
                                                  TextEditingController(
                                                text: _listdatastok[index]
                                                            ['harga_produk'] !=
                                                        null
                                                    ? '${_listdatastok[index]['harga_produk']}'
                                                    : '',
                                              );

                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // Ganti nilai sesuai keinginan Anda
                                                ),
                                                title: Center(
                                                    child: Text(
                                                        getTranslatedText(
                                                            'Change Price'))),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Form(
                                                      key: _formKey,
                                                      child: TextFormField(
                                                        controller:
                                                            priceController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration: InputDecoration(
                                                            icon: Text('Rp'),
                                                            labelText:
                                                                getTranslatedText(
                                                                    'Price')),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Isi Datanya';
                                                          } else if (!isNumeric(
                                                              value)) {
                                                            return 'harus mengandung angka saja';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  Center(
                                                    child: TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        backgroundColor: Color(
                                                            0xFF3DA9FC), // Ganti warna sesuai keinginan Anda
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  8), // Ganti nilai sesuai keinginan Anda
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        if (_formKey
                                                            .currentState!
                                                            .validate()) {
                                                          await _updatePrice(
                                                              context,
                                                              index,
                                                              priceController
                                                                  .text);
                                                        }
                                                      },
                                                      child: Text(
                                                        getTranslatedText(
                                                            'Save'),
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
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          color: Color(
                                              0xFF094067), // warna latar Card
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(16, 12, 16, 16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      4, 0, 0),
                                                          child: Text(
                                                            getTranslatedText(
                                                                'Product Name'),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color: Color(
                                                                  0xFFFFFFFE),
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.04, // Ukuran teks pada tombol
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      4, 0, 0),
                                                          child: Text(
                                                            _listdatastok[index]
                                                                ['nama_produk'],
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color: Color(
                                                                  0xFFFFFFFE),
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.04, // Ukuran teks pada tombol
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            bodyHeight * 0.02),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      4, 0, 0),
                                                          child: Text(
                                                            getTranslatedText(
                                                                'Stock'),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color: Color(
                                                                  0xFFFFFFFE),
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.04, // Ukuran teks pada tombol
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      4, 0, 0),
                                                          child: Text(
                                                            _listdatastok[index]
                                                                    [
                                                                    'jumlah_produk']
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color: Color(
                                                                  0xFFFFFFFE),
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.04, // Ukuran teks pada tombol
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            bodyHeight * 0.02),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      4, 0, 0),
                                                          child: Text(
                                                            getTranslatedText(
                                                                'Price'),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color: Color(
                                                                  0xFFFFFFFE),
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.04, // Ukuran teks pada tombol
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      4, 0, 0),
                                                          child: Text(
                                                            _listdatastok[index]
                                                                        [
                                                                        'harga_produk'] !=
                                                                    null
                                                                ? 'Rp ${NumberFormat.decimalPattern('id_ID').format(int.parse(_listdatastok[index]['harga_produk']))}'
                                                                : getTranslatedText(
                                                                    'Not yet added'),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color: Color(
                                                                  0xFFFFFFFE),
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.04,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
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
