import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testaja/Tambahkan/add_daftarwisata.dart'; // Import halaman tambah data
import 'package:testaja/edit/edit_daftarwisata.dart';
import 'package:testaja/view_daftarwisataPage.dart'; // Import view page

class DaftarWisataPage extends StatefulWidget {
  @override
  _DaftarWisataPageState createState() => _DaftarWisataPageState();
}

class _DaftarWisataPageState extends State<DaftarWisataPage> {
  List<Map<String, dynamic>> wisataList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getWisataData(); // Mengambil data saat halaman dimuat
  }

  // Fungsi untuk mengambil data dari API
  Future<void> _getWisataData() async {
    var uri = Uri.parse("http://localhost/flutter_api/daftar_wisata.php");
    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> fetchedWisata = [];
        var data = json.decode(response.body);

        if (data is List) {
          for (var item in data) {
            fetchedWisata.add({
              'id': item['id_wisata'].toString(),
              'title': item['nama_wisata'],
              'description': item['deskripsi'],
              'imageUrl': item['image_url'] ?? '', // Nilai default jika tidak ada URL gambar
            });
          }

          setState(() {
            wisataList = fetchedWisata;
            isLoading = false; // Selesai memuat data
          });
        } else {
          print('Format JSON tidak sesuai');
        }
      } else {
        print('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error mengambil data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Menampilkan notifikasi setelah menghapus data
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Menampilkan konfirmasi penghapusan
  Future<void> _confirmDelete(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menghapus wisata ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () async {
                var uri = Uri.parse('http://localhost/flutter_api/delete_wisata.php');
                var response = await http.post(uri, body: {'id_wisata': id});

                if (response.statusCode == 200) {
                  _showSnackBar('Wisata berhasil dihapus!');
                  Navigator.of(context).pop();
                  _getWisataData(); // Memuat ulang data
                } else {
                  _showSnackBar('Gagal menghapus wisata');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Daftar Wisata'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: wisataList.length,
              itemBuilder: (context, index) {
                var wisata = wisataList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Gambar destinasi wisata
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            image: DecorationImage(
                              image: NetworkImage(wisata['imageUrl'] != ''
                                  ? "http://localhost/flutter_api/${wisata['imageUrl']}"
                                  : 'https://via.placeholder.com/150'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        // Detail destinasi wisata
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wisata['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                wisata['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildActionButton(
                                      Icons.visibility, Colors.green, () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ViewDaftarWisataPage(wisata: wisata),
                                      ),
                                    );
                                  }),
                                  SizedBox(width: 8),
                                  _buildActionButton(Icons.edit, Colors.blue,
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditDaftarWisataPage(
                                                id: wisata['id'].toString()),
                                      ),
                                    );
                                  }),
                                  SizedBox(width: 8),
                                  _buildActionButton(Icons.delete, Colors.red,
                                      () {
                                    _confirmDelete(wisata['id']);
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWisataPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }
}
