import 'package:flutter/material.dart';
import 'package:testaja/menu.dart';
import 'package:testaja/screens/spalsh_screen.dart';

class PengaturanPage extends StatelessWidget {
  // Simulate fetching data of logged-in user (replace with actual database fetch)
  final Map<String, String> userData = {
    'name': 'Admin',
    'email': 'Admin1234567@gmail.com',
    'password': 'Svbjbdvbdvbvbkbk'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Menu()),
            );
          },
        ),
        title: Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white),  // Change text color to white
        ),
        backgroundColor: Colors.green,  // Change header background color to green
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Menu()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header with background and profile image
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/kominfo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/kominfo.png'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60),
            Text(
              userData['name']!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.edit, color: const Color.fromARGB(255, 255, 255, 255)),
            SizedBox(height: 20),

            // User Info Tiles
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.person, 'Admin', userData['name']!),
                    SizedBox(height: 10),
                    _buildInfoTile(Icons.email, 'Email', userData['email']!),
                    SizedBox(height: 10),
                    _buildInfoTile(Icons.lock, 'Password', userData['password']!),
                    SizedBox(height: 10),

                    // Logout Button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to SplashScreen when user logs out
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SplashScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(double.infinity, 50), // Full width button
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
