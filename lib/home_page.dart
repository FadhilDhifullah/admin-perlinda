import 'package:flutter/material.dart';
import 'package:flutter_perlinda_admin/data_advokat.dart';
import 'package:flutter_perlinda_admin/data_psikolog.dart';
import 'package:flutter_perlinda_admin/data_kpppa.dart';
import 'package:flutter_perlinda_admin/landing_page.dart'; // Import halaman LandingPage
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for logout

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // Header with custom image and logo
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200.0, // Adjust the height as needed
                    child: Image.asset(
                      'images/logo_home.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 20.0,
                    left: 16.0,
                    child: Image.asset(
                      'images/logo_perlinda.png',
                      width: 68.0, // Adjust the width as needed
                      height: 68.0, // Adjust the height as needed
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1.0), // Spacing
              // Menu options
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MenuItem(
                          imagePath: 'images/data_advokat.png',
                          text: 'Data Advokat',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DataAdvokat()),
                            );
                          },
                        ),
                        MenuItem(
                          imagePath: 'images/data_psikolog.png',
                          text: 'Data Psikolog',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DataPsikolog()),
                            );
                          },
                        ),
                        MenuItem(
                          imagePath: 'images/data_kpppa.png',
                          text: 'Data Akun KemenPPA',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DataKpppa()),
                            );
                          },
                        ),
                        const SizedBox(
                            height:
                                40.0), // Spacing between the last menu item and the button
                        ElevatedButton(
                          onPressed: () async {
                            // Handle the logout functionality
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LandingPage()), // Pindahkan ke halaman LandingPage dan hapus halaman lain dari stack
                              (Route<dynamic> route) =>
                                  false, // Hapus semua halaman dari stack
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color(0xFFA94646), // Button background color
                            padding: EdgeInsets.symmetric(
                                horizontal: 50.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'Keluar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0), // Spacing
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback onTap;

  MenuItem({required this.imagePath, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFFC1D9F1), // Background color for the menu items
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Container(
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(5.0), // Add padding if needed
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 20.0),
              Text(
                text,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00355C), // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
