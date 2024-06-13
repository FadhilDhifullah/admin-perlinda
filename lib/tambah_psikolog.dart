import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TambahPsikolog extends StatefulWidget {
  const TambahPsikolog({super.key});

  @override
  State<TambahPsikolog> createState() => _TambahPsikologState();
}

class _TambahPsikologState extends State<TambahPsikolog> {
  File? _image;
  TextEditingController _namaController = TextEditingController();
  TextEditingController _whatsappController = TextEditingController();
  TextEditingController _deskripsiController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addPsikolog() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('psikolog').doc();
      String? imageUrl;

      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('psikolog_images')
            .child('${docRef.id}.jpg');
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      await docRef.set({
        'id': docRef.id,
        'full_name': _namaController.text,
        'whatsapp': _whatsappController.text,
        'description': _deskripsiController.text,
        'image': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Psikolog berhasil ditambahkan')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan psikolog: $e')),
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
          'Tambah Psikolog',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: AppBar().preferredSize.height + 5),
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: _pickImage,
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
                                width: 122,
                                height: 122,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
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
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      fillColor: Color(0xFFC1D9F1),
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
                      fillColor: Color(0xFFC1D9F1),
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
                      fillColor: Color(0xFFC1D9F1),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 90),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _addPsikolog,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Color(0xFF4682A9),
                      ),
                      child: Text(
                        'Tambah',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
  }
}
