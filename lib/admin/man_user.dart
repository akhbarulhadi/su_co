import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:suco/admin/add_user.dart';
import 'package:suco/admin/sidebar.dart';
import 'package:suco/admin/setting.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  UserManagementPageState createState() => UserManagementPageState();
}

class UserManagementPageState extends State<UserManagementPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  TextEditingController passwordController = TextEditingController();
  late FocusNode _unfocusNode;
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List _listdata = [];
  List _filteredData = [];
  bool _isloading = true;
  String previousStatus = '';

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
    _textController = TextEditingController();
    _unfocusNode = FocusNode();
    _getdata();
    _listdata = [];
    _filteredData = [];
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
    _textController.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }

Future<void> _updateUserStatus(BuildContext context, int userId, String newStatus) async {
  try {
    final response = await http.post(
      Uri.parse(ApiConfig.status_user),
      body: {
        'id_user': userId.toString(),
        'status': newStatus,
      },
    );

    if (response.statusCode == 200) {
      print('Status update successful');
      Navigator.of(context).pop();
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
      await _getdata();
      // Handle success, if needed
    } else {
      print('Failed to update status. Status code: ${response.statusCode}');
      Navigator.of(context).pop();
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
      // Handle failure, if needed
    }
  } catch (e) {
    print('Error: $e');
    // Handle error
  }
}


 Future<void> _showStatusChangeDialog(BuildContext context, int index, int userId) async {
    String selectedStatus = _filteredData[index]['status'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change User Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select new status:'),
              DropdownButton<String>(
                value: selectedStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });
                },
                items: ['aktif', 'tidak-aktif'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Memeriksa apakah status berubah sebelum pembaruan
                if (selectedStatus != _filteredData[index]['status']) {
                  // Print status yang baru di terminal
                  // print('User ID: $userId - New Status: $selectedStatus');
                }

                _updateUserStatus(context, userId, selectedStatus);
                },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetPassword(
      BuildContext context, int index, String newStatus) async {
    final response = await http.post(
      Uri.parse(ApiConfig.reset_password),
      body: {
        'id_user': _listdata[index]['id_user'].toString(),
        'password': newStatus,
      },
    );

    if (response.statusCode == 200) {
      // Status berhasil diperbarui
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
      print('berhasil');
    } else {
      // Gagal memperbarui status
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
      print('gagal');
    }
  }

  Future _getdata() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.users),
      );
      print(response.body); // Cetak respons ke konsol

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Cetak data ke konsol
        setState(() {
          _listdata = data['users'];
          _filteredData = _listdata;
          _isloading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

// Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'User Management':
          return 'Manajemen Pengguna';
        case 'Time Period':
          return 'Jangka Waktu';
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
        case 'Line':
          return 'Barisan';
        case '10 Line':
          return '10 Baris';
        case '20 Line':
          return '20 Baris';
        case '30 Line':
          return '30 Baris';
        case '40 Line':
          return '40 Baris';
        case '+ User':
          return '+ Pengguna';
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
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final ThemeData themeData =
        isDarkTheme ? ThemeData.dark() : ThemeData.light();
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
          getTranslatedText("User Management"),
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
          drawer: SidebarDrawer(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: mediaQueryWidth * 0.28,
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
                          getTranslatedText("10 Line"),
                          getTranslatedText("20 Line"),
                          getTranslatedText('30 Line'),
                          getTranslatedText('40 Line')
                        ],
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            labelText: getTranslatedText("Line"),
                            // hintText: "waktu in menu mode",
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
                      width: mediaQueryWidth * 0.35,
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
                                      _filteredData = _listdata.where((item) {
                                        String lowerCaseQuery =
                                            query.toLowerCase();

                                        // Mencocokkan berdasarkan
                                        bool matchesname =
                                            item['nama_perusahaan']
                                                .toLowerCase()
                                                .contains(lowerCaseQuery);
                                        bool matchescreated_at =
                                            item['created_at']
                                                .toLowerCase()
                                                .contains(lowerCaseQuery);
                                        bool matchesstatus =
                                            item['status_pesanan']
                                                .toLowerCase()
                                                .contains(lowerCaseQuery);

                                        // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                                        return matchesname ||
                                            matchescreated_at ||
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => AddUser()));
                      },
                      child: Text(
                        getTranslatedText('+ User'),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(110, 28),
                        padding: EdgeInsets.all(10),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        primary: Color(0xFF3DA9FC),
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
                              TextEditingController namaController =
                                  TextEditingController(
                                      text: _filteredData[index]['nama']
                                          .toString());
                              TextEditingController idStaffController =
                                  TextEditingController(
                                      text: _filteredData[index]['id_staff']
                                          .toString());
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        title: Center(
                                          child: Text(
                                              getTranslatedText('User Detail')),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Visibility(
                                                  visible: false,
                                                  child: TextField(
                                                    controller:
                                                        idStaffController,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          getTranslatedText(
                                                              'Client Name'),
                                                    ),
                                                    enabled: false,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () async {
                                                    await _resetPassword(
                                                        context,
                                                        index,
                                                        idStaffController.text);
                                                  },
                                                  icon: Icon(
                                                      Icons.lock_reset_rounded),
                                                ),
                                              ],
                                            ),
                                            TextField(
                                              controller: namaController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                labelText: getTranslatedText(
                                                    'Client Name'),
                                              ),
                                              enabled: false,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  _filteredData[index]['roles'],
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenWidth * 0.028,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                Text(
                                                  _filteredData[index]
                                                      ['status'],
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenWidth * 0.028,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _showStatusChangeDialog(
                                                    context,
                                                    index,
                                                    _filteredData[index]
                                                        ['id_user']);
                                              },
                                              child: Text('Change Status'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
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
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16, 5, 16, 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            CircleAvatar(
                                              radius: mediaQueryWidth * 0.045,
                                              backgroundColor:
                                                  Color(0xFF7839CD),
                                              child: _filteredData[index]
                                                          ['foto'] !=
                                                      null
                                                  ? CircleAvatar(
                                                      radius: mediaQueryWidth *
                                                          0.042,
                                                      backgroundImage:
                                                          NetworkImage(
                                                        '${ApiConfig.baseURL}/storage/foto/${_filteredData[index]['foto']}',
                                                      ),
                                                    )
                                                  : CircleAvatar(
                                                      radius: mediaQueryWidth *
                                                          0.042,
                                                      backgroundColor:
                                                          Colors.grey,
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
                                                    Text(
                                                      _filteredData[index]
                                                          ['nama'],
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        color: Colors.white,
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 4, 0, 0),
                                                      child: Text(
                                                        _filteredData[index]
                                                            ['email'],
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          color: Colors.white,
                                                          fontSize:
                                                              screenWidth *
                                                                  0.028,
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
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            _filteredData[index]
                                                                ['no_tlp'],
                                                            style: TextStyle(
                                                              fontFamily: 'Inter',
                                                              color: Colors.white,
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.028,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                          ),
                                                          Text(
                                                            _filteredData[index]
                                                            ['status'],
                                                            style: TextStyle(
                                                              fontFamily: 'Inter',
                                                              color: Colors.white,
                                                              fontSize:
                                                              screenWidth *
                                                                  0.028,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
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