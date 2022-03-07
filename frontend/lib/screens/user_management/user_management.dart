import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' as qrmos;

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  bool _isLoading = true;
  List<qrmos.User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    var resp = await qrmos.getAllUsers();
    setState(() {
      _isLoading = false;
      if (resp.error == null) {
        _users = resp.data!;
        _users.sort((u1, u2) => (u1.role + u1.username).compareTo(u2.role + u2.username));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quản lý người dùng",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          Container(height: 20),
          Table(
            border: TableBorder.all(
              color: Colors.black,
              style: BorderStyle.solid,
              width: 2,
            ),
            defaultColumnWidth: const FixedColumnWidth(150.0),
            children: [
              _tableHeaders(),
              ..._userRows(),
            ],
          ),
          if (_isLoading) const Text("Loading ..."),
        ],
      ),
    );
  }

  TableRow _tableHeaders() {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
      ),
      children: [
        _tableHeaderText("Username"),
        _tableHeaderText("Họ và Tên"),
        _tableHeaderText("Chức vụ"),
        _tableHeaderText("Hoạt động"),
      ],
    );
  }

  Widget _tableHeaderText(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<TableRow> _userRows() {
    return _users.map((user) => _userRow(user)).toList();
  }

  TableRow _userRow(qrmos.User user) {
    var onTap = () {
      print("tapped on " + user.username);
    };
    return TableRow(
      children: [
        _userRowText(user.username, onTap),
        _userRowText(user.fullName, onTap),
        _userRowText(user.role, onTap),
        _userRowText(user.active ? "Có" : "Không", onTap),
      ],
    );
  }

  Widget _userRowText(String text, void Function() onTap) {
    return TableRowInkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
