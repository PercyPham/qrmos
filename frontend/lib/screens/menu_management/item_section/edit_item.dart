import 'package:flutter/material.dart';

class MenuItemEditScreen extends StatefulWidget {
  final int itemId;
  const MenuItemEditScreen(this.itemId, {Key? key}) : super(key: key);

  @override
  State<MenuItemEditScreen> createState() => _MenuItemEditScreenState();
}

class _MenuItemEditScreenState extends State<MenuItemEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa món"),
      ),
      body: const Text("TODO"),
    );
  }
}
