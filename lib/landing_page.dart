import 'package:flutter/material.dart';
import 'package:flutter_perlinda_admin/login_page.dart';
import 'package:flutter_perlinda_admin/signup_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4682A9),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 280.0, // Adjust width as needed
                height: 280.0, // Adjust height as needed
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Mengatur bentuk menjadi lingkaran
                  color: Color(0xFF749BC2), // Mengubah warna latar belakang lingkaran
                ),
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0.0, 20.0), // Pindahkan logo ke bawah sejauh 20.0 piksel
                    child: Container(
                      width: 208.0, // Adjust width as needed
                      height: 200.0, // Adjust height as needed
                      child: Image.asset(
                        'images/logo_perlinda.png',
                        fit: BoxFit.cover, // Maintain aspect ratio and fill the container
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100.0, bottom: 40.0),
                child: Text(
                  'Tetaplah kuat. Selamat datang di Perlinda,\ntempat di mana kita memberikan dukungan\ndan perlindungan bagi Anda atau orang\ndisekitar Anda yang mengalami kekerasan\ndalam rumah tangga.',
                  style: const TextStyle(fontSize: 14.0, color: Colors.white), // Ubah warna teks menjadi putih
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman LoginPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Masuk',
                      style: TextStyle(
                        color: Color(0xFF00355C), // Ubah warna teks tombol
                        fontWeight: FontWeight.bold, // Teks menjadi bold
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 80.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      // Handle create account button press
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text(
                      'Buat akun baru',
                      style: TextStyle(
                        color: Color(0xFF00355C), // Ubah warna teks tombol
                        fontWeight: FontWeight.bold, // Teks menjadi bold
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(214, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}