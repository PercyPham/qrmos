import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' as qrmos;
import 'package:qrmos/screens/create_user/create_user.dart';

import '../user_detail/user_detail.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
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
      _users = [];
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
              ..._userRows(context),
            ],
          ),
          if (_isLoading) const Text("Loading ..."),
          Container(height: 20),
          _createUserButton(context),
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

  List<TableRow> _userRows(BuildContext context) {
    return _users.map((user) => _userRow(user, context)).toList();
  }

  TableRow _userRow(qrmos.User user, BuildContext context) {
    onTap() async {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserDetailScreen(user.username)));
      await _loadUsers();
    }

    return TableRow(
      children: [
        _userRowText(user.username, onTap),
        _userRowText(user.fullName, onTap),
        _userRowText(user.role, onTap),
        _userRowText(user.active == true ? "Có" : "Không", onTap),
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

  ElevatedButton _createUserButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Tạo mới"),
      onPressed: () async {
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const CreateUserScreen()));
        await _loadUsers();
      },
    );
  }
}
