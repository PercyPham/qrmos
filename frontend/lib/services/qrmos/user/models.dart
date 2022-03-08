class User {
  final String username;
  final String fullName;
  final String? password;
  final String role;
  final bool? active;

  User({
    required this.username,
    this.password,
    required this.fullName,
    required this.role,
    this.active,
  });

  User.fromJson(Map<String, dynamic> data)
      : username = data["username"],
        password = data["password"] ?? "",
        fullName = data["fullName"],
        role = data["role"],
        active = data["active"] == true ? true : false;
}
