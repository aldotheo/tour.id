import 'package:flutter/material.dart';
import 'api/api_service.dart';
import 'Admin/admin.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Admin>> futureAdmin;

  @override
  void initState() {
    super.initState();
    futureAdmin = ApiService().fetchAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Data'),
      ),
      body: FutureBuilder<List<Admin>>(
        future: futureAdmin,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].username),
                  subtitle: Text("ID: ${snapshot.data![index].idUser}"),
                );
              },
            );
          }
        },
      ),
    );
  }
}
