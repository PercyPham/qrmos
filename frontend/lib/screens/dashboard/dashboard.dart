import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' as qrmos_api;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    _redirectToLoginIfNecessary(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
    );
  }

  Future<void> _redirectToLoginIfNecessary(BuildContext context) async {
    if (!await qrmos_api.hasLoggedIn()) {
      Navigator.of(context).pushNamed("/login");
    }
  }
}
