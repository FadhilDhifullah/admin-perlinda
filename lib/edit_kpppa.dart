import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_perlinda_admin/data_kpppa.dart'; // Import the DataKpppa page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: EditKpppa(userId: 'exampleUserId'), // Example userId for testing
  ));
}

class EditKpppa extends StatefulWidget {
  final String userId;
  const EditKpppa({Key? key, required this.userId}) : super(key: key);

  @override
  _EditKpppaState createState() => _EditKpppaState();
}

class _EditKpppaState extends State<EditKpppa> {
  File? _imageFile; // To store the picked image file
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHandphoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKpppaData(widget.userId);
  }

  Future<void> _fetchKpppaData(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('kpppa').doc(userId).get();
    if (userDoc.exists) {
      setState(() {
        _namaController.text = userDoc['full_name'];
        _emailController.text = userDoc['email'];
        _passwordController.text = '*******'; // Mask the password
        _alamatController.text = userDoc['alamat'];
        _noHandphoneController.text = userDoc['no_handphone'];
        _imageUrl = userDoc['profile_picture'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(String userId) async {
    if (_imageFile != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child('profile_pictures_kpppa').child('$userId.jpg');
        await ref.putFile(_imageFile!);
        String imageUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('kpppa').doc(userId).update({
          'profile_picture': imageUrl,
        });
        setState(() {
          _imageUrl = imageUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah gambar: $e')),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _uploadImage(widget.userId);

        await FirebaseFirestore.instance.collection('kpppa').doc(widget.userId).update({
          'full_name': _namaController.text,
          'alamat': _alamatController.text,
          'no_handphone': _noHandphoneController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perubahan berhasil disimpan')),
        );

        // Navigate to DataKpppa page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DataKpppa()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
      }
    }
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5.0),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: 'Masukkan $label',
              filled: true,
              fillColor: Color(0xFFC1D9F1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4682A9),
        centerTitle: true,
        title: Text(
          'Ubah Detail Akun KemenPPPA',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 150.0,
                child: Container(
                  color: Color(0xFF4682A9),
                  width: double.infinity,
                  child: Row(
                    children: [
                      SizedBox(width: 20.0),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_imageFile != null)
                                CircleAvatar(
                                  radius: 50.0,
                                  backgroundImage: FileImage(_imageFile!),
                                )
                              else if (_imageUrl != null)
                                CircleAvatar(
                                  radius: 50.0,
                                  backgroundImage: NetworkImage(_imageUrl!),
                                )
                              else
                                Icon(
                                  Icons.person,
                                  size: 50.0,
                                  color: Colors.grey,
                                ),
                              Positioned(
                                right: 3.0,
                                bottom: 3.0,
                                child: Container(
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 17.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _namaController.text,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Kementrian PPPA',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildLabeledTextField('Nama Lengkap', _namaController),
                      _buildLabeledTextField('Email', _emailController),
                      _buildLabeledTextField('Kata Sandi', _passwordController, isPassword: true),
                      _buildLabeledTextField('Alamat', _alamatController),
                      _buildLabeledTextField('No Handphone', _noHandphoneController),
                      SizedBox(height: 50.0),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4682A9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
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
