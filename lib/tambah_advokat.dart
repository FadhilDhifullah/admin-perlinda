import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: TambahAdvokat(),
  ));
}

class TambahAdvokat extends StatefulWidget {
  const TambahAdvokat({super.key});

  @override
  State<TambahAdvokat> createState() => _TambahAdvokatState();
}

class _TambahAdvokatState extends State<TambahAdvokat> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> _uploadData() async {
    if (_image == null ||
        _namaController.text.isEmpty ||
        _whatsappController.text.isEmpty ||
        _deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields and select an image')),
      );
      return;
    }

    try {
      // Generate a new document ID
      DocumentReference docRef = FirebaseFirestore.instance.collection('advokat').doc();
      String documentId = docRef.id;

      // Upload image to Firebase Storage
      String imageFileName = '$documentId.jpg';
      Reference storageReference = FirebaseStorage.instance.ref().child('advokat_images/$imageFileName');
      UploadTask uploadTask = storageReference.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Save data to Firestore
      await docRef.set({
        'id': documentId,
        'full_name': _namaController.text,
        'whatsapp': _whatsappController.text,
        'description': _deskripsiController.text,
        'image': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil ditambahkan')),
      );

      // Clear fields after successful upload
      setState(() {
        _image = null;
        _namaController.clear();
        _whatsappController.clear();
        _deskripsiController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan data: $e')),
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _whatsappController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4682A9),
        centerTitle: true,
        title: Text(
          'Tambah Advokat',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), // Ubah warna ikon kembali menjadi putih
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
                        size: 20, // Mengatur ukuran ikon kamera
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
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFC1D9F1), // Warna latar belakang
                  hintText: 'Masukkan nama lengkap',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Nomor WhatsApp',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _whatsappController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFC1D9F1), // Warna latar belakang
                  hintText: 'Masukkan nomor WhatsApp',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFC1D9F1), // Warna latar belakang
                  hintText: 'Masukkan deskripsi',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 90), // Tambahkan jarak antara TextFormField dan tombol
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _uploadData,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xFF4682A9), // Warna latar belakang
                  ),
                  child: Text(
                    'Tambah',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ), // Warna teks
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
