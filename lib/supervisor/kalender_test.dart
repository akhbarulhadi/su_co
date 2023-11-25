import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/supervisor/basics_example.dart';
import 'package:table_calendar/table_calendar.dart';

import 'event.dart';

class CalendarTest extends StatefulWidget {
  const CalendarTest({super.key});

  @override
  State<CalendarTest> createState() => CalenderState();
}

class CalenderState extends State<CalendarTest> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Event>> events = {};
  TextEditingController _eventController = TextEditingController();
  TextEditingController _roomnameController = TextEditingController();
  TextEditingController _leadernameController = TextEditingController();
  TextEditingController _productcodeController = TextEditingController();
  TextEditingController _totalproductionController = TextEditingController();
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _selectedEvents =
        ValueNotifier(_getEventsForDay(_selectedDay ?? DateTime.now()));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
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

  // Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Client Data':
          return 'Data Klien';
        case 'Company Name':
          return 'Nama Perusahaan';
        case 'Client Name':
          return 'Nama Klien';
        case 'Address':
          return 'Alamat';
        case 'Continue':
          return 'Selanjutnya';
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

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final ThemeData themeData =
        isDarkTheme ? ThemeData.dark() : ThemeData.dark();
    final myAppBar = AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        },
      ),
      backgroundColor: Colors.blue, // Mengubah warna AppBar
      elevation: 0, // Menghilangkan efek bayangan di bawah AppBar
      iconTheme: IconThemeData(
          color: isDarkTheme
              ? Colors.white
              : Colors
                  .black), // Mengatur ikon (misalnya, tombol back) menjadi hitam
      title: Align(
        alignment: Alignment.center,
        child: Text(
          getTranslatedText("Coba Kalender"),
          style: TextStyle(
            fontSize: 20.0,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    scrollable: true,
                    title: Text("Event Name"),
                    content: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          TextField(
                            controller: _eventController,
                            decoration: InputDecoration(
                              labelText: 'Product Name',
                            ),
                          ),
                          TextField(
                            controller: _roomnameController,
                            decoration: InputDecoration(
                              labelText: 'Room Name',
                            ),
                          ),
                          TextField(
                            controller: _leadernameController,
                            decoration: InputDecoration(
                              labelText: 'Leader Name',
                            ),
                          ),
                          TextField(
                            controller: _productcodeController,
                            decoration: InputDecoration(
                              labelText: 'Product Code',
                            ),
                          ),
                          TextField(
                            controller: _totalproductionController,
                            decoration: InputDecoration(
                              labelText: 'Total Product',
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          final newEvent = Event(
                            _eventController.text,
                            _roomnameController.text,
                            _leadernameController.text,
                            _productcodeController.text,
                            _totalproductionController.text,
                          );
                          events[_selectedDay!] = [
                            ...events[_selectedDay!] ?? [],
                            newEvent
                          ];
                          _eventController.clear();
                          _roomnameController.clear();
                          _leadernameController.clear();
                          _productcodeController.clear();
                          _totalproductionController.clear();
                          _eventController
                              .clear(); // Membersihkan teks yang diinput
                          Navigator.of(context).pop();
                          _selectedEvents.value =
                              _getEventsForDay(_selectedDay!);
                        },
                        child: Text("Submit"),
                      ),
                    ],
                  );
                });
          },
          child: Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Selected Day + " + _selectedDay.toString().split(" ")[0],
                style: TextStyle(color: Colors.black),
              ),
              Container(
                decoration: BoxDecoration(),
                child: TableCalendar(
                  locale: "en_US",
                  rowHeight: 43,
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                        color: Colors
                            .black), // Mengubah warna teks judul kalender menjadi putih
                    formatButtonDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black, // Warna garis tepi
                        width: 0.5, // Lebar garis tepi
                      ),
                      color: Colors
                          .transparent, // Mengubah warna latar belakang tombol ganti format (minggu, bulan, tahun, dll.) jika diperlukan
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors
                          .black, // Mengubah warna teks tombol ganti format (minggu, bulan, tahun, dll.)
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors
                          .blue, // Mengubah warna ikon panah kiri jika diperlukan
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors
                          .blue, // Mengubah warna ikon panah kanan jika diperlukan
                    ),
                  ),
                  availableGestures: AvailableGestures.all,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  onDaySelected: _onDaySelected,
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                        color: Colors
                            .black), // Mengubah warna teks hari Sabtu dan Minggu menjadi putih
                    defaultTextStyle: TextStyle(
                        color: Colors.black), // Ubah warna teks menjadi putih
                    todayTextStyle: TextStyle(
                        color: Colors
                            .black), // Ubah warna teks hari ini menjadi putih
                    selectedTextStyle: TextStyle(
                        color: Colors
                            .black), // Ubah warna teks saat dipilih menjadi putih
                    todayDecoration: BoxDecoration(
                      color: Color(
                          0xFF71C4EF), // Ganti warna latar belakang hari ini jika diperlukan
                      shape: BoxShape
                          .circle, // Ganti bentuk latar belakang hari ini jika diperlukan
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors
                          .blue, // Ganti warna latar belakang saat dipilih jika diperlukan
                      shape: BoxShape
                          .circle, // Ganti bentuk latar belakang saat dipilih jika diperlukan
                    ),
                  ),
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
              SizedBox(
                height: 8.0,
              ),
              Expanded(
                child: ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            final event = value[index]; // Akses objek Event
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  event.eventName,
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
                                                  '',
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
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  event.productCode,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFFFFFFFE),
                                                    fontSize: screenWidth *
                                                        0.04, // Ukuran teks pada tombol
                                                    fontWeight:
                                                    FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox( height: bodyHeight * 0.02,),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Icon(
                                                  Icons.pin_drop,
                                                  color: Color(0xFFFFFFFE),
                                                  size: 18,
                                                ),
                                              ),
                                              SizedBox( width: mediaQueryWidth * 0.02,),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  event.roomName,
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
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Container(
                                                  width: mediaQueryWidth * 0.04,
                                                  height: bodyHeight * 0.04,
                                                  child: Image(
                                                    image: AssetImage('lib/assets/user.png'),
                                                  ),
                                                ),
                                              ),
                                              SizedBox( width: mediaQueryWidth * 0.02,),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  event.leaderName,
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
                                                  event.totalProduction,
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
                                            ],
                                          ),
                                          SizedBox( height: bodyHeight * 0.01,),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            );
                          });
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
