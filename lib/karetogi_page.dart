import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testaja/Tambahkan/add_kategori.dart';
import 'package:testaja/menu.dart';

class KategoriPage extends StatefulWidget {
  @override
  _KategoriPageState createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  List<Map<String, String>> kategoriList = [];

  // Fetch categories from the backend
  Future<void> _getCategories() async {
    var uri = Uri.parse("http://localhost/flutter_api/get_kategori.php"); // Ganti localhost dengan IP lokal
    var response = await http.get(uri);

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      List<Map<String, String>> fetchedCategories = [];
      try {
        var data = json.decode(response.body);
        print("Decoded data: $data");

        if (data is List) {
          for (var item in data) {
            if (item is Map) {
              fetchedCategories.add({
                'id': item['id_kategori']?.toString() ?? '',
                'title': item['nama_kategori'] ?? '',
                'description': item['keterangan_kategori'] ?? '',
              });
            }
          }
        } else {
          print("Unexpected data format: $data");
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }

      setState(() {
        kategoriList = fetchedCategories;
      });
    } else {
      _showSnackbar('Gagal memuat kategori (${response.statusCode})');
    }
  }

  // Show Snackbar for messages
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Menu()),
            );
          },
        ),
        title: Text('Kategori', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Menu()),
              );
            },
          ),
        ],
      ),
      body: kategoriList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.green.shade100.withOpacity(0.3),
              child: ListView.builder(
                itemCount: kategoriList.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ListTile(
                      title: Text(
                        kategoriList[index]['title']!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        kategoriList[index]['description']!,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      onTap: () {
                        // Handle category click
                        _showSnackbar('Klik pada kategori ${kategoriList[index]['title']}');
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool categoryAdded = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddKategori()),
              ) ??
              false;

          if (categoryAdded) {
            _getCategories();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
