import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testaja/daftarwisata_page.dart';
import 'package:testaja/karetogi_page.dart';
import 'package:testaja/pengaturan_page.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _destinations = []; // List to store destination data

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Function to fetch data from the API
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost/flutter_api/get_data.php'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _destinations = data['data']; // Store destination data
          });
        } else {
          print('No data found');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Membatasi baseSize agar elemen tidak terlalu besar di layar besar
    double baseSize = (screenWidth * 0.85).clamp(300.0, 600.0);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Menu Wisata'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.home, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(baseSize * 0.02),
        child: Column(
          children: [
            // Menu buttons
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMenuButton(Icons.map, "Daftar Wisata", baseSize, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DaftarWisataPage()),
                    );
                  }),
                  _buildMenuButton(Icons.category, "Kategori", baseSize, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => KategoriPage()),
                    );
                  }),
                  _buildMenuButton(Icons.settings, "Pengaturan", baseSize, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PengaturanPage()),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Displaying list of destinations
            Expanded(
              child: Container(
                padding: EdgeInsets.all(baseSize * 0.02),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(baseSize * 0.05),
                ),
                child: _destinations.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _destinations.length,
                        itemBuilder: (context, index) {
                          final destination = _destinations[index];
                          return _buildDestinationCard(
                            destination['nama_wisata'],
                            destination['deskripsi'],
                            destination['image_url'],
                            baseSize,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create menu button widget
  Widget _buildMenuButton(
      IconData icon, String label, double baseSize, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: baseSize * 0.12, color: Colors.black), // Ikon dengan batas ukuran
          SizedBox(height: baseSize * 0.01),
          Text(
            label,
            style: TextStyle(color: Colors.black, fontSize: baseSize * 0.04), // Teks dengan batas ukuran
          ),
        ],
      ),
    );
  }

  // Create destination card widget
  Widget _buildDestinationCard(
      String title, String description, String imageUrl, double baseSize) {
    String fullImageUrl = "http://localhost/flutter_api/$imageUrl";

    return Card(
      margin: EdgeInsets.symmetric(vertical: baseSize * 0.015),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(baseSize * 0.03)),
      child: Row(
        children: [
          // Destination image
          Container(
            width: baseSize * 0.30, // Gambar dengan batas ukuran
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(baseSize * 0.03),
                bottomLeft: Radius.circular(baseSize * 0.03),
              ),
              child: Image.network(
                fullImageUrl,
                width: baseSize * 0.30,
                height: baseSize * 0.20,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, size: 50, color: Colors.red);
                },
              ),
            ),
          ),
          // Destination details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(baseSize * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: baseSize * 0.04, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: baseSize * 0.01),
                  Text(
                    description,
                    style: TextStyle(fontSize: baseSize * 0.035, color: Colors.grey[700]),
                  ),
                  SizedBox(height: baseSize * 0.015),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewDaftarWisataPage(destination: title),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      backgroundColor: Colors.grey[300],
                    ),
                    child: Text("View", style: TextStyle(fontSize: baseSize * 0.035)),
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

class ViewDaftarWisataPage extends StatelessWidget {
  final dynamic destination;

  const ViewDaftarWisataPage({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destination),
      ),
      body: Center(
        child: Text(
          'Detail Wisata: $destination',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
