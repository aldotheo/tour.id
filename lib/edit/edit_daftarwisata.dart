import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class EditDaftarWisataPage extends StatefulWidget {
  final String id;

  EditDaftarWisataPage({required this.id});

  @override
  _EditDaftarWisataPageState createState() => _EditDaftarWisataPageState();
}

class _EditDaftarWisataPageState extends State<EditDaftarWisataPage> {
  TextEditingController namaController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  File? _image;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _fetchWisataDetails();
  }

  Future<void> _fetchWisataDetails() async {
    final uri = Uri.parse("http://localhost/flutter_api/get_wisata_detail.php?id=${widget.id}");
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            namaController.text = data['data']['nama_wisata'];
            deskripsiController.text = data['data']['deskripsi'];
          });
        } else {
          _showSnackbar("Gagal memuat data wisata");
        }
      } else {
        throw Exception("Failed to fetch wisata details");
      }
    } catch (e) {
      _showSnackbar("Error: $e");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    if (kIsWeb) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _submitData() async {
    if (namaController.text.isEmpty || deskripsiController.text.isEmpty) {
      _showSnackbar("Nama wisata dan deskripsi tidak boleh kosong");
      return;
    }

    var uri = Uri.parse("http://localhost/flutter_api/edit_daftarwisata.php");
    var request = http.MultipartRequest('POST', uri);

    request.fields['id_wisata'] = widget.id;
    request.fields['nama_wisata'] = namaController.text;
    request.fields['deskripsi'] = deskripsiController.text;

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    } else if (_webImage != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _webImage!,
        filename: 'image.jpg',
      ));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        if (jsonResponse['status'] == 'success') {
          _showSnackbar("Data berhasil diubah");
          Navigator.pop(context);
        } else {
          _showSnackbar(jsonResponse['message']);
        }
      } else {
        _showSnackbar("Gagal mengubah data");
      }
    } catch (e) {
      _showSnackbar("Error: $e");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Daftar Wisata'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: "Nama Wisata",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: deskripsiController,
                decoration: InputDecoration(
                  labelText: "Deskripsi Wisata",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null && _webImage == null
                      ? Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey))
                      : (kIsWeb
                          ? Image.memory(_webImage!, fit: BoxFit.cover)
                          : Image.file(_image!, fit: BoxFit.cover)),
                ),
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
    );
  }
}
