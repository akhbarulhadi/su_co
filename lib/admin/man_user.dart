import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late TextEditingController _textstatusController;
  late TextEditingController _textperiodController;
  TextEditingController passwordController = TextEditingController();
  late FocusNode _unfocusNode;
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  List _listdata = [];
  List _filteredData = [];
  bool _isloading = true;
  String previousStatus = '';
  String selectedPeriod = "";
  String selectedStatus = "";

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
    _textstatusController = TextEditingController();
    _textperiodController = TextEditingController();
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
    _textstatusController.dispose();
    _textperiodController.dispose();
    _textController.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }

  bool isDateInRange(String date, String dateRange) {
    List<String> dateRangeArray = dateRange.split('/');
    if (dateRangeArray.length == 2) {
      String startDateString = dateRangeArray[0].trim();
      String endDateString = dateRangeArray[1].trim();

      DateTime startDate = DateTime.parse(startDateString);
      DateTime endDate = DateTime.parse(endDateString).add(Duration(days: 1));

      DateTime dateToCheck = DateTime.parse(date);

      return dateToCheck.isAfter(startDate.subtract(Duration(days: 1))) && dateToCheck.isBefore(endDate);
    }
    return false;
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
        return StatefulBuilder(
          // StatefulBuilder digunakan untuk memperbarui UI dalam dialog
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(getTranslatedText('Change User Status')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(getTranslatedText('Select new status:')),
                  Row(
                    children: [
                      Radio(
                        value: 'aktif.',
                        groupValue: selectedStatus,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                          });
                        },
                      ),
                      Text(getTranslatedText('active')),
                      Radio(
                        value: 'tidak-aktif',
                        groupValue: selectedStatus,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                          });
                        },
                      ),
                      Text(getTranslatedText('not active')),
                    ],
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Memeriksa apakah status berubah sebelum pembaruan
                        if (selectedStatus != _filteredData[index]['status']) {
                          // Print status yang baru di terminal
                          // print('User ID: $userId - New Status: $selectedStatus');
                        }

                        _updateUserStatus(context, userId, selectedStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 40),
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19),
                        ),
                      ),
                      child: Text(getTranslatedText('Save')),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(getTranslatedText('Cancel')),
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
        case 'Search...':
          return 'Cari...';
        case 'User Name':
          return 'Nama Pengguna';
        case 'Address':
          return 'Alamat';
        case 'Gender':
          return 'Jenis Kelamin';
        case 'Role':
          return 'Peran';
        case 'Account Status':
          return 'Status Akun';
        case 'User Detail':
          return 'Detail Pengguna';
        case 'Change Status':
          return 'Ganti Status';
        case 'Change User Status':
          return 'Ganti Status User';
        case 'Select new status:':
          return 'Pilih status baru:';
        case 'active':
          return 'aktif';
        case 'not active':
          return 'tidak aktif';
        case 'Save':
          return 'Simpan';
        case 'Cancel':
          return 'Batal';
        case 'Select Status':
          return 'Pilih Status';
        case 'Successfully':
          return 'Berhasil';
        case 'Close':
          return 'Tutup';
        case 'Failed':
          return 'Gagal';
        case 'No User':
          return 'Tidak ada pengguna';
        case 'Reset Password':
          return 'Reset Kata Sandi';
        case 'The password will be reset to default':
          return 'Password akan di reset ke awal';
        case 'Yes':
          return 'Ya';
        case 'No':
          return 'Tidak';
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

  String getTranslatedDatabase(String status) {
    if (selectedLanguage == 'ENG') {
      // Teks dalam bahasa Indonesia
      switch (status) {
        case 'aktif':
          return 'active';
        case 'tidak aktif':
          return 'not active';
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
                    //ini dropdown status
                    Container(
                      width: mediaQueryWidth * 0.28,
                      height: bodyHeight * 0.060,
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
                          getTranslatedText("active"),
                          getTranslatedText('not active'),
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
                            selectedStatus = selectedItem ?? getTranslatedText("All");

                            // Set nilai pada search bar sesuai dengan pilihan dropdown
                            if (selectedStatus == getTranslatedText("active")) {
                              _textstatusController.text = ("aktif.");
                            } else if (selectedStatus == getTranslatedText("not active")) {
                              _textstatusController.text = ("tidak-aktif");
                            } else {
                              _textstatusController.text = "";
                            }

                            // Lakukan filter berdasarkan pilihan dropdown
                            _filteredData = _listdata.where((item) {
                              String lowerCaseQuery = _textstatusController.text.toLowerCase();

                              // Mencocokkan berdasarkan
                              bool matchesstatus = item['status'].toLowerCase().contains(lowerCaseQuery);

                              // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                              return matchesstatus;
                            }).toList();
                          });
                        },
                        selectedItem: getTranslatedText("All"),
                      ),
                    ),
                    //ini searchbar untuk status
                    Visibility(
                      visible: false,
                      child: Container(
                        width: mediaQueryWidth * 0.38,
                        height: bodyHeight * 0.060,
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
                                    controller: _textstatusController,
                                    onChanged: (query) {
                                      setState(() {
                                        _filteredData = _listdata.where((item) {
                                          String lowerCaseQuery = query.toLowerCase();

                                          // Mencocokkan berdasarkan
                                          bool matchesname = item['nama'].toLowerCase().contains(lowerCaseQuery);
                                          bool matchesroles = item['roles'].toLowerCase().contains(lowerCaseQuery);
                                          bool matchescreated_at = item['created_at'].toLowerCase().contains(lowerCaseQuery);
                                          bool matchesstatus = item['status'].toLowerCase().contains(lowerCaseQuery);

                                          // Mencocokkan berdasarkan updated_at dengan jangka waktu
                                          bool matchescreated_at2 = (item['created_at'] != null) &&
                                              isDateInRange(
                                                DateFormat('yyyy-MM-dd').format(DateTime.parse(item['created_at'])),
                                                lowerCaseQuery,
                                              );

                                          // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                                          return matchesname || matchescreated_at || matchescreated_at2 || matchesstatus || matchesroles;
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
                    ),
                    //ini searchbar
                    Container(
                      width: mediaQueryWidth * 0.38,
                      height: bodyHeight * 0.060,
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
                                        String lowerCaseQuery = query.toLowerCase();

                                        // Mencocokkan berdasarkan
                                        bool matchesname = item['nama'].toLowerCase().contains(lowerCaseQuery);
                                        bool matchesroles = item['roles'].toLowerCase().contains(lowerCaseQuery);
                                        bool matchescreated_at = item['created_at'].toLowerCase().contains(lowerCaseQuery);
                                        bool matchesstatus = item['status'].toLowerCase().contains(lowerCaseQuery);

                                        // Mencocokkan berdasarkan updated_at dengan jangka waktu
                                        bool matchescreated_at2 = (item['created_at'] != null) &&
                                            isDateInRange(
                                              DateFormat('yyyy-MM-dd').format(DateTime.parse(item['created_at'])),
                                              lowerCaseQuery,
                                            );

                                        // Mengembalikan true jika ada kecocokan berdasarkan nama_perusahaan atau updated_at
                                        return matchesname || matchescreated_at || matchescreated_at2 || matchesstatus || matchesroles;
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
                        minimumSize: Size(100, 18),
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
                            child: Text(getTranslatedText('No User')),
                          )
                        : ListView.builder(
                            itemCount: _filteredData.length,
                            itemBuilder: ((context, index) {
                              TextEditingController idStaffController =
                                  TextEditingController(
                                      text: _filteredData[index]['id_staff']
                                          .toString());
                              TextEditingController namaController =
                              TextEditingController(
                                  text: _filteredData[index]['nama']
                                      .toString());
                              TextEditingController notelpController =
                              TextEditingController(
                                  text: _filteredData[index]['no_tlp']
                                      .toString());
                              TextEditingController alamatController =
                              TextEditingController(
                                  text: _filteredData[index]['alamat']
                                      .toString());
                              TextEditingController emailController =
                              TextEditingController(
                                  text: _filteredData[index]['email']
                                      .toString());
                              TextEditingController rolesController =
                              TextEditingController(
                                  text: _filteredData[index]['roles']
                                      .toString());
                              TextEditingController jkController =
                              TextEditingController(
                                  text: _filteredData[index]['jenis_kelamin']
                                      .toString());
                              TextEditingController statusController =
                              TextEditingController(
                                  text: _filteredData[index]['status']
                                      .toString().replaceAll('.', ''));
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
                                        content: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                controller: idStaffController,
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Id Staff'),
                                                ),
                                                enabled: false,
                                              ),
                                              TextField(
                                                controller: namaController,
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'User Name'),
                                                ),
                                                enabled: false,
                                              ),
                                              TextField(
                                                controller: notelpController,
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'No Telp'),
                                                ),
                                                enabled: false,
                                              ),
                                              TextField(
                                                controller: alamatController,
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Address'),
                                                ),
                                                enabled: false,
                                              ),
                                              TextField(
                                                controller: emailController,
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Email'),
                                                ),
                                                enabled: false,
                                              ),
                                              TextField(
                                                controller: jkController,
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Gender'),
                                                ),
                                                enabled: false,
                                              ),
                                              TextField(
                                                controller: rolesController,
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Role'),
                                                ),
                                                enabled: false,
                                              ),
                                              TextField(
                                                controller: statusController,
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: getTranslatedText(
                                                      'Account Status'),
                                                ),
                                                enabled: false,
                                              ),
                                              Visibility(
                                                visible: false,
                                                child: Row(
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
                                                          ['status'].toString().replaceAll('.', '').replaceAll('-', ''),
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
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                              getTranslatedText('Reset Password'),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                            content: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(getTranslatedText('The password will be reset to default'))
                                                              ],
                                                            ),

                                                            actions: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () async {
                                                                      await _resetPassword(
                                                                          context,
                                                                          index,
                                                                          idStaffController.text);
                                                                    },
                                                                    child: Text(getTranslatedText('Yes')),
                                                                    style: ElevatedButton.styleFrom(
                                                                      minimumSize: Size(100, 40),
                                                                      padding: EdgeInsets.all(10),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(19),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(getTranslatedText('No')),
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
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: Size(100, 40),
                                                      padding: EdgeInsets.all(10),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(19),
                                                      ),
                                                    ),
                                                    child: Text(getTranslatedText('Reset Password')),
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
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: Size(100, 40),
                                                      padding: EdgeInsets.all(10),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(19),
                                                      ),
                                                    ),
                                                    child: Text(getTranslatedText('Change Status')),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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
                                                            getTranslatedDatabase(_filteredData[index]
                                                            ['status'].toString().replaceAll('.', '').replaceAll('-', ' '),),
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