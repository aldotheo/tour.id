import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditKategoriPage extends StatefulWidget {
  final String id;

  // Constructor untuk menerima ID kategori
  EditKategoriPage({required this.id});

  @override
  _EditKategoriPageState createState() => _EditKategoriPageState();
}

class _EditKategoriPageState extends State<EditKategoriPage> {
  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKategoriData(widget.id); // Mengambil data kategori berdasarkan ID
  }

  // Fungsi untuk mengambil data kategori berdasarkan ID dari API
  Future<void> _fetchKategoriData(String id) async {
    final response = await http.get(Uri.parse('http://localhost/flutter_api/edit_kategori.php?id=$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        kategoriController.text = data['kategori'];
        deskripsiController.text = data['deskripsi'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data')));
    }
  }

  // Fungsi untuk mengupdate kategori ke server
  Future<void> _submitData(BuildContext context) async {
    if (kategoriController.text.isEmpty || deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    final response = await http.put(
      Uri.parse('http://localhost/flutter_api/edit_kategori.php?id=${widget.id}'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'kategori': kategoriController.text,
        'deskripsi': deskripsiController.text,
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui kategori')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Kategori'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.green.shade100,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kategoriController,
                  decoration: InputDecoration(labelText: "Kategori"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: deskripsiController,
                  decoration: InputDecoration(labelText: "Deskripsi"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _submitData(context),
                  child: Text('Simpan Perubahan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
