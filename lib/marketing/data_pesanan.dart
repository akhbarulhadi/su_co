import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:suco/marketing/dashboard.dart';

class DataPesanan extends StatefulWidget {
  const DataPesanan({super.key});

  @override
  State<DataPesanan> createState() => DataPesananState();
}

class DataPesananState extends State<DataPesanan> {
  bool isDarkTheme = false; // Variabel untuk tema gelap
  String selectedLanguage = 'IDN'; // Variabel untuk bahasa yang dipilih
  TextEditingController NamaProduk = TextEditingController();
  TextEditingController JumlahProduk = TextEditingController();
  TextEditingController JenisPembayaran = TextEditingController();
  TextEditingController TotalHarga = TextEditingController();
  bool isDataBenar = false;
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

  void dialog1() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            getTranslatedText('Confirmation'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            getTranslatedText('Would you like to submit this form?'),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog 1
                    setState(() {
                      isDataBenar = false; // Set data ke false
                      NamaProduk.clear(); // Kosongkan form
                      JumlahProduk.clear(); // Kosongkan form
                      JenisPembayaran.clear(); // Kosongkan form
                      TotalHarga.clear(); // Kosongkan form
                    });
                    dialog2();
                  },
                  child: Text(getTranslatedText('Yes')),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                ),
                SizedBox(width: 10.0,),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Tidak'),
                  child: Text(getTranslatedText('No')),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                      side: BorderSide(
                        color: Color(0xFF3DA9FC), // Warna border
                        width: 1.0,          // Lebar border
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
  }

  void dialog2() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.image(
          Image.asset('lib/assets/gif_send_letter.gif',
          height: 200,
            fit: BoxFit.cover,
          ),
          title: Text(
            getTranslatedText('Data Sent Successfully'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            getTranslatedText('Do you want to fill in the data again ?'),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => DashboardPageMarketing()));
                  },
                  child: Text(getTranslatedText('No, Thank You')),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 40),
                    padding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                ),
                SizedBox(width: 10.0,),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(getTranslatedText('Fill in the Data Again')),
                  style: TextButton.styleFrom(
                    minimumSize: Size(100, 40),
                    padding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                      side: BorderSide(
                        color: Color(0xFF3DA9FC), // Warna border
                        width: 1.0,          // Lebar border
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
  }

  // Fungsi untuk mendapatkan teks berdasarkan bahasa yang dipilih
  String getTranslatedText(String text) {
    if (selectedLanguage == 'IDN') {
      // Teks dalam bahasa Indonesia
      switch (text) {
        case 'Order Data':
          return 'Data Pesanan';
        case 'Product Name':
          return 'Nama Produk';
        case 'Number Of Products':
          return 'Jumlah Produk';
        case 'Type Of Payments':
          return 'Jenis Pembayaran';
        case 'Total Product Price':
          return 'Total Harga Produk';
        case 'Confirmation':
          return 'Konfirmasi';
        case 'Would you like to submit this form?':
          return 'Apakah Anda ingin mengirim formulir ini?';
        case 'Yes':
          return 'Ya';
        case 'No':
          return 'Tidak';
        case 'Data Sent Successfully':
          return 'Data Berhasil Terkirim';
        case 'Do you want to fill in the data again ?':
          return 'Apakah anda ingin melakukan pengisian data lagi ?';
        case 'No, Thank You':
          return 'Tidak, Terima Kasih';
        case 'Fill in the Data Again':
          return 'Isi Data Lagi';
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
              getTranslatedText("Order Data"),
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
                          TextFormField(
                            controller: NamaProduk,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Product Name'),
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          TextFormField(
                            controller: JumlahProduk,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Number Of Products'),
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          TextFormField(
                            controller: JenisPembayaran,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Type Of Payments'),
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          TextFormField(
                            controller: TotalHarga,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: getTranslatedText('Total Product Price'),
                              contentPadding: EdgeInsets.all(13),
                            ),
                            style: TextStyle(fontSize: 16),
// Tambahkan validator sesuai kebutuhan
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 30, left: 160),
                            child: ElevatedButton(
                              onPressed: dialog1,
                              child: Text(
                                getTranslatedText('Confirmation'),
                                style: TextStyle(
                                  fontSize: 18,
                                ),),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(170, 44),
                                padding: EdgeInsets.all(0),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
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
