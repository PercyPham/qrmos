import 'package:flutter/material.dart';

class CusOrderHistoryScreen extends StatefulWidget {
  const CusOrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CusOrderHistoryScreen> createState() => _CusOrderHistoryScreenState();
}

class _CusOrderHistoryScreenState extends State<CusOrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử', style: TextStyle(color: Colors.brown)),
        backgroundColor: Colors.white,
      ),
      body: Container(),
    );
  }
}
