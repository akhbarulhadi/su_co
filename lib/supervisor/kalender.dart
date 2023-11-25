import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/supervisor/basics_example.dart';
import 'package:suco/supervisor/kalender_test.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => CalenderState();
}

class CalenderState extends State<Calendar> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
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

  // Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Product Name':
          return 'Nama Produk';
        case 'Room Name':
          return 'Nama Ruangan';
        case 'Leader Production Name':
          return 'Nama Kepala Produksi';
        case 'Product Code':
          return 'Kode Produk';
        case 'Total Production':
          return 'Jumlah Produksi';
        case 'Add Task':
          return 'Tambah Tugas';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final ThemeData themeData =
    isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final myAppBar = AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        },
      ),
      backgroundColor: Color(0xFF094067), // Mengubah warna AppBar
      elevation: 0, // Menghilangkan efek bayangan di bawah AppBar
      iconTheme: IconThemeData(color: isDarkTheme ? Colors.white : Colors.black), // Mengatur ikon (misalnya, tombol back) menjadi hitam
      title: Align(
        alignment: Alignment.center,
        child: Text(
          getTranslatedText(""),
          style: TextStyle(
            fontSize: 20.0,
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
        appBar: myAppBar,
        body: SingleChildScrollView(
          child: Container(
          decoration: BoxDecoration(
              color: Color(0xFF094067), // warna latar Card
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                  child: TextFormField(
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: getTranslatedText('Product Name'),
                      contentPadding: EdgeInsets.all(13),
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna teks label di sini
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Ubah warna garis bawah saat fokus di sini
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,),
// Tambahkan validator sesuai kebutuhan
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                  child: TextFormField(
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: getTranslatedText('Room Name'),
                      contentPadding: EdgeInsets.all(13),
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna teks label di sini
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Ubah warna garis bawah saat fokus di sini
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,),
// Tambahkan validator sesuai kebutuhan
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                  child: TextFormField(
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: getTranslatedText('Leader Production Name'),
                      contentPadding: EdgeInsets.all(13),
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna teks label di sini
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Ubah warna garis bawah saat fokus di sini
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,),
// Tambahkan validator sesuai kebutuhan
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                  child: TextFormField(
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: getTranslatedText('Product Code'),
                      contentPadding: EdgeInsets.all(13),
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna teks label di sini
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Ubah warna garis bawah saat fokus di sini
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,),
// Tambahkan validator sesuai kebutuhan
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                  child: TextFormField(
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: getTranslatedText('Total Production'),
                      contentPadding: EdgeInsets.all(13),
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna teks label di sini
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Ubah warna garis bawah saat fokus di sini
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,),
// Tambahkan validator sesuai kebutuhan
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 61, 0, 0),
                  child: Container(
                        decoration: BoxDecoration(
                          color: isDarkTheme ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                50.0), // Atur radius sudut kiri atas
                            topRight: Radius.circular(
                                50.0), // Atur radius sudut kanan atas
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16, 20, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Color(0xFF094067),
                                ),
                                child: TableCalendar(
                                  headerStyle: HeaderStyle(
                                    titleTextStyle: TextStyle(color: Colors.white), // Mengubah warna teks judul kalender menjadi putih
                                    formatButtonDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white, // Warna garis tepi
                                        width: 0.5, // Lebar garis tepi
                                      ),
                                      color: Colors.transparent, // Mengubah warna latar belakang tombol ganti format (minggu, bulan, tahun, dll.) jika diperlukan
                                    ),
                                    formatButtonTextStyle: TextStyle(
                                      color: Colors.white, // Mengubah warna teks tombol ganti format (minggu, bulan, tahun, dll.)
                                    ),
                                    leftChevronIcon: Icon(
                                      Icons.chevron_left,
                                      color: Colors.white, // Mengubah warna ikon panah kiri jika diperlukan
                                    ),
                                    rightChevronIcon: Icon(
                                      Icons.chevron_right,
                                      color: Colors.white, // Mengubah warna ikon panah kanan jika diperlukan
                                    ),
                                  ),
                                  daysOfWeekStyle: DaysOfWeekStyle(
                                    weekdayStyle: TextStyle(color: Colors.white), // Mengubah warna teks hari kerja menjadi putih
                                    weekendStyle: TextStyle(color: Colors.white), // Mengubah warna teks akhir pekan menjadi putih
                                  ),
                                  firstDay: kFirstDay,
                                  lastDay: kLastDay,
                                  focusedDay: _focusedDay,
                                  calendarFormat: _calendarFormat,
                                  calendarStyle: CalendarStyle(
                                    outsideDaysVisible: false,
                                    weekendTextStyle: TextStyle(color: Colors.white), // Mengubah warna teks hari Sabtu dan Minggu menjadi putih
                                    defaultTextStyle: TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
                                    todayTextStyle: TextStyle(color: Colors.white), // Ubah warna teks hari ini menjadi putih
                                    selectedTextStyle: TextStyle(color: Colors.white), // Ubah warna teks saat dipilih menjadi putih
                                    todayDecoration: BoxDecoration(
                                      color: Color(0xFF71C4EF), // Ganti warna latar belakang hari ini jika diperlukan
                                      shape: BoxShape.circle, // Ganti bentuk latar belakang hari ini jika diperlukan
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: Colors.blue, // Ganti warna latar belakang saat dipilih jika diperlukan
                                      shape: BoxShape.circle, // Ganti bentuk latar belakang saat dipilih jika diperlukan
                                    ),
                                  ),
                                  selectedDayPredicate: (day) {
                                    // Use `selectedDayPredicate` to determine which day is currently selected.
                                    // If this returns true, then `day` will be marked as selected.

                                    // Using `isSameDay` is recommended to disregard
                                    // the time-part of compared DateTime objects.
                                    return isSameDay(_selectedDay, day);
                                  },
                                  onDaySelected: (selectedDay, focusedDay) {
                                    if (!isSameDay(_selectedDay, selectedDay)) {
                                      // Call `setState()` when updating the selected day
                                      setState(() {
                                        _selectedDay = selectedDay;
                                        _focusedDay = focusedDay;
                                      });
                                    }
                                  },
                                  onFormatChanged: (format) {
                                    if (_calendarFormat != format) {
                                      // Call `setState()` when updating calendar format
                                      setState(() {
                                        _calendarFormat = format;
                                      });
                                    }
                                  },
                                  onPageChanged: (focusedDay) {
                                    // No need to call `setState()` here
                                    _focusedDay = focusedDay;
                                  },
                                ),
                              ),
                              SizedBox(height: bodyHeight * 0.001),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => CalendarTest()));                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 7,
                                        ),
                                        primary: Color(0xFF3DA9FC),
                                      ),
                                      child: Text(
                                        getTranslatedText('Add Task'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          height: 0,
                                        ),
                                      )
                                  ),
                                ],
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
      ),
    );
  }
}
