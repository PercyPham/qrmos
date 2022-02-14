import 'package:flutter/material.dart';
import 'package:qrmos/screens/home/home.dart';
import 'package:qrmos/screens/login/login.dart';
import 'package:qrmos/screens/dashboard/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QRMOS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const HomeScreen(title: 'QRMOS'),
        "/login": (context) => const LoginScreen(),
        "/dashboard": (context) => const DashboardScreen(),
      },
    );
  }
}
