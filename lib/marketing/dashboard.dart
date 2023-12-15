import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suco/marketing/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:suco/api_config.dart';


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

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _getdatapemasukan('', ''); // Isi tanggal sesuai kebutuhan
    textController = TextEditingController();
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

  Future<void> _getdatapemasukan(String startDate, String endDate) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.pemasukan}?startDate=$startDate&endDate=$endDate'),
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
        case 'No income yet' :
          return 'Belum ada';
        case 'Search...':
          return 'Cari...';
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
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: mediaQueryWidth * 0.5,
                      height: bodyHeight * 0.08,
                      decoration: BoxDecoration(
                        color: Color(0xFF094067), // Ganti warna sesuai kebutuhan
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Color(0XFF53D258), // Ganti warna sesuai kebutuhan
                            size: 40,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 11, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  getTranslatedText(
                                      'Income'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  _totalHargaSelesai != ''
                                      ? 'Rp ${_totalHargaSelesai}'
                                      : getTranslatedText('No income yet'),
                                  style: TextStyle(
                                    fontSize: 16,
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
                                  readOnly: true,
                                  //set it true, so that user will not able to edit text
                                  onTap: () async {
                                    DateTimeRange? pickedDateRange = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );

                                    if (pickedDateRange != null) {
                                      print(pickedDateRange.start); // Tanggal awal
                                      print(pickedDateRange.end);   // Tanggal akhir

                                      String formattedStartDate = DateFormat('yyyy-MM-dd').format(pickedDateRange.start!);
                                      String formattedEndDate = DateFormat('yyyy-MM-dd').format(pickedDateRange.end!);
                                      print('startDate: $formattedStartDate, endDate: $formattedEndDate'); // Tambahkan ini

                                      setState(() {
                                        textController.text = '$formattedStartDate/$formattedEndDate';
                                        _getdatapemasukan(formattedStartDate, formattedEndDate);
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
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16, 5, 16, 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                EdgeInsetsDirectional.fromSTEB(
                                    12, 9, 0, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text(
                                          '2',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color:
                                            Color(0xFFFFFFFE),
                                            fontSize: screenWidth *
                                                0.07, // Ukuran teks pada tombol
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional
                                          .fromSTEB(0, 4, 0, 0),
                                      child: Text(
                                        getTranslatedText(
                                            'Client Order List'),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFFFFFFFE),
                                          fontSize: screenWidth *
                                              0.05, // Ukuran teks pada tombol
                                          fontWeight:
                                          FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional
                                          .fromSTEB(0, 4, 0, 0),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          getTranslatedText(
                                              'See Detail'),
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(0xFFFFFFFE),
                                            fontSize: screenWidth *
                                                0.03, // Ukuran teks pada tombol
                                            fontWeight:
                                            FontWeight.normal,
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
                      SizedBox( height: bodyHeight * 0.01,),
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
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16, 12, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                color: Color(0xFF0A4F81), // warna latar Card
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16, 10, 16, 5),
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
                                                  'Laptop',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFFFFFFFE),
                                                    fontSize: screenWidth *
                                                        0.05, // Ukuran teks pada tombol
                                                    fontWeight:
                                                    FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  '10 pcs',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFFFFFFFE),
                                                    fontSize: screenWidth *
                                                        0.04, // Ukuran teks pada tombol
                                                    fontWeight:
                                                    FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: mediaQueryWidth * 0.07,
                                                height: bodyHeight * 0.07,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF06D5CD),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment:
                                                AlignmentDirectional(0.00, 0.00),
                                                child: Text(
                                                  'id',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    fontSize: screenWidth *
                                                        0.03, // Ukuran teks pada tombol
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                      12, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Nama Klien',
                                                            style: TextStyle(
                                                              fontFamily: 'Inter',
                                                              color:
                                                              Color(0xFFFFFFFE),
                                                              fontSize: screenWidth *
                                                                  0.04, // Ukuran teks pada tombol
                                                              fontWeight:
                                                              FontWeight.bold,
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
                                            MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  '1 Minggu Yang Lalu',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFFFFFFFE),
                                                    fontSize: screenWidth *
                                                        0.03, // Ukuran teks pada tombol
                                                    fontWeight:
                                                    FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox( height: bodyHeight * 0.01,),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                        Card(
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
                                    16, 10, 16, 5),
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
                                            'Elektronik',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Color(0xFFFFFFFE),
                                              fontSize: screenWidth *
                                                  0.05, // Ukuran teks pada tombol
                                              fontWeight:
                                              FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox( height: bodyHeight * 0.02,),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(0, 4, 0, 0),
                                          child: Text(
                                            'Laptop',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Color(0xFFFFFFFE),
                                              fontSize: screenWidth *
                                                  0.05, // Ukuran teks pada tombol
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(0, 4, 0, 0),
                                          child: Text(
                                            '1000 pcs',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Color(0xFFFFFFFE),
                                              fontSize: screenWidth *
                                                  0.04, // Ukuran teks pada tombol
                                              fontWeight:
                                              FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(0, 4, 0, 0),
                                          child: Text(
                                            'Rp. 11.000.000',
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
                                    SizedBox( height: bodyHeight * 0.01,),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                              'Order History'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize: screenWidth *
                                0.05, // Ukuran teks pada tombol
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                        Card(
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
                                    16, 10, 16, 5),
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
                                                'Completed on'),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Color(0xFFFFFFFE),
                                              fontSize: screenWidth *
                                                  0.03, // Ukuran teks pada tombol
                                              fontWeight:
                                              FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(0, 4, 0, 0),
                                          child: Text(
                                            '13 Oktober 2023',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Color(0xFFFFFFFE),
                                              fontSize: screenWidth *
                                                  0.03, // Ukuran teks pada tombol
                                              fontWeight:
                                              FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox( height: bodyHeight * 0.01,)
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF094067),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.20000000298023224),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16, 12, 16, 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: mediaQueryWidth * 0.09,
                                        height: bodyHeight * 0.09,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF06D5CD),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment:
                                        AlignmentDirectional(0.00, 0.00),
                                        child: Text(
                                          'id',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: screenWidth *
                                                0.04, // Ukuran teks pada tombol
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              12, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    'PT',
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      color:
                                                      Color(0xFFFFFFFE),
                                                      fontSize: screenWidth *
                                                          0.04, // Ukuran teks pada tombol
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  'alamat',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFFFFFFFE),
                                                    fontSize: screenWidth *
                                                        0.028, // Ukuran teks pada tombol
                                                    fontWeight:
                                                    FontWeight.normal,
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
                              ),
                            ],
                          ),
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
