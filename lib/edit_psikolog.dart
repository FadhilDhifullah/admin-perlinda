import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditPsikolog extends StatefulWidget {
  final String docId;
  const EditPsikolog({Key? key, required this.docId}) : super(key: key);

  @override
  _EditPsikologState createState() => _EditPsikologState();
}

class _EditPsikologState extends State<EditPsikolog> {
  File? _imageFile;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPsikologData(widget.docId);
  }

  Future<void> _fetchPsikologData(String docId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('psikolog').doc(docId).get();
    if (doc.exists) {
      setState(() {
        _namaController.text = doc['full_name'];
        _whatsappController.text = doc['whatsapp'];
        _deskripsiController.text = doc['description'];
        _imageUrl = doc['image'];
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

  Future<void> _uploadImage(String docId) async {
    if (_imageFile != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child('psikolog_images').child('$docId.jpg');
        await ref.putFile(_imageFile!);
        String imageUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('psikolog').doc(docId).update({
          'image': imageUrl,
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
    try {
      await _uploadImage(widget.docId);

      await FirebaseFirestore.instance.collection('psikolog').doc(widget.docId).update({
        'full_name': _namaController.text,
        'whatsapp': _whatsappController.text,
        'description': _deskripsiController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perubahan berhasil disimpan')),
      );

      Navigator.pop(context); // Navigate back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
      );
    }
  }

  void _editDeskripsi() {
    TextEditingController controller = TextEditingController(text: _deskripsiController.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Deskripsi'),
          content: TextField(
            controller: controller,
            maxLines: null,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _deskripsiController.text = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _editNama() {
    TextEditingController controller = TextEditingController(text: _namaController.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Nama'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _namaController.text = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _editNomorTelepon() {
    TextEditingController controller = TextEditingController(text: _whatsappController.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Nomor Telepon'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _whatsappController.text = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4682A9),
        centerTitle: true,
        title: Text(
          'Ubah Data Psikolog',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Color(0xFF4682A9),
              width: double.infinity,
              height: 50.0,
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
                            ),
                          ),
                          Positioned(
                            right: 5.0,
                            bottom: 5.0,
                            child: Icon(
                              Icons.camera_alt,
                              size: 20.0,
                              color: Colors.grey,
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
                      Row(
                        children: [
                          Text(
                            _namaController.text,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: _editNama,
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: [
                          Text(
                            'Psikolog',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Color(0xFF25D366),
                            size: 16.0,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            _whatsappController.text,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: _editNomorTelepon,
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  GestureDetector(
                    onTap: _editDeskripsi,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFC1D9F1),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: _deskripsiController.text,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.grey,
                                      size: 18.0,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
