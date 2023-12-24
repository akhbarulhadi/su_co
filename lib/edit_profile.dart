import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/marketing/data_pesanan.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:giffy_dialog/giffy_dialog.dart';

final StreamController<void> _streamController =
    StreamController<void>.broadcast();

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => EditProfilePage();
}

class EditProfilePage extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitPressed = false;
  File? _imageFile;
  bool isDarkTheme = false;
  String selectedLanguage = 'IDN';
  late TextEditingController _alamatController;
  late TextEditingController _noTlpController;
  late TextEditingController _emailController;
  List _listData = [];
  List _filteredData = [];
  bool isNumeric(String value) {
    return int.tryParse(value) != null;
  }

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController();
    _noTlpController = TextEditingController();
    _emailController = TextEditingController();
    loadDataProfile();
    loadThemePreference();
    loadSelectedLanguage();
    _getData();
    _streamController.stream.listen((_) {
      _getData();
    });
  }

  void loadDataProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String storedToken = prefs.getString('access_token') ?? '';

      var headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $storedToken', // Menggunakan storedToken bukan token
      };

      var response = await http.get(
        Uri.parse(ApiConfig.getProfile),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          _alamatController.text = data['data']['alamat'];
          _emailController.text = data['data']['email'];
          _noTlpController.text = data['data']['no_tlp'];
        });
      } else {
        // Handle kesalahan atau cetak pesan kesalahan
        print('Failed to load profile data: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle kesalahan atau cetak pesan kesalahan
      print("Error: $e");
    }
  }

  Future<void> _getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('access_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConfig.getfoto),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          _listData = [data['user']];
          _filteredData = _listData;
        });

        print(_filteredData);
        print(_filteredData.isNotEmpty
            ? _filteredData[0]['foto']
            : 'No photo available');
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

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final image = File(pickedFile.path);
      final savedImage = await saveImageToDeviceDirectory(image);
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<File> saveImageToDeviceDirectory(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = directory.path + '/image.png';

    // Menghapus file yang mungkin sudah ada
    if (await File(imagePath).exists()) {
      await File(imagePath).delete();
    }

    // Menyalin gambar baru
    await image.copy(imagePath);

    return File(imagePath);
  }

  Future<void> openCamera() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _imageFile = File(pickedImage!.path);
    });
  }

  Future<void> saveProfileChanges() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String storedToken = prefs.getString('access_token') ?? '';

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $storedToken',
      };

      var body = {
        'alamat': _alamatController.text,
        'email': _emailController.text,
        'no_tlp': _noTlpController.text,
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.editProfile),
      );

      // Menggunakan MultipartRequest untuk mengirim file (foto)
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            _imageFile!.path,
          ),
        );
      }

      // Menambahkan data teks ke body request
      request.fields.addAll(body);

      // Menambahkan header ke request
      request.headers.addAll(headers);

      // Melakukan request HTTP
      var response = await request.send();

      if (response.statusCode == 200) {
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
        print('Profile changes saved successfully');
      } else {
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
        print('Failed to save profile changes: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle kesalahan atau cetak pesan kesalahan
      print("Error: $e");
    }
  }

  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Profile':
          return 'Profil';
        case 'Address':
          return 'Alamat';
        case 'Save':
          return 'Simpan';
        case 'Cancel':
          return 'Batal';
        case 'Successfully':
          return 'Berhasil';
        case 'Close':
          return 'Tutup';
        case 'Failed':
          return 'Gagal';
        case 'No Image':
          return 'Tidak ada gambar';
        case 'Edit Profile Photo':
          return 'Edit Foto Profil';
        case 'Select Photo':
          return 'Pilih Gambar';
        case 'Take a Photo':
          return 'Ambil Gambar';
        case 'Fill in the data':
          return 'Isi datanya';
        case 'Email must contain the "@" character':
          return 'Email harus menganding karakter "@"';
        case 'Minimum 10 numbers':
          return 'Minimal 10 angka';
        case 'Telephone numbers must contain numbers only':
          return 'Nomor telepon harus mengandung angka saja';
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
      theme: themeData,
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
          title: Align(
            alignment: Alignment.center,
            child: Text(
              getTranslatedText('Profile'),
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
        ),
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkTheme ? Colors.white10 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkTheme ? Colors.white70 : Colors.black,
                        width: 0.3,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              child: _imageFile == null
                                  ? Image(
                                      image: AssetImage('lib/assets/user.png'))
                                  : Image.file(_imageFile!),
                            ),
                          ),
                          Center(
                            child: MaterialButton(
                              textColor:
                                  isDarkTheme ? Colors.white : Colors.black,
                              child:
                                  Text(getTranslatedText('Edit Profile Photo')),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding: EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: isDarkTheme
                                            ? Colors.black87
                                            : Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: _getImageFromGallery,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.image,
                                                  color: Color(0xFF57636C),
                                                  size: 40,
                                                ),
                                                SizedBox(width: 20.0),
                                                Text(getTranslatedText(
                                                    'Select Photo')),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5.0),
                                          ElevatedButton(
                                            onPressed: () {
                                              openCamera();
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.camera_alt_sharp,
                                                  color: Color(0xFF57636C),
                                                  size: 40,
                                                ),
                                                SizedBox(width: 20.0),
                                                Text(getTranslatedText(
                                                    'Take a Photo')),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Center(
                            child: _imageFile == null
                                ? Text(getTranslatedText('No Image'))
                                : Text(
                                    "Suco_Photo: ${_imageFile!.path.split('/').last}"),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _alamatController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: getTranslatedText('Address'),
                                    contentPadding: EdgeInsets.all(13),
                                  ),
                                  style: TextStyle(fontSize: 16),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return getTranslatedText('Fill in the data');
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _emailController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    contentPadding: EdgeInsets.all(13),
                                  ),
                                  style: TextStyle(fontSize: 16),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return getTranslatedText('Fill in the data');
                                    } else if (!value.contains('@')) {
                                      return getTranslatedText('Email must contain the "@" character');
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _noTlpController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: 'Telp',
                                    contentPadding: EdgeInsets.all(13),
                                  ),
                                  style: TextStyle(fontSize: 16),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return getTranslatedText('Fill in the data');
                                    } else if (value.length < 10) {
                                      return getTranslatedText('Minimum 10 numbers');
                                    } else if (!isNumeric(value)) {
                                      return getTranslatedText('Telephone numbers must contain numbers only');
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(50, 50, 50, 10),
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isSubmitPressed = true;
                                });
                                if (_formKey.currentState!.validate()) {
                                  await saveProfileChanges();
                                }
                              },
                              child: Text(
                                getTranslatedText('Save'),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(370, 44),
                                padding: EdgeInsets.all(0),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                primary: Color(0xFF3DA9FC),
                              ),
                            ),
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
