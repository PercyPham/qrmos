import 'package:flutter/material.dart';
import 'package:qrmos/widgets/big_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Báo Cáo"),
      ),
      body: BigScreen(
        child: Container(), //TODO implement
      ),
    );
  }
}
