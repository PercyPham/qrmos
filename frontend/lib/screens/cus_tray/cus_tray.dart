import 'package:flutter/material.dart';

class CusTrayScreen extends StatefulWidget {
  const CusTrayScreen({Key? key}) : super(key: key);

  @override
  State<CusTrayScreen> createState() => _CusTrayScreenState();
}

class _CusTrayScreenState extends State<CusTrayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khay'),
      ),
      body: Container(),
    );
  }
}
