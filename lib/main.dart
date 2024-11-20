 import 'package:flutter/material.dart';
import '../screens/spalsh_screen.dart';  // Import the file where the HomePage widget is defined
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisata Barsel',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(), // Set HomePage as the initial screen
    );
  }
}