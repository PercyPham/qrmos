import 'package:flutter/material.dart';

class CreateUserScreen extends StatefulWidget {
  static const routeName = "/create-user";

  const CreateUserScreen({Key? key}) : super(key: key);

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo Người Dùng Mới"),
      ),
    );
  }
}
