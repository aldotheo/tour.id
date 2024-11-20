import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddWisataPage extends StatefulWidget {
  @override
  _AddWisataPageState createState() => _AddWisataPageState();
}

class _AddWisataPageState extends State<AddWisataPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  File? _image;
  Uint8List? _webImage; // For web to store image as Uint8List

  String selectedCategoryId = '';
  List<Map<String, String>> categories = [];

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  // Fetch categories from the backend
  Future<void> _getCategories() async {
    var uri = Uri.parse("http://localhost/flutter_api/get_kategori.php");
    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data']; // Access 'data' directly
        List<Map<String, String>> fetchedCategories = [];

        for (var item in data) {
          fetchedCategories.add({
            'id': item['id_kategori'].toString(),
            'nama': item['Nama_kategori'],  // Ensure correct case for 'Nama_kategori'
          });
        }

        setState(() {
          categories = fetchedCategories;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil kategori: $e')),
      );
    }
  }

  // Image picking function (for gallery)
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  // Submit data to server
  Future<void> _submitData() async {
    if (selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pilih kategori terlebih dahulu')));
      return;
    }

    if (namaController.text.isEmpty || deskripsiController.text.isEmpty || alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    var uri = Uri.parse("http://localhost/flutter_api/add_daftarwisata.php");
    var request = http.MultipartRequest('POST', uri);

    request.fields['nama_wisata'] = namaController.text;
    request.fields['deskripsi'] = deskripsiController.text;
    request.fields['id_kategori'] = selectedCategoryId;
    request.fields['alamat'] = alamatController.text;

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    } else if (_webImage != null) {
      request.files.add(http.MultipartFile.fromBytes('image', _webImage!, filename: 'upload.jpg'));
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wisata berhasil ditambahkan")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambahkan wisata')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambahkan wisata: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Wisata'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.green.shade100,
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(labelText: "Nama Wisata"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: deskripsiController,
                    decoration: InputDecoration(labelText: "Deskripsi Wisata"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: alamatController,
                    decoration: InputDecoration(labelText: "Alamat Wisata"),
                  ),
                  SizedBox(height: 10),
                  // Dropdown for categories
                  categories.isEmpty
                      ? CircularProgressIndicator()  // Show loading if categories are empty
                      : DropdownButton<String>(
                          value: selectedCategoryId.isEmpty ? null : selectedCategoryId,
                          hint: Text('Pilih Kategori'),
                          onChanged: (newValue) {
                            setState(() {
                              selectedCategoryId = newValue!;
                            });
                          },
                          items: categories.map<DropdownMenuItem<String>>((category) {
                            return DropdownMenuItem<String>(
                              value: category['id'],
                              child: Text(category['nama'] ?? ''),
                            );
                          }).toList(),
                        ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: _image == null && _webImage == null
                        ? Icon(Icons.add_a_photo, size: 100, color: Colors.grey)
                        : (kIsWeb
                            ? Image.memory(_webImage!, height: 100, width: 100, fit: BoxFit.cover)
                            : Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitData,
                    child: Text("Simpan"),
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
      ),
    );
  }
}
