import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:math';

class StatusPesanan extends StatefulWidget {
  const StatusPesanan({Key? key}) : super(key: key);

  @override
  _LaporanWidgetState createState() => _LaporanWidgetState();
}

class _LaporanWidgetState extends State<StatusPesanan> {
  late TextEditingController _textController;
  late FocusNode _unfocusNode;
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List _listdata = [];
  bool _isloading = true;
  List _filteredData = [];
  Map<int, Color> colorMap = {}; // Menyimpan warna berdasarkan id_klien

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

  Future<void> _updateStatus(BuildContext context, int index, String newStatus) async {
    final response = await http.post(
         Uri.parse(ApiConfig.status_pesanan),
      body: {
        'id_pemesanan': _listdata[index]['id_pemesanan'].toString(),
        'status_pesanan': newStatus,
      },
    );

    if (response.statusCode == 200) {
      // Status berhasil diperbarui
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diperbarui'),
          duration: Duration(seconds: 2),
        ),
      );

      // Perbarui status langsung dalam _filteredData
      setState(() {
        _filteredData[index]['status_pesanan'] = newStatus;
      });

      // Panggil fungsi untuk mengurangkan jumlah_produk di tabel ketersediaan
      await _updateProductAvailability(
          _listdata[index]['id_produk'],
          _listdata[index]['jumlah_pesanan'], // Ubah ke string jika diperlukan
      );

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

  Future<void> _updateProductAvailability(int productId, int jumlahPesanan) async {
    final response = await http.post(
      Uri.parse(ApiConfig.kurangi_stok),
      body: {
        'id_produk': productId.toString(),
        'jumlah_pesanan': jumlahPesanan.toString(),
      },
    );

    if (response.statusCode == 200) {
      // Berhasil mengurangkan jumlah_pesanan
      print('Jumlah pesanan berhasil diperbarui');
    } else {
      // Gagal mengurangkan jumlah_pesanan
      print('Gagal mengurangkan jumlah_pesanan');
    }
  }



  Future _getdata() async {
    try {
      final response =
          await http.get(Uri.parse(ApiConfig.pesanan));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listdata = data['pesanan'];
          _filteredData =
              _listdata; // Initially, filtered data is the same as the complete data
          _isloading = false;
        });
      }
    } catch (e) {
      print(e);
    }
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

  Color getColorForStatus(String status) {
    switch (status) {
      case 'Menunggu':
        return Color(0xFFFBE28F);
      case 'Siap Diantar':
        return Color(0xFF00FF00);
      default:
        return Colors.grey; // Warna default jika diluar case nya
    }
  }

// Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Order Status':
          return 'Status Pemesanan';
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
          getTranslatedText("Order Status"),
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
                            child: Text(getTranslatedText('No Order')),
                          )
                        : ListView.builder(
                            itemCount: _filteredData.length,
                            itemBuilder: ((context, index) {
                              int idKlien = _filteredData[index]['id_klien'];
                              String statusPesanan =
                              _filteredData[index]['status_pesanan'];
                              return GestureDetector(
                                onTap: () {
                                  if (_filteredData[index]['status_pesanan'] ==
                                      'Menunggu') {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          title: Center(
                                              child: Text(
                                                  'Pesanan sudah selesai diproses')),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Siap Diantar ?'),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                // Mengubah status pesanan menjadi 'Selesai'
                                                await _updateStatus(context,
                                                    index, 'Siap Diantar');
                                              },
                                              child: Text(
                                                'Ya',
                                                style: TextStyle(
                                                    color: Colors.green),
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
                                                    color: Colors.red),
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
                                            16, 5, 16, 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: mediaQueryWidth * 0.09,
                                              height: bodyHeight * 0.09,
                                              decoration: BoxDecoration(
                                                color: getColorForId(idKlien),
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
                                                  fontWeight: FontWeight.normal,
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          _filteredData[index][
                                                              'nama_perusahaan'],
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            color: Color(
                                                                0xFFFFFFFE),
                                                            fontSize: screenWidth *
                                                                0.04, // Ukuran teks pada tombol
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              mediaQueryWidth *
                                                                  0.20,
                                                          height:
                                                              bodyHeight * 0.03,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: getColorForStatus(
                                                                statusPesanan),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              _filteredData[index][
                                                                  'status_pesanan'],
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: Color(
                                                                    0xFF101518),
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.030, // Ukuran teks pada tombol
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                                          color:
                                                              Color(0xFFFFFFFE),
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
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16, 12, 16, 16),
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
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      getTranslatedText(
                                                          'Client Name :'),
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF57636C),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      _filteredData[index]
                                                          ['nama_klien'],
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF101518),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      getTranslatedText(
                                                          'Product Code :'),
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF57636C),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      _filteredData[index]
                                                              ['kode_produk']
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF101518),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      getTranslatedText(
                                                          'Product Name :'),
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF57636C),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      _filteredData[index]
                                                          ['nama_produk'],
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF101518),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      getTranslatedText(
                                                          'Order Quantity :'),
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF57636C),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          _filteredData[index][
                                                              'jumlah_pesanan'],
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            color: Color(
                                                                0xFF101518),
                                                            fontSize: screenWidth *
                                                                0.03, // Ukuran teks pada tombol
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                        Text(
                                                          '/',
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            color: Color(
                                                                0xFF101518),
                                                            fontSize: screenWidth *
                                                                0.03, // Ukuran teks pada tombol
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                        Text(
                                                          _filteredData[index][
                                                                  'jumlah_produk']
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            color: Color(
                                                                0xFF101518),
                                                            fontSize: screenWidth *
                                                                0.03, // Ukuran teks pada tombol
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      getTranslatedText(
                                                          'Deadline :'),
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF57636C),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      _filteredData[index]
                                                          ['batas_tanggal'],
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF101518),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      getTranslatedText(
                                                          'Type Of Payment :'),
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF57636C),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      _filteredData[index]
                                                          ['jenis_pembayaran'],
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF101518),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      getTranslatedText(
                                                          'Price :'),
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF57636C),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 4, 0, 0),
                                                    child: Text(
                                                      _filteredData[index]
                                                          ['harga_total'],
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            Color(0xFF101518),
                                                        fontSize: screenWidth *
                                                            0.03, // Ukuran teks pada tombol
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
