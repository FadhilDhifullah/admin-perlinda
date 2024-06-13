import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_perlinda_admin/edit_psikolog.dart'; // Import halaman EditPsikolog
import 'package:flutter_perlinda_admin/tambah_psikolog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: DataPsikolog(),
  ));
}

class DataPsikolog extends StatefulWidget {
  const DataPsikolog({Key? key}) : super(key: key);

  @override
  State<DataPsikolog> createState() => _DataPsikologState();
}

class _DataPsikologState extends State<DataPsikolog> {
  String _searchQuery = '';

  Future<void> _deletePsikolog(String docId, String imageUrl) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance.collection('psikolog').doc(docId).delete();

      // Delete profile picture from Storage
      if (imageUrl.isNotEmpty) {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Psikolog berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus psikolog: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(String docId, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus psikolog ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deletePsikolog(docId, imageUrl);
              },
              child: Text('Hapus'),
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
          'Data Psikolog',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Cari nama psikolog',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TambahPsikolog()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4682A9),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Tambahkan Psikolog',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 8.0),
                      Icon(Icons.add, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('psikolog').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('Tidak ada data'));
                  }

                  final psikologDocs = snapshot.data!.docs;
                  final filteredDocs = psikologDocs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return data['full_name'].toLowerCase().contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var psikolog = filteredDocs[index].data() as Map<String, dynamic>;
                      return Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: psikolog['image'] != null
                                        ? NetworkImage(psikolog['image'])
                                        : AssetImage('images/default_avatar.png') as ImageProvider,
                                    radius: 30,
                                  ),
                                  SizedBox(width: 16.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        psikolog['full_name'] ?? 'Nama tidak tersedia',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        'Psikolog',
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                      SizedBox(height: 4.0),
                                      Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 16.0),
                                          SizedBox(width: 8.0),
                                          Text(psikolog['whatsapp'] ?? 'Nomor tidak tersedia'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0),
                              Divider(color: Colors.black),
                              SizedBox(height: 16.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditPsikolog(docId: filteredDocs[index].id),
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xff4682A9)),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        minimumSize: MaterialStateProperty.all<Size>(Size(120, 40)),
                                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                          EdgeInsets.symmetric(vertical: 12.0),
                                        ),
                                      ),
                                      child: Text('Edit', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(width: 15.0),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(filteredDocs[index].id, psikolog['image']);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFA94646)),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        minimumSize: MaterialStateProperty.all<Size>(Size(120, 40)),
                                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                          EdgeInsets.symmetric(vertical: 12.0),
                                        ),
                                      ),
                                      child: Text('Hapus', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
