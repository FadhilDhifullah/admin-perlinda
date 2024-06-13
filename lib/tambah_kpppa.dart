import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: TambahKpppa(),
  ));
}

class TambahKpppa extends StatefulWidget {
  const TambahKpppa({Key? key}) : super(key: key);

  @override
  State<TambahKpppa> createState() => _TambahKpppaState();
}

class _TambahKpppaState extends State<TambahKpppa> {
  File? _image;
  String? _imageUrl;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHandphoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();
    _noHandphoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(String userId) async {
    if (_image != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child('profile_pictures_kpppa').child('$userId.jpg');
        await ref.putFile(_image!);
        _imageUrl = await ref.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah gambar: $e')),
        );
      }
    }
  }

  Future<void> _addKpppa() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String userId = userCredential.user!.uid;

      await _uploadImage(userId);

      await FirebaseFirestore.instance.collection('kpppa').doc(userId).set({
        'id': userId,
        'full_name': _namaController.text,
        'email': _emailController.text,
        'password': _passwordController.text, // Save the password in Firestore
        'alamat': _alamatController.text,
        'no_handphone': _noHandphoneController.text,
        'profile_picture': _imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Akun KemenPPPA berhasil ditambahkan')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan akun: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan akun: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4682A9),
        centerTitle: true,
        title: Text(
          'Tambah Akun KemenPPPA',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      child: _image != null
                          ? ClipOval(
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(8),
                        backgroundColor: Colors.white,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Nama Lengkap',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFC1D9F1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFC1D9F1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Kata Sandi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFC1D9F1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Alamat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFC1D9F1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'No. Handphone',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _noHandphoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Masukkan no. handphone',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFC1D9F1),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _addKpppa,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xFF4682A9),
                  ),
                  child: Text(
                    'Tambah',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
