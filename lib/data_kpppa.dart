import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_perlinda_admin/tambah_kpppa.dart';
import 'package:flutter_perlinda_admin/edit_kpppa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: DataKpppa(),
  ));
}

class DataKpppa extends StatefulWidget {
  const DataKpppa({Key? key}) : super(key: key);

  @override
  State<DataKpppa> createState() => _DataKpppaState();
}

class _DataKpppaState extends State<DataKpppa> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _deleteAccount(String userId) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance.collection('kpppa').doc(userId).delete();

      // Delete profile picture from Storage
      final ref = FirebaseStorage.instance.ref().child('profile_pictures_kpppa').child('$userId.jpg');
      await ref.delete();

      // Re-authenticate and delete the user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Akun berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus akun: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus akun ini?'),
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
                await _deleteAccount(userId);
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
          'Data Akun KemenPPPA',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari nama akun',
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
                      MaterialPageRoute(builder: (context) => TambahKpppa()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4682A9),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Tambahkan Akun',
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
                stream: FirebaseFirestore.instance.collection('kpppa').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('Tidak ada data'));
                  }

                  final kpppaDocs = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var fullName = data['full_name']?.toLowerCase() ?? '';
                    return fullName.contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: kpppaDocs.length,
                    itemBuilder: (context, index) {
                      var kpppa = kpppaDocs[index].data() as Map<String, dynamic>;
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
                                    backgroundImage: kpppa['profile_picture'] != null
                                        ? NetworkImage(kpppa['profile_picture'])
                                        : AssetImage('images/default_avatar.png') as ImageProvider,
                                    radius: 30,
                                  ),
                                  SizedBox(width: 16.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        kpppa['full_name'] ?? 'Nama tidak tersedia',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 15.0),
                                      Text(
                                        kpppa['email'] ?? 'Email tidak tersedia',
                                        style: TextStyle(fontSize: 14.0),
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
                                          MaterialPageRoute(builder: (context) => EditKpppa(userId: kpppaDocs[index].id)),
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
                                        _showDeleteConfirmationDialog(kpppaDocs[index].id);
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
