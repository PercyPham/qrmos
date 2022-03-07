import 'package:flutter/material.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
            ],
          ),
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
}
