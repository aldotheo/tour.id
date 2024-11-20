import 'dart:convert'; // Import this to handle JSON parsing
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testaja/karetogi_page.dart';

class AddKategori extends StatefulWidget {
  @override
  _AddKategoriState createState() => _AddKategoriState();
}

class _AddKategoriState extends State<AddKategori> {
  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  // The function to submit the category data
  Future<void> _submitData() async {
    String kategori = kategoriController.text;
    String deskripsi = deskripsiController.text;

    // Validate the input fields
    if (kategori.isEmpty || deskripsi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // Define the URL for the PHP endpoint
    var uri = Uri.parse("http://localhost/flutter_api/add_kategori.php");

    // Send the data to the PHP endpoint using a POST request
    var response = await http.post(uri, body: {
      'kategori': kategori,
      'deskripsi': deskripsi,
    });

    // Check the response
    if (response.statusCode == 200) {
      // If successful, show a success message and clear the fields
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kategori berhasil ditambahkan')));
      kategoriController.clear();
      deskripsiController.clear();
    } else {
      // If error occurs, show a failure message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambahkan kategori')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Kategori'),
         leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => KategoriPage()),
          );// Navigate back
          },
        ),
      ),
      body: Container(
        color: Colors.green,
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
                TextField(
                  controller: deskripsiController,
                  decoration: InputDecoration(labelText: "Deskripsi"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitData, 
                  child: Text("Simpan"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
