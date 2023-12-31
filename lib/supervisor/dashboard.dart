import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:suco/supervisor/laporan.dart';
import 'package:suco/supervisor/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suco/supervisor/kalender.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class DashboardPageSupervisor extends StatefulWidget {
  const DashboardPageSupervisor({Key? key}) : super(key: key);

  @override
  _Dashboard1WidgetState createState() => _Dashboard1WidgetState();
}

class _Dashboard1WidgetState extends State<DashboardPageSupervisor> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List _listdata = [];
  int _totalData = 0;
  bool _isloading = true;
  Map<int, Color> colorMap = {}; // Menyimpan warna berdasarkan id_klien
  bool _isDisposed = false;
  List<Map<String, dynamic>> produksiData = [];
  List<bool> isItemClicked = [];
  TextEditingController textController = TextEditingController();
  List _stockData = [];
  String _selectedProductId = '';
  late TextEditingController _textController;
  TextEditingController jumlahpesananController = TextEditingController();
  TextEditingController hargatotalController = TextEditingController();
  String _totalHasilProduksi = '';
  String _formattedStartDate = ''; // Tambahkan ini
  String _formattedEndDate = ''; // Tambahkan ini

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _listdata = [];
    _getdatapesanan();
    loadProduksi();
    textController = TextEditingController();
    _getStockData();
    _getdatapemasukan('', '', ''); // Isi tanggal sesuai kebutuhan
    _totalData;
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
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

  void _showConfirmationDialog(
    BuildContext context,
    int idproduct,
    String productName,
    String jumlahPesanan,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslatedText("Confirmation")),
          content: Text(
              getTranslatedText("Are you sure you want to create a schedule?")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog konfirmasi
                _navigateToSchedulePage(idproduct, productName, jumlahPesanan);
              },
              child: Text(getTranslatedText("Yes")),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog konfirmasi
              },
              child: Text(getTranslatedText("No"),
                  style: TextStyle(
                  color: Colors
                      .blueGrey)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSchedulePage(
    int idproduct,
    String productName,
    String jumlahPesanan,
  ) {
    print("Navigasi ke halaman pembuatan jadwal");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Calendar(
          idproduct: idproduct,
          productName: productName,
          jumlahPesanan: jumlahPesanan,
        ),
      ),
    );
  }

  Future _getdatapesanan() async {
    try {
      final response =
          await http.get(Uri.parse(ApiConfig.pesanan_dashboard_supervisor));
      print(response.body); // Cetak respons ke konsol

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Cetak data ke konsol
        int totalData = data['total_data']; // Ambil jumlah total data
        setState(() {
          _listdata = data['pesanan'];
          _totalData = totalData; // Simpan total data ke dalam variabel _totalData
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

  Future<void> loadProduksi() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.get_production_supervisor_dashboard));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Tambahkan ini untuk melihat respons data di konsol
        setState(() {
          produksiData = List.from(data['produksi']);
          isItemClicked = List.generate(produksiData.length, (index) => false);
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateStatus(
      BuildContext context, int idProduksi, String newStatus, int index) async {
    if (mounted) {
      // Periksa status sebelumnya, harus "Sudah Dibuat" untuk diubah menjadi "Sudah Sesuai"
      if (newStatus.toLowerCase() == 'sudah sesuai') {
        if (produksiData[index]['status_produksi'] != 'sudah dibuat') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Status harus "Sudah Dibuat" untuk diubah menjadi "Sudah Sesuai".'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      final response = await http.post(
        Uri.parse(ApiConfig.status),
        body: {
          'id_produksi': idProduksi.toString(),
          'status_produksi': newStatus.toLowerCase(),
        },
      );

      if (!_isDisposed && response.statusCode == 200 && mounted) {
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
        // Perbarui data produksi setelah berhasil memperbarui status
        await loadProduksi();
        setState(() {
          isItemClicked[index] = true; // Setel item sudah diklik
          // Tambahkan pembaruan state yang diperlukan setelah memperbarui data
        });
      } else if (!_isDisposed && mounted) {
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
      }
    }
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

  Future<void> _showConfirmationDialog2(
      BuildContext context, int idProduksi, String newStatus, int index) async {
    if (mounted) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          if (!_isDisposed) {
            // Perbarui logika untuk mencegah pembaruan status jika status sudah berubah
            bool canUpdateStatus = !isItemClicked[index];
            return AlertDialog(
              title: Text(getTranslatedText('Confirmation')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(getTranslatedText(
                        'Is production appropriate ?')),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(getTranslatedText('Yes')),
                  onPressed: () async {
                    if (!_isDisposed && canUpdateStatus) {
                      await _updateStatus(
                          context, idProduksi, newStatus, index);
                    }
                  },
                ),
                TextButton(
                  child: Text(getTranslatedText('Cancel'),
                      style: TextStyle(
                          color: Colors
                              .blueGrey)),
                  onPressed: () {
                    if (!_isDisposed) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          } else {
            return Offstage();
          }
        },
      );
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
        case 'Change Status':
          return 'Ubah Status';
        case 'Finished':
          return 'Selesai';
        case 'Waiting':
          return 'Menunggu';
        case 'Edit':
          return 'Ubah';
        case 'Is production appropriate ?':
          return 'Apakah produksi sudah sesuai ?';
        case 'Yes':
          return 'Ya';
        case 'Cancel':
          return 'Batal';
        case 'Are you sure you want to create a schedule?':
          return 'Apakah Anda yakin ingin membuat jadwal?';
        case 'No':
          return 'Tidak';
        case 'Activity':
          return 'Aktivitas';
        case 'Confirmation':
          return 'Konfirmasi';
        case 'Successfully':
          return 'Berhasil';
        case 'Failed':
          return 'Gagal';
        case 'Close':
          return 'Tutup';
        case 'No Production':
          return 'Tidak ada produksi';
        case 'No Order':
          return 'Tidak ada pesanan';
        case 'There isnt any yet':
          return 'Belum Ada';
        case 'Total Production':
          return 'Jumlah Produksi';
        case 'Select Product':
          return 'Pilih Produk';
        case 'Input Date':
          return 'Masukkan Tanggal';
        case 'Items':
          return 'Barang';
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
        // Tambahkan kases lain jika diperlukan
        default:
          return status;
      }
    } else {
      // Teks dalam bahasa Inggris (default)
      return status;
    }
  }

  Future<void> _getdatapemasukan(
      String startDate, String endDate, String selectedProductId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.pemasukan_produksi}?startDate=$startDate&endDate=$endDate&idProduk=$selectedProductId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _totalHasilProduksi = data['total_hasil_produksi'].toString();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData =
        isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final screenWidth = MediaQuery.of(context).size.width;
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
                            Icons.precision_manufacturing_outlined,
                            color: Color(
                                0XFF53D258), // Ganti warna sesuai kebutuhan
                            size: 35,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 11, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  getTranslatedText('Total Production'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  _totalHasilProduksi != ''
                                      ? '${_totalHasilProduksi} ${getTranslatedText('Items')}'
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
                    Column(
                      children: [
                        // Dropdown Produk
                        Container(
                          width: mediaQueryWidth * 0.4,
                          height: bodyHeight * 0.050,
                          decoration: BoxDecoration(
                            color: isDarkTheme ? Colors.white24 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isDarkTheme ? Colors.white38 : Colors.black38,
                              width: 1, // Lebar garis tepi
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.pageview,
                                    color: isDarkTheme
                                        ? Colors.white
                                        : Color(
                                            0xFF8B9BA8), // Ganti dengan warna yang sesuai
                                    size: 20,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: DropdownButtonFormField<String>(
                                      value: null,
                                      items: _stockData
                                          .where((product) =>
                                              product['harga_produk'] !=
                                              null) // Filter produk dengan harga_produk yang tidak null
                                          .map((product) {
                                        return DropdownMenuItem<String>(
                                          value:
                                              product['id_produk'].toString(),
                                          child: Text(
                                            '${product['nama_produk']}',
                                            style: TextStyle(
                                              fontSize: screenWidth *
                                                  0.021, // Ukuran teks pada tombol
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
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
                                        border: InputBorder
                                            .none, // Ini akan menghilangkan garis bawah
                                        hintText: getTranslatedText(
                                            'Select Product'), // Teks hint untuk dropdown
                                        hintStyle: TextStyle(
                                          fontSize: screenWidth *
                                              0.030, // Ukuran teks pada tombol
                                          fontWeight: FontWeight.normal,
                                        ),
                                        // Menghilangkan ikon segitiga ke bawah
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: bodyHeight * 0.01,
                        ),
                        // Dropdown Tanggal
                        Container(
                          width: mediaQueryWidth * 0.4,
                          height: bodyHeight * 0.050,
                          decoration: BoxDecoration(
                            color: isDarkTheme ? Colors.white24 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isDarkTheme ? Colors.white38 : Colors.black38,
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
                                        hintText:
                                            getTranslatedText('Input Date'),
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
                                            0.022, // Ukuran teks pada tombol
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
                                                    textTheme: ButtonTextTheme
                                                        .primary),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (pickedDateRange != null) {
                                          print(pickedDateRange
                                              .start); // Tanggal awal
                                          print(pickedDateRange
                                              .end); // Tanggal akhir

                                          _formattedStartDate =
                                              DateFormat('yyyy-MM-dd').format(
                                                  pickedDateRange.start!);
                                          _formattedEndDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDateRange.end!);
                                          print(
                                              'startDate: $_formattedStartDate, endDate: $_formattedEndDate');

                                          setState(() {
                                            textController.text =
                                                '$_formattedStartDate/$_formattedEndDate';
                                            _getdatapemasukan(
                                                _formattedStartDate,
                                                _formattedEndDate,
                                                _selectedProductId);
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
                                          _totalData.toString(),
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
                                            String statusPesanan =
                                                _listdata[index]
                                                    ['status_pesanan'];
                                            return GestureDetector(
                                              onTap: () {
                                                if (statusPesanan ==
                                                    'Menunggu') {
                                                  _showConfirmationDialog(
                                                    context,
                                                    _listdata[index]
                                                            ['id_produk'] ??
                                                        "", // Pastikan nama_produk tidak null
                                                    _listdata[index]
                                                            ['nama_produk'] ??
                                                        "", // Pastikan nama_produk tidak null
                                                    _listdata[index][
                                                            'jumlah_pesanan'] ??
                                                        "", // Pastikan jumlah_pesanan tidak null
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
                          getTranslatedText('Activity'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize:
                                screenWidth * 0.05, // Ukuran teks pada tombol
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: bodyHeight * 0.01),
                        _isloading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : produksiData.isEmpty
                                ? Center(
                                    child: Text(
                                        getTranslatedText('No Production')),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: produksiData.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final item = produksiData[index];
                                      return GestureDetector(
                                        onTap: () {
                                          if (!isItemClicked[index]) {
                                            print('Tapped index: $index');
                                            _showConfirmationDialog2(
                                                context,
                                                item['id_produksi'],
                                                'Sudah Sesuai',
                                                index);
                                          } else {
                                            print(
                                                'Item sudah diklik dan status sudah sesuai');
                                          }
                                        },
                                        child: buildProductionItem(
                                            item, screenWidth, index),
                                      );
                                    },
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

  Widget buildProductionItem(
      Map<String, dynamic> item, double screenWidth, int index) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    if (item == null) {
      print('Error: Item is null');
      return Container();
    }

    print('Item: $item');

    return GestureDetector(
      onTap: () {
        if (!isItemClicked[index]) {
          if (item['status_produksi'].toLowerCase() == 'sudah dibuat') {
            print('Tapped index: $index');
            _showConfirmationDialog2(
                context, item['id_produksi'], 'Sudah Sesuai', index);
          } else {
            print('Item sudah diklik dan status sudah sesuai');
          }
        } else {
          print('Item sudah diklik dan status sudah sesuai');
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
                          DateFormat('dd-MM-yyyy').format(
                              DateTime.parse(item['tanggal_produksi'])) ??
                              '',
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
                      SizedBox(
                        width: mediaQueryWidth * 0.02,
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
                          getTranslatedDatabase(item['status_produksi'] ?? ''),
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
