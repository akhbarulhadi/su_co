import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suco/api_config.dart';
import 'package:suco/kepala_produksi/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:giffy_dialog/giffy_dialog.dart';

class TableEventsExample extends StatefulWidget {
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
  bool _isDisposed = false;
  List<Map<String, dynamic>> produksiData = [];
  List<bool> isItemClicked = [];
  late TextEditingController _textController;
  late TextEditingController _textstatusController;
  late TextEditingController _textperiodController;
  List _filteredData = [];
  String selectedPeriod = "";
  String selectedStatus = "";
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    loadThemePreference();
    loadSelectedLanguage();
    loadProduksi();
    _textController = TextEditingController();
    _textstatusController = TextEditingController();
    _textperiodController = TextEditingController();
    produksiData = [];
    _filteredData = [];
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

  Future<void> loadProduksi() async {
    try {
      final response =
          await http.get(Uri.parse(ApiConfig.get_production_leader));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Add this to see the response data in the console
        setState(() {
          produksiData = List.from(data['produksi']);
          _filteredData = produksiData;
          isItemClicked = List.generate(produksiData.length, (index) => false);
          _isloading = false;
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
      // Check the previous status, must be "Sudah Dibuat" to change to "Sudah Sesuai"
      if (newStatus.toLowerCase() == 'sudah dibuat') {
        if (produksiData[index]['status_produksi'] != 'belum selesai') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Status must be "belum selesai" to change to "Sudah Dibuat".'),
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

      if (response.statusCode == 200 && mounted) {
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
                      child: Text(getTranslatedText('Tutup')),
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
        // Update production data after successfully updating the status
        await loadProduksi();
        setState(() {
          isItemClicked[index] = true; // Set the item as clicked
          // Add necessary state updates after updating data
        });
      } else if (mounted) {
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
                      child: Text(getTranslatedText('Tutup')),
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

  Future<void> _showConfirmationDialog(
      BuildContext context, int idProduksi, String newStatus, int index) async {
    if (mounted) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          bool canUpdateStatus = !isItemClicked[index];
          return AlertDialog(
            title: Text(getTranslatedText('Confirmation')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(getTranslatedText(
                      'Are you sure you want to change this production status?')),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(getTranslatedText('Yes')),
                onPressed: () async {
                  if (canUpdateStatus) {
                    await _updateStatus(context, idProduksi, newStatus, index);
                  }
                },
              ),
              TextButton(
                child: Text(getTranslatedText('Cancel')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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

  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      switch (text) {
        case 'Schedule':
          return 'Jadwal';
        case 'Activity':
          return 'Aktivitas';
        case 'Confirmation':
          return 'Konfirmasi';
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
        case 'Are you sure you want to change this production status?':
          return 'Apakah Anda yakin ingin mengubah status produksi ini?';
        case 'Yes':
          return 'Ya';
        case 'Cancel':
          return 'Batal';
        case 'already made':
          return 'sudah dibuat';
        case 'not finished yet':
          return 'belum selesai';
        case 'already appropriate':
          return 'sudah sesuai';
        case 'finished':
          return 'selesai';
        default:
          return text;
      }
    } else {
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
      iconTheme: IconThemeData(
        color: isDarkTheme ? Colors.white : Colors.black,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Align(
        alignment: Alignment.center,
        child: Text(
          getTranslatedText('Schedule'),
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
                      onChanged: (selectedItem) {
                        setState(() {
                          // Set nilai pilihan dropdown
                          selectedPeriod =
                              selectedItem ?? getTranslatedText("All");

                          // Set nilai pada search bar sesuai dengan pilihan dropdown
                          if (selectedPeriod == getTranslatedText("Daily")) {
                            _textController.text =
                                DateFormat('yyyy-MM-dd').format(DateTime.now());
                          } else if (selectedPeriod ==
                              getTranslatedText("Weekly")) {
                            // Mendapatkan tanggal awal dan akhir minggu saat ini
                            DateTime now = DateTime.now();
                            DateTime startOfWeek =
                                now.subtract(Duration(days: now.weekday - 1));
                            DateTime endOfWeek =
                                startOfWeek.add(Duration(days: 6));

                            _textController.text =
                                '${DateFormat('yyyy-MM-dd').format(startOfWeek)}/${DateFormat('yyyy-MM-dd').format(endOfWeek)}';
                          } else if (selectedPeriod ==
                              getTranslatedText("Monthly")) {
                            // Mendapatkan tanggal awal dan akhir bulan saat ini
                            DateTime now = DateTime.now();
                            DateTime startOfMonth =
                                DateTime(now.year, now.month, 1);
                            DateTime endOfMonth =
                                DateTime(now.year, now.month + 1, 1)
                                    .subtract(Duration(days: 1));

                            _textController.text =
                                '${DateFormat('yyyy-MM-dd').format(startOfMonth)}/${DateFormat('yyyy-MM-dd').format(endOfMonth)}';
                          } else if (selectedPeriod ==
                              getTranslatedText("Yearly")) {
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
                          _filteredData = produksiData.where((item) {
                            String lowerCaseQuery =
                                _textController.text.toLowerCase();

                            // Mencocokkan berdasarkan nama_perusahaan
                            bool matchesname = item['nama_produk']
                                .toLowerCase()
                                .contains(lowerCaseQuery);
                            bool matchescreated_at = item['tanggal_produksi']
                                .toLowerCase()
                                .contains(lowerCaseQuery);

                            // Mencocokkan berdasarkan updated_at dengan jangka waktu
                            bool matchescreated_at2 =
                                (item['tanggal_produksi'] != null) &&
                                    isDateInRange(
                                      DateFormat('yyyy-MM-dd').format(
                                          DateTime.parse(
                                              item['tanggal_produksi'])),
                                      lowerCaseQuery,
                                    );

                            // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                            return matchesname ||
                                matchescreated_at ||
                                matchescreated_at2;
                          }).toList();
                        });
                      },
                      selectedItem: getTranslatedText('All'),
                    ),
                  ),
                  //ini searchbar
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
                                    _filteredData = produksiData.where((item) {
                                      String lowerCaseQuery =
                                          query.toLowerCase();

                                      // Mencocokkan berdasarkan
                                      bool matchesname = item['nama_produk']
                                          .toLowerCase()
                                          .contains(lowerCaseQuery);
                                      bool matchescreated_at =
                                          item['tanggal_produksi']
                                              .toLowerCase()
                                              .contains(lowerCaseQuery);
                                      bool matchesstatus =
                                          item['status_produksi']
                                              .toLowerCase()
                                              .contains(lowerCaseQuery);

                                      // Mencocokkan berdasarkan updated_at dengan jangka waktu
                                      bool matchescreated_at2 =
                                          (item['tanggal_produksi'] != null) &&
                                              isDateInRange(
                                                DateFormat('yyyy-MM-dd').format(
                                                    DateTime.parse(item[
                                                        'tanggal_produksi'])),
                                                lowerCaseQuery,
                                              );

                                      // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                                      return matchesname ||
                                          matchescreated_at ||
                                          matchescreated_at2 ||
                                          matchesstatus;
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
                                  color:
                                      isDarkTheme ? Colors.white : Colors.black,
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
                        getTranslatedText("not finished yet"),
                        getTranslatedText('already made'),
                        getTranslatedText('already appropriate'),
                        getTranslatedText('finished'),
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
                          selectedStatus =
                              selectedItem ?? getTranslatedText("All");

                          // Set nilai pada search bar sesuai dengan pilihan dropdown
                          if (selectedStatus ==
                              getTranslatedText("not finished yet")) {
                            _textController.text = ("belum selesai");
                          } else if (selectedStatus ==
                              getTranslatedText("already made")) {
                            _textController.text = ("sudah dibuat");
                          } else if (selectedStatus ==
                              getTranslatedText("already appropriate")) {
                            _textController.text = ("sudah sesuai");
                          } else if (selectedStatus ==
                              getTranslatedText("finished")) {
                            _textController.text = ("selesai");
                          } else {
                            _textController.text = "";
                          }

                          // Lakukan filter berdasarkan pilihan dropdown
                          _filteredData = produksiData.where((item) {
                            String lowerCaseQuery =
                                _textController.text.toLowerCase();

                            // Mencocokkan berdasarkan
                            bool matchesstatus = item['status_produksi']
                                .toLowerCase()
                                .contains(lowerCaseQuery);

                            // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                            return matchesstatus;
                          }).toList();
                        });
                      },
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
                          child: Text(getTranslatedText('No Production')),
                        )
                      : ListView.builder(
                          itemCount: _filteredData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = _filteredData[index];
                            return buildProductionItem(
                                item, screenWidth, index);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductionItem(
      Map<String, dynamic> item, double screenWidth, int index) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    if (item == null) {
      print('Error: Item is null');
      return Container();
    }

    print('Item: $item');
    return GestureDetector(
      onTap: () {
        if (!isItemClicked[index]) {
          if (item['status_produksi'].toLowerCase() == 'belum selesai') {
            print('Tapped index: $index');
            _showConfirmationDialog(
                context, item['id_produksi'], 'Sudah Dibuat', index);
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
                          item['tanggal_produksi'] ?? '',
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
