import 'package:flutter/material.dart';

class CreateMenuItemScreen extends StatefulWidget {
  const CreateMenuItemScreen({Key? key}) : super(key: key);

  @override
  State<CreateMenuItemScreen> createState() => _CreateMenuItemScreenState();
}

class _CreateMenuItemScreenState extends State<CreateMenuItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo món mới"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [],
      ),
    );
  }
}
