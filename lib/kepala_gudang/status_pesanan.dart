import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:suco/kepala_gudang/dashboard.dart';

class StatusPesanan extends StatefulWidget {
  const StatusPesanan({Key? key}) : super(key: key);

  @override
  _LaporanWidgetState createState() => _LaporanWidgetState();
}

class _LaporanWidgetState extends State<StatusPesanan> {
  late TextEditingController _textController;
  late TextEditingController _textstatusController;
  late TextEditingController _textperiodController;
  late FocusNode _unfocusNode;
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List _listdata = [];
  bool _isloading = true;
  List _filteredData = [];
  Map<int, Color> colorMap = {}; // Menyimpan warna berdasarkan id_klien
  String selectedPeriod = "";
  String selectedStatus = "";


  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _textController = TextEditingController();
    _textstatusController = TextEditingController();
    _textperiodController = TextEditingController();
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
    _textstatusController.dispose();
    _textperiodController.dispose();
    _textController.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }

  bool isDateInRange(String date, String dateRange) {
    List<String> dateRangeArray = dateRange.split('/');
    if (dateRangeArray.length == 2) {
      String startDateString = dateRangeArray[0].trim();
      String endDateString = dateRangeArray[1].trim();

      DateTime startDate = DateTime.parse(startDateString);
      DateTime endDate = DateTime.parse(endDateString).add(Duration(days: 1));

      DateTime dateToCheck = DateTime.parse(date);

      return dateToCheck.isAfter(startDate.subtract(Duration(days: 1))) && dateToCheck.isBefore(endDate);
    }
    return false;
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
        for (int i = 0; i < _filteredData.length; i++) {
          if (_filteredData[i]['id_produk'] == productId) {
            _filteredData[i]['jumlah_produk'] -= jumlahPesanan;
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
      print('Berhasil');

      // Perbarui status langsung dalam _filteredData
      setState(() {
        _filteredData[index]['status_pesanan'] = status_pesanan;
      });

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
        case 'Order / Stock :':
          return 'Pesanan / Ketersediaan :';
        case 'Type Of Payment :':
          return 'Jenis Pembayaran :';
        case 'Price :':
          return 'Harga :';
        case 'Deadline :':
          return 'Batas Tanggal :';
        case 'The order has been processed':
          return 'Pesanan sudah selesai diproses';
        case 'Ready To Be Delivered ?':
          return 'Siap Diantar ?';
        case 'Yes':
          return 'Ya';
        case 'No':
          return 'Tidak';
        case 'Insufficient stock quantity':
          return 'Jumlah stok tidak mencukupi';
        case 'Successfully':
          return 'Berhasil';
        case 'Failed':
          return 'Gagal';
        case 'Close':
          return 'Tutup';
        case 'No Order':
          return 'Tidak ada pesanan';
        case 'No Order':
          return 'Tidak ada pesanan';
        case 'Ready Delivered':
          return 'Siap Diantar';
        case 'Cancelled':
          return 'Batal';
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
        case 'Batal':
          return 'Cancelled';
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
                    //ini dropdown jangka waktu
                    Container(
                      width: mediaQueryWidth * 0.28,
                      height: bodyHeight * 0.060,
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
                        onChanged: (selectedItem) {
                          setState(() {
                            // Set nilai pilihan dropdown
                            selectedPeriod = selectedItem ?? getTranslatedText("All");

                            // Set nilai pada search bar sesuai dengan pilihan dropdown
                            if (selectedPeriod == getTranslatedText("Daily")) {
                              _textController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
                            } else if (selectedPeriod == getTranslatedText("Weekly")) {
                              // Mendapatkan tanggal awal dan akhir minggu saat ini
                              DateTime now = DateTime.now();
                              DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                              DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

                              _textController.text =
                              '${DateFormat('yyyy-MM-dd').format(startOfWeek)}/${DateFormat('yyyy-MM-dd').format(endOfWeek)}';
                            } else if (selectedPeriod == getTranslatedText("Monthly")) {
                              // Mendapatkan tanggal awal dan akhir bulan saat ini
                              DateTime now = DateTime.now();
                              DateTime startOfMonth = DateTime(now.year, now.month, 1);
                              DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));

                              _textController.text =
                              '${DateFormat('yyyy-MM-dd').format(startOfMonth)}/${DateFormat('yyyy-MM-dd').format(endOfMonth)}';
                            } else if (selectedPeriod == getTranslatedText("Yearly")) {
                              // Mendapatkan tanggal awal dan akhir tahun saat ini
                              DateTime now = DateTime.now();
                              DateTime startOfYear = DateTime(now.year, 1, 1);
                              DateTime endOfYear = DateTime(now.year, 12, 31);

                              _textController.text =
                              '${DateFormat('yyyy-MM-dd').format(startOfYear)}/${DateFormat('yyyy-MM-dd').format(endOfYear)}';
                            } else {
                              _textController.text = "";
                            }

                            // Lakukan filter berdasarkan pilihan dropdown
                            _filteredData = _listdata.where((item) {
                              String lowerCaseQuery = _textController.text.toLowerCase();

                              // Mencocokkan berdasarkan nama_perusahaan
                              bool matchesname = item['nama_perusahaan'].toLowerCase().contains(lowerCaseQuery);
                              bool matchescreated_at = item['batas_tanggal'].toLowerCase().contains(lowerCaseQuery);

                              // Mencocokkan berdasarkan updated_at dengan jangka waktu
                              bool matchescreated_at2 = (item['batas_tanggal'] != null) &&
                                  isDateInRange(
                                    DateFormat('yyyy-MM-dd').format(DateTime.parse(item['batas_tanggal'])),
                                    lowerCaseQuery,
                                  );

                              // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                              return matchesname || matchescreated_at || matchescreated_at2;
                            }).toList();
                          });
                        },
                        selectedItem: getTranslatedText('All'),
                      ),
                    ),
                    //ini searchbar
                    Container(
                      width: mediaQueryWidth * 0.38,
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
                                        String lowerCaseQuery = query.toLowerCase();

                                        // Mencocokkan berdasarkan
                                        bool matchesname = item['nama_perusahaan'].toLowerCase().contains(lowerCaseQuery);
                                        bool matchescreated_at = item['batas_tanggal'].toLowerCase().contains(lowerCaseQuery);
                                        bool matchesstatus = item['status_pesanan'].toLowerCase().contains(lowerCaseQuery);

                                        // Mencocokkan berdasarkan updated_at dengan jangka waktu
                                        bool matchescreated_at2 = (item['batas_tanggal'] != null) &&
                                            isDateInRange(
                                              DateFormat('yyyy-MM-dd').format(DateTime.parse(item['batas_tanggal'])),
                                              lowerCaseQuery,
                                            );

                                        // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                                        return matchesname || matchescreated_at || matchescreated_at2 || matchesstatus;
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
                    //ini dropdown status
                    Container(
                      width: mediaQueryWidth * 0.28,
                      height: bodyHeight * 0.060,
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
                          getTranslatedText('Ready Delivered'),
                          getTranslatedText('Cancelled'),
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
                        onChanged: (selectedItem) {
                          setState(() {
                            // Set nilai pilihan dropdown
                            selectedStatus = selectedItem ?? getTranslatedText("All");

                            // Set nilai pada search bar sesuai dengan pilihan dropdown
                            if (selectedStatus == getTranslatedText("Waiting")) {
                              _textstatusController.text = ("Menunggu");
                            } else if (selectedStatus == getTranslatedText("Ready Delivered")) {
                              _textstatusController.text = ("Siap Diantar");
                            }else if (selectedStatus == getTranslatedText("Cancelled")) {
                              _textstatusController.text = ("Batal");
                            } else {
                              _textstatusController.text = "";
                            }

                            // Lakukan filter berdasarkan pilihan dropdown
                            _filteredData = _listdata.where((item) {
                              String lowerCaseQuery = _textstatusController.text.toLowerCase();

                              // Mencocokkan berdasarkan
                              bool matchesstatus = item['status_pesanan'].toLowerCase().contains(lowerCaseQuery);

                              // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                              return matchesstatus;
                            }).toList();
                          });
                        },
                        selectedItem: getTranslatedText("All"),
                      ),
                    ),
                    //ini searchbar untuk dropdown status
                    Visibility(
                      visible: false,
                      child: Container(
                        width: mediaQueryWidth * 0.38,
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
                                      : Color(
                                      0xFF8B9BA8), // Ganti dengan warna yang sesuai
                                  size: 15,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: TextFormField(
                                    controller: _textstatusController,
                                    onChanged: (query) {
                                      setState(() {
                                        _filteredData = _listdata.where((item) {
                                          String lowerCaseQuery = query.toLowerCase();

                                          // Mencocokkan berdasarkan
                                          bool matchesname = item['nama_perusahaan'].toLowerCase().contains(lowerCaseQuery);
                                          bool matchescreated_at = item['batas_tanggal'].toLowerCase().contains(lowerCaseQuery);
                                          bool matchesstatus = item['status_pesanan'].toLowerCase().contains(lowerCaseQuery);

                                          // Mencocokkan berdasarkan updated_at dengan jangka waktu
                                          bool matchescreated_at2 = (item['batas_tanggal'] != null) &&
                                              isDateInRange(
                                                DateFormat('yyyy-MM-dd').format(DateTime.parse(item['batas_tanggal'])),
                                                lowerCaseQuery,
                                              );

                                          // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                                          return matchesname || matchescreated_at || matchescreated_at2 || matchesstatus;
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
                                onTap: () async {
                                  if (_filteredData[index]['status_pesanan'] == 'Menunggu') {
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
                                                int productId = _filteredData[index]['id_produk'];
                                                int jumlahPesanan = int.parse(_filteredData[index]['jumlah_pesanan']);
                                                Navigator.of(context).pop();
                                                // Panggil fungsi untuk mengurangi jumlah_produk di tabel ketersediaan_barang
                                                await _updateProductAvailability(index, productId, jumlahPesanan);
                                                },
                                              child: Text(
                                                getTranslatedText('Yes'),
                                                style: TextStyle(
                                                  color: Colors.blue,
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
                                                      color: Colors
                                                          .blueGrey),
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
                                                                  0.25,
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
                                                              getTranslatedDatabase(_filteredData[index][
                                                                  'status_pesanan']),
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
                                                          'Order / Stock :'),
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
                                                      DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                                          _filteredData[index]['batas_tanggal'])),
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
                                                      'Rp ${NumberFormat.decimalPattern('id_ID').format(int.parse(_filteredData[index]['harga_total']))}',
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