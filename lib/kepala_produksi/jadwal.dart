import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suco/api_config.dart';
import 'package:suco/kepala_produksi/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils.dart';

class TableEventsExample extends StatefulWidget {
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
  List<Map<String, dynamic>> produksiData = [];
  late TextEditingController _textController;
  List<bool> isItemClicked = [];

  @override
  void initState() {
    super.initState();
    loadThemePreference();
    loadSelectedLanguage();
    loadProduksi();
    _textController = TextEditingController();
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

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  Future<void> loadProduksi() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.jadwal_produksi));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Add this to see the response data in the console
        setState(() {
          produksiData = List.from(data['produksi']);
          isItemClicked = List.generate(produksiData.length, (index) => false);

          produksiData.forEach((item) {
            item['tanggal_produksi'] = _formatDate(item['tanggal_produksi']);
          });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status successfully updated'),
            duration: Duration(seconds: 2),
          ),
        );

        // Update production data after successfully updating the status
        await loadProduksi();
        setState(() {
          isItemClicked[index] = true; // Set the item as clicked
          // Add necessary state updates after updating data
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, int idProduksi, String newStatus, int index) async {
    if (mounted) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          bool canUpdateStatus = !isItemClicked[index];
          return AlertDialog(
            title: Text(getTranslatedText('Confirmation')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(getTranslatedText(
                      'Are you sure you want to change the production status?')),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(getTranslatedText('Yes')),
                onPressed: () async {
                  if (canUpdateStatus) {
                    await _updateStatus(context, idProduksi, newStatus, index);
                    Navigator.of(context).pop();
                  }
                },
              ),
              TextButton(
                child: Text(getTranslatedText('Cancle')),
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

  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      switch (text) {
        case 'Schedule':
          return 'Jadwal';
        case 'Activity':
          return 'Aktivitas';
        case 'Confirmation':
          return 'Konfirmasi';
        case 'Are you sure you want to change the production status?':
          return 'Apakah Anda yakin ingin mengubah status produksi?';
        case 'Yes':
          return 'Ya';
        case 'Cancle':
          return 'Batal';
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
                  Container(
                    width: mediaQueryWidth * 0.25,
                    height: bodyHeight * 0.048,
                    decoration: BoxDecoration(
                      color: isDarkTheme ? Colors.white24 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                        width: 1,
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
                                  : Color(0xFF8B9BA8),
                              size: 15,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: TextFormField(
                                controller: _textController,
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
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.normal,
                                ),
                                validator: (value) {
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
                        color: Colors.transparent,
                        width: 0.5,
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
                        disabledItemFn: (String s) =>
                            s.startsWith(getTranslatedText('Finished')),
                      ),
                      items: [
                        getTranslatedText("All"),
                        getTranslatedText("Cancelled"),
                        getTranslatedText("Finished"),
                        getTranslatedText('Waiting'),
                      ],
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          labelText: getTranslatedText("Select Status"),
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
            SizedBox(height: bodyHeight * 0.03),
            Expanded(
              child: produksiData.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: produksiData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = produksiData[index];
                        return buildProductionItem(item, screenWidth);
                      },
                    ),
            ),
          ],
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
      return Container();
    }

    print('Item: $item');
    return InkWell(
      onTap: () {
        _showConfirmationDialog(
          context,
          item['id_produksi'], // Assuming 'id_produksi' is the correct key
          'newStatus', // Replace 'newStatus' with the actual new status
          produksiData.indexOf(item),
        );
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
                          item['status_produksi'] ?? '',
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
