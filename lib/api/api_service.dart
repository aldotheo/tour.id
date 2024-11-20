import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Admin/admin.dart';

class ApiService {
  final String apiUrl = "http://localhost/flutter_api/login/get_admin.php";// Use your local server IP address or localhost for emulator

  Future<List<Admin>> fetchAdmin() async {
    final response = await http.get(Uri.parse('$apiUrl/get_admin.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((admin) => Admin.fromJson(admin)).toList();
    } else {
      throw Exception('Failed to load admin');
    }
  }
}
