import 'package:flutter/material.dart';
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
        case 'Schedule':
          return 'Jadwal';
        case 'Date':
          return 'Tanggal';
        case 'Activity':
          return 'Aktivitas';
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
    final ThemeData themeData = isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    final myAppBar = AppBar(
      leading: IconButton(
        icon: Icon(
            Icons.arrow_back,
            color: isDarkTheme ? Colors.white : Colors.black),
        onPressed: () async {
          Navigator.of(context).pop();
        },
      ),
      actions: <Widget>[
        SizedBox(width: 45.0,),
      ],
      backgroundColor: Colors.transparent, // Mengubah warna AppBar menjadi merah
      elevation: 0,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          getTranslatedText('Schedule'),
          style: TextStyle(
            fontSize: 20.0,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
    final bodyHeight = mediaQueryHeight - myAppBar.preferredSize.height - MediaQuery.of(context).padding.top;
    return MaterialApp(
      color: isDarkTheme ? Colors.black : Colors.white,
      theme: themeData, // Terapkan tema sesuai dengan preferensi tema gelap
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        appBar: myAppBar,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                    16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: mediaQueryWidth * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 0, 35, 0),
                                child: Text(
                                  getTranslatedText('Date'),
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: isDarkTheme ? Colors.white54 : Colors.black38,
                                  ),
                                ),
                              ),
                              Text(
                                getTranslatedText('Activity'),
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: isDarkTheme ? Colors.white54 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: bodyHeight * 0.02),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '14 Juni',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: isDarkTheme ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    Container(
                                      width: mediaQueryWidth * 0.65,
                                      height: bodyHeight * 0.17,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF094067), // warna latar Card
                                        borderRadius: BorderRadius.circular(20),
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
                                                          .fromSTEB(0, 0, 0, 0),
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
                                                          .fromSTEB(0, 0, 0, 0),
                                                      child: Text(
                                                        'Kode Produksi',
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
                                                SizedBox(height: bodyHeight * 0.01,),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsetsDirectional
                                                          .fromSTEB(0, 0, 0, 0),
                                                      child: Icon(
                                                        Icons.pin_drop,
                                                        color: Color(0xFFFFFFFE),
                                                        size: 18,
                                                      ),
                                                    ),
                                                    SizedBox( width: mediaQueryWidth * 0.02,),
                                                    Padding(
                                                      padding: EdgeInsetsDirectional
                                                          .fromSTEB(0, 0, 0, 0),
                                                      child: Text(
                                                        'Ruang Produksi Lane-001',
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
                                                          .fromSTEB(0, 0, 0, 0),
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
                                                          .fromSTEB(0, 0, 0, 0),
                                                      child: Text(
                                                        'Damar',
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
                                                          .fromSTEB(0, 0, 0, 0),
                                                      child: Text(
                                                        '10 pcs',
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
                                  ],
                                ),
                              ),
                              SizedBox(height: bodyHeight * 0.01),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

        ),
      ),
    );
  }
}
