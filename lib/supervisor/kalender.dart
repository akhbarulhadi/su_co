import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:suco/supervisor/dashboard.dart';
import 'dart:convert';
import '../utils.dart';
import 'kalender_test.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:suco/supervisor/jadwal.dart';
import 'package:intl/intl.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class Calendar extends StatefulWidget {
  final int idproduct;
  final String productName;
  final String jumlahPesanan;

  const Calendar({
    Key? key,
    required this.idproduct,
    required this.productName,
    required this.jumlahPesanan,
  }) : super(key: key);

  @override
  State<Calendar> createState() => CalenderState();
}

class CalenderState extends State<Calendar> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController productNameprodukController = TextEditingController();
  TextEditingController namaRuanganController = TextEditingController();
  TextEditingController jumlahPesananController = TextEditingController();
  bool isDataBenar = false;
  bool isNumeric(String value) {
    return int.tryParse(value) != null;
  }

  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> listuser = [];
  String selectedLeader = '';
  bool shouldShowProductName() {
    // Add your condition here
    // For example, if you want to show the product name when the selected leader is not empty
    return selectedLeader.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    loadThemePreference();
    loadSelectedLanguage();
    loadLeaders();
    if (listuser.isNotEmpty) {
      selectedLeader = listuser[0]['id_user'].toString();
    }
    productNameController.text = widget.idproduct.toString();
    productNameprodukController.text = widget.productName;
    jumlahPesananController.text = widget.jumlahPesanan;
  }

  Future<void> loadLeaders() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.leaders));
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          listuser = data['leaders'];
          if (listuser.isNotEmpty) {
            selectedLeader = listuser[0]['id_user'].toString();
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendDataToDatabase() async {
    try {
      print("Product Name: ${productNameController.text}");
      print("Selected Leader: $selectedLeader");
      print("Jumlah Pesanan: ${jumlahPesananController.text}");

      int? idproduct = int.tryParse(productNameController.text);
      int? leaderId = int.tryParse(selectedLeader);
      int? orderAmount = int.tryParse(jumlahPesananController.text);

      if (idproduct != null && leaderId != null && orderAmount != null) {
        String formattedDate =
            _selectedDay?.toIso8601String()?.split('T')[0] ?? '';

        final response = await http.post(
          Uri.parse(ApiConfig.produksi),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id_produk": idproduct,
            "id_user": leaderId,
            "nama_ruangan": namaRuanganController.text,
            "jumlah_produksi": orderAmount,
            "tanggal_produksi": formattedDate,
          }),
        );

        if (response.statusCode == 201) {
          print("Jadwal Produksi berhasil dibuat!");
          print("Response: ${response.body}");
          setState(() {
            isDataBenar = false; // Set data ke false
            namaRuanganController.clear(); // Kosongkan form
          });
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
                  getTranslatedText('Fill in the data again ?'),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DashboardPageSupervisor(),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TableEventsExample(),
                            ),
                          );
                        },
                        child: Text(getTranslatedText('No')),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 40),
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(getTranslatedText('Yes')),
                        style: TextButton.styleFrom(
                          minimumSize: Size(100, 40),
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                            side: BorderSide(
                              color: Color(0xFF3DA9FC), // Warna border
                              width: 1.0, // Lebar border
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        } else {
          print("Gagal membuat Jadwal Produksi.");
          print("Response Status Code: ${response.statusCode}");
          print("Response Body: ${response.body}");
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
                  getTranslatedText('Data cannot be empty'),
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
    } catch (e) {
      print(e);
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

  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      switch (text) {
        case 'Product Name':
          return 'Nama Produk';
        case 'Room Name':
          return 'Nama Ruangan';
        case 'Leader Production Name':
          return 'Nama Kepala Produksi';
        case 'Total Production':
          return 'Jumlah Produksi';
        case 'Add Task':
          return 'Tambah Tugas';
        case 'Successfully':
          return 'Berhasil';
        case 'Close':
          return 'Tutup';
        case 'Failed':
          return 'Gagal';
        case 'Fill in the data again ?':
          return 'Isi data lagi ?';
        case 'No':
          return 'Tidak';
        case 'Yes':
          return 'Ya';
        case 'Data cannot be empty':
          return 'Data tidak boleh kosong';
        case 'Fill in the data':
          return 'Isi datanya';
        case 'Must contain numbers only':
          return 'Harus mengandung angka saja';
        case '':
          return '';
        case '':
          return '';
        default:
          return text;
      }
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String idproduct = widget.idproduct.toString();
    final String productName = widget.productName;
    final String jumlahPesanan = widget.jumlahPesanan;
    final screenWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final ThemeData themeData =
        isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final myAppBar = AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Color(0xFF094067),
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
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
        appBar: myAppBar,
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF094067),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                    child: TextFormField(
                      readOnly: true, // Menggantikan enabled: false
                      obscureText: false,
                      controller: productNameprodukController,
                      decoration: InputDecoration(
                        labelText: getTranslatedText('Product Name'),
                        contentPadding: EdgeInsets.all(13),
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
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
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                    child: TextFormField(
                      obscureText: false,
                      controller: namaRuanganController,
                      decoration: InputDecoration(
                        labelText: getTranslatedText('Room Name'),
                        contentPadding: EdgeInsets.all(13),
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
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
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                    child: Form(
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText:
                              getTranslatedText('Leader Production Name'),
                          contentPadding: EdgeInsets.all(13),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        dropdownColor: Color(
                            0xFF094067), // Warna latar belakang dropdown saat dibuka
                        value: selectedLeader,
                        items: listuser.map((leader) {
                          return DropdownMenuItem(
                            value: leader['id_user'].toString(),
                            child: Row(
                              children: [
                                Text(
                                  'ID: ${leader['id_user']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${leader['nama']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          print("Selected Leader: $newValue");
                          setState(() {
                            selectedLeader = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return getTranslatedText('Select the leader first');
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      controller: jumlahPesananController,
                      decoration: InputDecoration(
                        labelText: getTranslatedText('Total Production'),
                        contentPadding: EdgeInsets.all(13),
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return getTranslatedText('Fill in the data');
                        } else if (!isNumeric(value)) {
                          return getTranslatedText('Must contain numbers only');
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 61, 0, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkTheme ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          topRight: Radius.circular(50.0),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 20, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Color(0xFF094067),
                              ),
                              child: Column(
                                children: [
                                  Visibility(
                                    visible: false,
                                    child: Text(
                                      'Tanggal Dipilih: ${_selectedDay?.toLocal()}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  TableCalendar(
                                    headerStyle: HeaderStyle(
                                      titleTextStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      formatButtonDecoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 0.5,
                                        ),
                                        color: Colors.transparent,
                                      ),
                                      formatButtonTextStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      leftChevronIcon: Icon(
                                        Icons.chevron_left,
                                        color: Colors.white,
                                      ),
                                      rightChevronIcon: Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                      ),
                                    ),
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                      weekdayStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      weekendStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    firstDay: DateTime.now(),
                                    lastDay: kLastDay,
                                    focusedDay: _focusedDay,
                                    calendarFormat: _calendarFormat,
                                    calendarStyle: CalendarStyle(
                                      outsideDaysVisible: false,
                                      weekendTextStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      defaultTextStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      todayTextStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      selectedTextStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      todayDecoration: BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      selectedDecoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    selectedDayPredicate: (day) {
                                      return isSameDay(_selectedDay, day);
                                    },
                                    onDaySelected: (selectedDay, focusedDay) {
                                      if (!isSameDay(
                                          _selectedDay, selectedDay)) {
                                        setState(() {
                                          _selectedDay = selectedDay;
                                          _focusedDay = focusedDay;
                                        });
                                      }
                                    },
                                    onFormatChanged: (format) {
                                      setState(() {
                                        _calendarFormat = format;
                                      });
                                    },
                                    onPageChanged: (focusedDay) {
                                      _focusedDay = focusedDay;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: bodyHeight * 0.001),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      sendDataToDatabase();
                                    }
                                  },
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
                                  ),
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
      ),
    );
  }
}
