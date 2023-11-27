import 'package:flutter/material.dart';
import 'package:suco/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/marketing/data_pesanan.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => EditProfilePage();
}

class EditProfilePage extends State<EditProfile> {
  File? _imageFile;
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  TextEditingController _emailController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _noTlpController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    loadDataProfile();
    loadThemePreference();
    loadSelectedLanguage();
  }

  void loadDataProfile() async {
    try {
      var token = 'access_token';

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(
        Uri.parse(ApiConfig.getProfile),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          _emailController.text = data['email'];
          _alamatController.text = data['alamat'];
          _noTlpController.text = data['no_tlp'];
        });
      } else {
        print('Failed to load profile data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error: $e");
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
        case 'Edit Profile':
          return 'Ubah Profil';
        case 'Name':
          return 'Nama';
        case 'Address':
          return 'Alamat';
        case 'Edit Profile Photo':
          return 'Ganti Foto Profil';
        case 'Upload':
          return 'Unggah';
        case 'Select Photo':
          return 'Pilih Foto';
        case 'Take a Photo':
          return 'Ambil Gambar';
        case 'No Image':
          return 'Tidak Ada Gambar';
        case 'Save':
          return 'Simpan';

        default:
          return text;
      }
    } else {
      return text;
    }
  }

  Future<void> saveProfileChanges() async {
    try {
      var token = 'access_token';

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var body = {
        'email': _emailController.text,
        'alamat': _alamatController.text,
        'no_tlp': _noTlpController.text,
      };

      var response = await http.post(
        Uri.parse(ApiConfig.editProfile),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Berhasil menyimpan perubahan, tambahkan logika atau pindah ke halaman lain jika perlu
      } else {
        // Gagal menyimpan perubahan, tampilkan pesan kesalahan atau lakukan sesuatu yang sesuai
      }
    } catch (e) {
      print("Error: $e");
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
              getTranslatedText('Edit Profile'),
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
                          TextFormField(
                            controller: _emailController,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Email'),
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
                          ),
                          TextFormField(
                            controller: _alamatController,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Alamat'),
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
                          ),
                          TextFormField(
                            controller: _noTlpController,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Telp',
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(50, 50, 50, 10),
                            child: ElevatedButton(
                              onPressed: () async {
                                await saveProfileChanges();
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
