class User {
  final String username;
  final String fullName;
  final String role;
  final bool isActive;

  User({
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
  });

  User.fromJson(Map<String, dynamic> data)
      : username = data["username"],
        fullName = data["fullName"],
        role = data["role"],
        isActive = data["isActive"] == true ? true : false;
}
