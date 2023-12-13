import 'package:flutter/material.dart';
import 'package:suco/supervisor/kalender.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

class TableEventsExample extends StatefulWidget {
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
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
        _rangeStart = null; // Important to clean those
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

    // `start` or `end` could be null
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

  // Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
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

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData =
        isDarkTheme ? ThemeData.dark() : ThemeData.light();
    return MaterialApp(
      color: isDarkTheme ? Colors.black : Colors.white,
      theme: themeData, // Terapkan tema sesuai dengan preferensi tema gelap
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDarkTheme ? Colors.white : Colors.black),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            SizedBox(
              width: 45.0,
            ),
          ],
          backgroundColor:
              Colors.transparent, // Mengubah warna AppBar menjadi merah
          elevation: 0,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              "Ja",
              style: TextStyle(
                fontSize: 20.0,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => Calendar(
                    //       idproduct:
                    //           "Nilai Produk", // Ganti dengan nilai yang sesuai
                    //       jumlahPesanan:
                    //           "Jumlah Pesanan", // Ganti dengan nilai yang sesuai
                    //     ),
                    //   ),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 11,
                    ),
                    primary: Color(0xFF9766FF),
                  ),
                  child: Text(
                    "+  Add Task",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Color(0xFF094067),
                ),
                child: TableCalendar<Event>(
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                        color: Colors
                            .white), // Mengubah warna teks judul kalender menjadi putih
                    formatButtonDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white, // Warna garis tepi
                        width: 0.5, // Lebar garis tepi
                      ),
                      color: Colors
                          .transparent, // Mengubah warna latar belakang tombol ganti format (minggu, bulan, tahun, dll.) jika diperlukan
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors
                          .white, // Mengubah warna teks tombol ganti format (minggu, bulan, tahun, dll.)
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors
                          .white, // Mengubah warna ikon panah kiri jika diperlukan
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors
                          .white, // Mengubah warna ikon panah kanan jika diperlukan
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                        color: Colors
                            .white), // Mengubah warna teks hari kerja menjadi putih
                    weekendStyle: TextStyle(
                        color: Colors
                            .white), // Mengubah warna teks akhir pekan menjadi putih
                  ),
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  rangeSelectionMode: _rangeSelectionMode,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                        color: Colors
                            .white), // Mengubah warna teks hari Sabtu dan Minggu menjadi putih
                    defaultTextStyle: TextStyle(
                        color: Colors.white), // Ubah warna teks menjadi putih
                    todayTextStyle: TextStyle(
                        color: Colors
                            .white), // Ubah warna teks hari ini menjadi putih
                    selectedTextStyle: TextStyle(
                        color: Colors
                            .white), // Ubah warna teks saat dipilih menjadi putih
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
                  onDaySelected: _onDaySelected,
                  onRangeSelected: _onRangeSelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              const SizedBox(height: 25.0),
              Expanded(
                child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(12.0),
                            color: Color(0xFF094067),
                          ),
                          child: ListTile(
                            onTap: () => print('${value[index]}'),
                            title: Text('${value[index]}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
