class Admin {
  final String idUser;
  final String username;
  final String password;

  Admin({required this.idUser, required this.username, required this.password});

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      idUser: json['id_user'],
      username: json['username'],
      password: json['password'],  // Since password is int in DB
    );
  }
}
