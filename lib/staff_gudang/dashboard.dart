import 'package:flutter/material.dart';
import 'package:suco/staff_gudang/sidebar.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPageStaff extends StatefulWidget {
  const DashboardPageStaff({Key? key}) : super(key: key);

  @override
  _DashboardPageStaffState createState() => _DashboardPageStaffState();
}

class _DashboardPageStaffState extends State<DashboardPageStaff> {
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List _listdata = [];
  bool _isloading = true;
  List _filteredData = [];
  List<Map<String, dynamic>> produksiData = [];

  @override
  void initState() {
    super.initState();
    loadThemePreference();
    loadSelectedLanguage();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    loadProduksi();
    _getdata();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
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

  Future _getdata() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.stock));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listdata = data['stock'];
          _filteredData =
              _listdata; // Initially, filtered data is the same as the complete data
          _isloading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadProduksi() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.produksi));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Tambahkan ini untuk melihat respons data di konsol
        setState(() {
          produksiData = List.from(data['produksi']);
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
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
        default:
          return text;
      }
    } else {
      return text;
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme:
          IconThemeData(color: isDarkTheme ? Colors.white : Colors.black),
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
      theme: themeData,
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        drawer: SidebarDrawer(),
        appBar: myAppBar,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // Display Product Availability
              ProductAvailabilityWidget(
                mediaQueryHeight: mediaQueryHeight,
                screenWidth: screenWidth,
                availabilityData: _listdata.cast<Map<String, dynamic>>(),
              ),

              // SizedBox(height: bodyHeight * 0.03),
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
                        // Text for Activity
                        Text(
                          getTranslatedText('Activity'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: bodyHeight * 0.01),

                        // Added ListView.builder to display production data
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: produksiData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = produksiData[index];
                            return buildProductionItem(item, screenWidth);
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

  Widget buildProductionItem(Map<String, dynamic> item, double screenWidth) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    if (item == null) {
      print('Error: Item is null');
      return Container(); // Atau widget lain sebagai penanganan error
    }

    print('Item: $item');
    return Card(
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
                        item['nama_produk'] ??
                            '', // Ganti dengan kunci yang sesuai
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
                        item['tanggal_produksi'] ??
                            '', // Ganti dengan data yang sesuai dari produksi
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
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        'Ruang Produksi Lane-001',
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
                    // Menampilkan status produksi di sebelah kiri
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        item['status_produksi'] ??
                            '', // Ganti dengan data yang sesuai dari produksi
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFFFFFFFE),
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    // Menampilkan jumlah produksi di sebelah kanan
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        item['jumlah_produksi']
                            .toString(), // Konversi ke String
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
    );
  }
}

class ProductAvailabilityWidget extends StatelessWidget {
  final double mediaQueryHeight;
  final double screenWidth;
  final List<Map<String, dynamic>> availabilityData;

  ProductAvailabilityWidget({
    required this.mediaQueryHeight,
    required this.screenWidth,
    required this.availabilityData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                'Available Items',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.black,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: availabilityData.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = availabilityData[index];
                  return buildAvailabilityItem(item, screenWidth);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAvailabilityItem(Map<String, dynamic> item, double screenWidth) {
    return Card(
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
                        item['jenis_produk'] ?? 'Default Category',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFFFFFFFE),
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: mediaQueryHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        item['nama_produk'] ?? 'Default Product',
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
                        item['jumlah_produk'].toString() ?? '0',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFFFFFFFE),
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w400,
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
                        'Rp. ${item['harga_produk'] ?? '0'}',
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
    );
  }
}

void main() {
  runApp(DashboardPageStaff());
}
