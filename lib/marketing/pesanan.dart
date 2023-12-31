import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:suco/marketing/data_client.dart';
import 'package:intl/intl.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class Pesanan extends StatefulWidget {
  const Pesanan({Key? key}) : super(key: key);

  @override
  PesananState createState() => PesananState();
}

class PesananState extends State<Pesanan> {
  late TextEditingController _textController;
  late FocusNode _unfocusNode;
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List _listdata = [];
  List _filteredData = [];
  bool _isloading = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController idklienController = TextEditingController();
  TextEditingController jenispembayaranController = TextEditingController();
  TextEditingController hargatotalController = TextEditingController();
  TextEditingController batastanggalController = TextEditingController();
  TextEditingController jumlahpesananController = TextEditingController();
  TextEditingController namaklienController = TextEditingController();
  bool isDataBenar = false;
  bool isNumeric(String value) {
    return int.tryParse(value) != null;
  }
  List _stockData = [];
  String _selectedProductId = '';

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _textController = TextEditingController();
    _unfocusNode = FocusNode();
    _getdata();
    _listdata = [];
    _filteredData = [];
    _getStockData();
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

  Future<void> _getStockData() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.stock));
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _stockData = data['stock'];
          // Tambahkan penanganan nilai default di sini jika diperlukan
          if (_stockData.isNotEmpty) {
            _selectedProductId = _stockData[0]['id_produk'].toString();
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createPesanan() async {

    final response = await http.post(
      Uri.parse(ApiConfig.tambah_pesanan),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "kode_pemesanan": '',
        "id_produk": _selectedProductId,
        "id_klien": idklienController.text,
        "harga_total": hargatotalController.text,
        "jenis_pembayaran": jenispembayaranController.text,
        "jumlah_pesanan": jumlahpesananController.text,
        "batas_tanggal": batastanggalController.text,
      }),
    );

    if (response.statusCode == 201) {
      print("Data Pesanan berhasil dibuat!");
      print("Response: ${response.body}");
      setState(() {
        isDataBenar = false; // Set data ke false
        idklienController.clear();
        hargatotalController.clear();
        jenispembayaranController.clear();
        jumlahpesananController.clear();
        batastanggalController.clear();
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
      // Tambahkan logika atau navigasi ke halaman berikutnya jika diperlukan
    } else {
      print("Gagal membuat data Pesanan.");
      print("Response: ${response.body}");
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
      final response = await http.get(Uri.parse(ApiConfig.client));
      print(response.body); // Cetak respons ke konsol

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Cetak data ke konsol
        setState(() {
          _listdata = data['klien'];
          _filteredData = _listdata;
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
        case 'Client Data':
          return 'Data Klien';
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
        case 'Deadline':
          return 'Batas Tanggal';
        case 'No Data Client':
          return 'Tidak Ada Data Klien';
        case '+ Client':
          return '+ Klien';
        case 'Click Here to add an order':
          return 'Klik Disini untuk menambah pesanan';
        case 'Make an Order':
          return 'Buat Pesanan';
        case 'Client Name':
          return 'Nama Klien';
        case 'Select Product':
          return 'Pilih Produk';
        case 'Order Quantity':
          return 'Jumlah Pesanan';
        case 'Total Price':
          return 'Harga Total';
        case 'Type of payment':
          return 'Jenis Pembayaran';
        case 'Deadline':
          return 'Batas Tanggal';
        case 'Cancel':
          return 'Batal';
        case 'Successfully':
          return 'Berhasil';
        case 'Failed':
          return 'Gagal';
        case 'Close':
          return 'Tutup';
        case 'No Data Client':
          return 'Tidak ada data klien';
        case 'Company Name':
          return 'Nama Perusahaan';
        case 'Client Detail':
          return 'Detail Klien';
        case 'Address':
          return 'Alamat';
        case 'Select the product first':
          return 'Pilih produk terlebih dahulu';
        case 'Fill in the data':
          return 'Isi datanya';
        case 'Must contain numbers only':
          return 'Harus mengandung angka saja';
        case 'Minimum 1 numbers':
          return 'Minimal 1 angka';
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

  bool isDateInRange(String date, String dateRange) {
    List<String> dateRangeArray = dateRange.split('/');
    if (dateRangeArray.length == 2) {
      String startDateString = dateRangeArray[0].trim();
      String endDateString = dateRangeArray[1].trim();

      DateTime startDate = DateTime.parse(startDateString);
      DateTime endDate = DateTime.parse(endDateString).add(Duration(days: 1));

      DateTime dateToCheck = DateTime.parse(date);

      return dateToCheck.isAfter(startDate.subtract(Duration(days: 1))) &&
          dateToCheck.isBefore(endDate);
    }
    return false;
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
          getTranslatedText("Client Data"),
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
    return MaterialApp(
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
                    width: mediaQueryWidth * 0.6,
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
                                      String lowerCaseQuery = query.toLowerCase();

                                      // Mencocokkan berdasarkan nama_perusahaan
                                      bool matchesname = item['nama_perusahaan'].toLowerCase().contains(lowerCaseQuery);
                                      bool matchesupdated_at = item['updated_at'].toLowerCase().contains(lowerCaseQuery);

                                      // Mencocokkan berdasarkan updated_at dengan jangka waktu
                                      bool matchesupdated_at2 = (item['updated_at'] != null) &&
                                          isDateInRange(
                                            DateFormat('yyyy-MM-dd').format(DateTime.parse(item['updated_at'])),
                                            lowerCaseQuery,
                                          );
                                      bool matchesBareng = matchesname && matchesupdated_at;
                                      bool matchesBareng2 = matchesname && matchesupdated_at2;

                                      // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                                      return matchesBareng || matchesBareng2 || matchesname || matchesupdated_at || matchesupdated_at2;
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DataClient()));
                    },
                    child: Text(
                      getTranslatedText('+ Client'),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(120, 38),
                      padding: EdgeInsets.all(10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      primary: Color(0xFF3DA9FC),
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
                          child: Text(getTranslatedText('No Data Client')),
                        )
                      : ListView.builder(
                          itemCount: _filteredData.length,
                          itemBuilder: ((context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Menampilkan form edit harga saat Card ditekan
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    TextEditingController
                                        perusahaanController =
                                        TextEditingController(
                                            text: _listdata[index]
                                                    ['nama_perusahaan']
                                                .toString());
                                    TextEditingController
                                        namaklienController =
                                        TextEditingController(
                                            text: _listdata[index]
                                                    ['nama_klien']
                                                .toString());
                                    TextEditingController alamatController =
                                        TextEditingController(
                                            text: _listdata[index]['alamat']
                                                .toString());
                                    TextEditingController faxController =
                                        TextEditingController(
                                            text: _listdata[index]['fax']
                                                .toString());
                                    TextEditingController emailController =
                                    TextEditingController(
                                        text: _listdata[index]['email']
                                            .toString());
                                    TextEditingController notelpController =
                                    TextEditingController(
                                        text: _listdata[index]['no_tlp']
                                            .toString());
                                    TextEditingController nobankController =
                                    TextEditingController(
                                        text: _listdata[index]['no_bank']
                                            .toString());
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Ganti nilai sesuai keinginan Anda
                                      ),
                                      title: Center(
                                          child: Text(getTranslatedText(
                                              'Client Detail'))),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: perusahaanController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Company Name')),
                                              enabled: false,
                                            ),
                                            TextField(
                                              controller: namaklienController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Client Name')),
                                              enabled:
                                                  false, // Mengatur TextField menjadi disable
                                            ),
                                            TextField(
                                              controller: alamatController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Address')),
                                              enabled:
                                                  false, // Mengatur TextField menjadi disable
                                            ),
                                            TextField(
                                              controller: emailController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Email')),
                                              enabled:
                                              false, // Mengatur TextField menjadi disable
                                            ),
                                            TextField(
                                              controller: nobankController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'No Bank')),
                                              enabled:
                                              false, // Mengatur TextField menjadi disable
                                            ),
                                            TextField(
                                              controller: notelpController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'No Telp')),
                                              enabled:
                                              false, // Mengatur TextField menjadi disable
                                            ),
                                            TextField(
                                              controller: faxController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  labelText: 'Fax'),
                                              enabled:
                                                  false, // Mengatur TextField menjadi disable
                                            ),
                                          ],
                                        ),
                                      ),
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
                                          16, 10, 16, 5),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: mediaQueryWidth * 0.09,
                                                height: bodyHeight * 0.09,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF06D5CD),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.00, 0.00),
                                                child: Text(
                                                  _filteredData[index]['id_klien']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    fontSize: screenWidth *
                                                        0.04, // Ukuran teks pada tombol
                                                    fontWeight:
                                                    FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(12, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.max,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        _filteredData[index]
                                                        ['nama_perusahaan'],
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
                                                      Padding(
                                                        padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0, 4, 0, 0),
                                                        child: Text(
                                                          _filteredData[index]
                                                          ['alamat'],
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            color: Color(
                                                                0xFFFFFFFE),
                                                            fontSize: screenWidth *
                                                                0.028, // Ukuran teks pada tombol
                                                            fontWeight:
                                                            FontWeight
                                                                .normal,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF094067),
                                        border: Border.all(
                                          color: Colors.black.withOpacity(
                                              0.20000000298023224),
                                        ),
                                      ),
                                      child: Padding(
                                        padding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                1, 1, 1, 1),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .end,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 0, 0),
                                              child: TextButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible:
                                                    false,
                                                    builder: (BuildContext
                                                    context) {
                                                      idklienController =
                                                          TextEditingController(
                                                              text: _listdata[
                                                              index]
                                                              [
                                                              'id_klien']
                                                                  .toString());
                                                      namaklienController =
                                                          TextEditingController(
                                                              text: _listdata[
                                                              index]
                                                              [
                                                              'nama_klien']
                                                                  .toString());
                                                      return Form(
                                                        key: _formKey,
                                                        child: Center(
                                                          child:
                                                          SingleChildScrollView(
                                                            child:
                                                            AlertDialog(
                                                              title: Text(
                                                                  getTranslatedText('Make an Order')),
                                                              content:
                                                              Column(
                                                                mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                                children: [
                                                                  Visibility(
                                                                    visible:
                                                                    false,
                                                                    child:
                                                                    TextFormField(
                                                                      controller:
                                                                      idklienController,
                                                                      obscureText:
                                                                      false,
                                                                      decoration:
                                                                      InputDecoration(
                                                                        labelText:
                                                                        'Id Client',
                                                                        contentPadding:
                                                                        EdgeInsets.all(13),
                                                                      ),
                                                                      style:
                                                                      TextStyle(fontSize: 16),
                                                                      validator:
                                                                          (value) {
                                                                        if (value == null ||
                                                                            value.isEmpty) {
                                                                          return getTranslatedText('Fill in the data');
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                  ),
                                                                  TextFormField(
                                                                    controller:
                                                                    namaklienController,
                                                                    obscureText:
                                                                    false,
                                                                    enabled:
                                                                    false,
                                                                    decoration:
                                                                    InputDecoration(
                                                                      labelText:
                                                                      getTranslatedText('Client Name'),
                                                                      contentPadding:
                                                                      EdgeInsets.all(13),
                                                                    ),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        16),
                                                                    validator:
                                                                        (value) {
                                                                      if (value == null ||
                                                                          value.isEmpty) {
                                                                        return getTranslatedText('Fill in the data');
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                  DropdownButtonFormField<String>(
                                                                    value: null,
                                                                    items: _stockData
                                                                        .where((product) => product['harga_produk'] != null) // Filter produk dengan harga_produk yang tidak null
                                                                        .map((product) {
                                                                      return DropdownMenuItem<String>(
                                                                        value: product['id_produk'].toString(),
                                                                        child: Text('${product['nama_produk']} - Rp${product['harga_produk']}'),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged: (String? newValue) {
                                                                      setState(() {
                                                                        _selectedProductId = newValue!;
                                                                        // Reset the jumlah_pesanan and hargatotalController when product changes
                                                                        jumlahpesananController.text = '';
                                                                        hargatotalController.text = '';
                                                                      });
                                                                    },
                                                                    decoration: InputDecoration(
                                                                      labelText: getTranslatedText('Select Product'),
                                                                    ),
                                                                    validator: (value) {
                                                                      if (value == null || value.isEmpty) {
                                                                        return getTranslatedText('Select the product first');
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                  TextFormField(
                                                                    keyboardType: TextInputType.number,
                                                                    controller: jumlahpesananController,
                                                                    onChanged: (value) {
                                                                      // Calculate harga_total when jumlah_pesanan changes
                                                                      double hargaProduk = double.tryParse(
                                                                        _stockData.firstWhere(
                                                                              (product) => product['id_produk'].toString() == _selectedProductId,
                                                                        )['harga_produk'] ?? '0',
                                                                      ) ?? 0;
                                                                      int jumlahPesanan = int.tryParse(value) ?? 0;
                                                                      double totalHarga = hargaProduk * jumlahPesanan;
                                                                      hargatotalController.text = totalHarga.toStringAsFixed(totalHarga.truncateToDouble() == totalHarga ? 0 : 2);
                                                                    },
                                                                    obscureText: false,
                                                                    decoration: InputDecoration(
                                                                      labelText: getTranslatedText('Order Quantity'),
                                                                      contentPadding: EdgeInsets.all(13),
                                                                    ),
                                                                    style: TextStyle(fontSize: 16),
                                                                    validator: (value) {
                                                                      if (value == null || value.isEmpty) {
                                                                        return getTranslatedText('Fill in the data');
                                                                      } else if (value.length < 1) {
                                                                        return getTranslatedText('Minimum 1 numbers');
                                                                      } else if (!isNumeric(value)) {
                                                                        return getTranslatedText('Must contain numbers only');
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                  TextFormField(
                                                                    enabled: false,
                                                                    controller:
                                                                    hargatotalController,
                                                                    obscureText:
                                                                    false,
                                                                    decoration:
                                                                    InputDecoration(
                                                                      icon: Text('Rp'),
                                                                      labelText:
                                                                      getTranslatedText('Total Price'),
                                                                      contentPadding:
                                                                      EdgeInsets.all(13),
                                                                    ),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        16),
                                                                    validator:
                                                                        (value) {
                                                                      if (value == null ||
                                                                          value.isEmpty) {
                                                                        return getTranslatedText('Fill in the data');
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                  TextFormField(
                                                                    controller:
                                                                    jenispembayaranController,
                                                                    obscureText:
                                                                    false,
                                                                    decoration:
                                                                    InputDecoration(
                                                                      labelText:
                                                                      getTranslatedText('Type of payment'),
                                                                      contentPadding:
                                                                      EdgeInsets.all(13),
                                                                    ),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        16),
                                                                    validator:
                                                                        (value) {
                                                                      if (value == null ||
                                                                          value.isEmpty) {
                                                                        return getTranslatedText('Fill in the data');
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                  TextFormField(
                                                                    controller: batastanggalController,
                                                                    decoration: InputDecoration(
                                                                        icon: Icon(Icons.calendar_today),
                                                                        labelText: getTranslatedText("Deadline")
                                                                    ),
                                                                    readOnly: true,
                                                                    //set it true, so that user will not able to edit text
                                                                    onTap: () async {
                                                                      DateTime now = DateTime.now();
                                                                      DateTime tomorrow = now.add(Duration(days: 1));

                                                                      DateTime? pickedDate = await showDatePicker(
                                                                          context: context,
                                                                          initialDate: tomorrow,
                                                                          firstDate: tomorrow,
                                                                          //DateTime.now() - not to allow to choose before today.
                                                                          lastDate: DateTime(2100));

                                                                      if (pickedDate != null) {
                                                                        print(
                                                                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                                        String formattedDate =
                                                                        DateFormat('yyyy-MM-dd').format(pickedDate);
                                                                        print(
                                                                            formattedDate); //formatted date output using intl package =>  2021-03-16
                                                                        setState(() {
                                                                          batastanggalController.text =
                                                                              formattedDate; //set output date to TextField value.
                                                                        });
                                                                      } else {}
                                                                    },
                                                                    validator:
                                                                        (value) {
                                                                      if (value == null ||
                                                                          value.isEmpty) {
                                                                        return getTranslatedText('Fill in the data');
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                                  children: [
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (_formKey.currentState!.validate()) {
                                                                          createPesanan();
                                                                          Navigator.pop(context);
                                                                        }
                                                                      },
                                                                      child:
                                                                      Text(getTranslatedText('Make an Order')),
                                                                      style:
                                                                      ElevatedButton.styleFrom(
                                                                        minimumSize:
                                                                        Size(100, 40),
                                                                        padding:
                                                                        EdgeInsets.all(10),
                                                                        shape:
                                                                        RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(19),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                      10.0,
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child:
                                                                      Text(getTranslatedText('Cancel')),
                                                                      style:
                                                                      TextButton.styleFrom(
                                                                        minimumSize:
                                                                        Size(100, 40),
                                                                        padding:
                                                                        EdgeInsets.all(10),
                                                                        shape:
                                                                        RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(19),
                                                                          side: BorderSide(
                                                                            color: Color(0xFF3DA9FC),
                                                                            width: 1.0,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                    getTranslatedText('Click Here to add an order'),
                                                style: TextStyle(color: Colors.white),),
                                              ),
                                            ),
                                          ],
                                        ),

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
    );
  }
}
