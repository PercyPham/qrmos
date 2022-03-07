class User {
  final String username;
  final String fullName;
  final String role;
  final bool active;

  User({
    required this.username,
    required this.fullName,
    required this.role,
    required this.active,
  });

  User.fromJson(Map<String, dynamic> data)
      : username = data["username"],
        fullName = data["fullName"],
        role = data["role"],
        active = data["active"] == true ? true : false;
}
