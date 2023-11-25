import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suco/marketing/data_pesanan.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => EditProfilePage();
}

class EditProfilePage extends State<EditProfile> {
  File? _imageFile;
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final image = File(pickedFile.path);
      // Simpan gambar ke direktori perangkat
      final savedImage = await saveImageToDeviceDirectory(image);
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  // Fungsi untuk menyimpan gambar ke direktori perangkat
  Future<File> saveImageToDeviceDirectory(File image) async {
    // Tentukan direktori penyimpanan (contoh: direktori gambar)
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = directory.path + '/image.png';

    // Salin gambar ke direktori
    await image.copy(imagePath);

    return File(imagePath);
  }

  Future<void> openCamera() async {
    //fuction openCamera();
    final pickedImage =
    await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      // tempat untuk set state image
      _imageFile = File(pickedImage!.path);
    });
  }

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Muat preferensi tema gelap saat halaman dimulai
    loadSelectedLanguage(); // Muat bahasa yang dipilih saat halaman dimulai
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
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
          ),
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
              getTranslatedText(
                  'Edit Profile'),
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
                      color: isDarkTheme
                          ? Colors.white10
                          : Colors
                          .white, // Ganti dengan warna latar belakang yang sesuai
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkTheme
                            ? Colors.white70
                            : Colors.black, // Ganti dengan warna yang sesuai
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
                              child: Image(
                                image: AssetImage('lib/assets/user.png'),
                              ),
                            ),
                          ),
                          Center(
                            child: MaterialButton(
                              textColor: isDarkTheme
                                  ? Colors.white
                                  : Colors.black, // Warna teks
                              child: Text(getTranslatedText('Edit Profile Photo'),),
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
                                                Text(getTranslatedText('Select Photo'),),
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
                                                Text(getTranslatedText('Take a Photo'),),
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
                                ? Text(getTranslatedText(''),)
                                : Text(
                                "Suco_Photo: ${_imageFile!.path.split('/').last}"),
                          ),
                          TextFormField(
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Name'),
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          TextFormField(
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Id Staff',
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          TextFormField(
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          TextFormField(
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Address'),
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          TextFormField(
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Telp',
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(50, 50, 50, 10),
                            child: ElevatedButton(
                              onPressed: () {
                                //Navigator.push(
                                    //context, MaterialPageRoute(builder: (context) => DataPesanan()));
                                },
                              child: Text(
                                getTranslatedText('Save'),
                                style: TextStyle(
                                  fontSize: 16,
                                ),),
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
