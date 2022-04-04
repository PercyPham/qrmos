import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_model.dart';

import 'screens/login/login.dart';
import 'screens/dashboard/dashboard.dart';
import 'screens/cus_menu/cus_menu.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthModel()),
    ],
    child: const MyApp(),
  ));
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
        "/": (context) => const CusMenuScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
        CusMenuScreen.routeName: (context) => const CusMenuScreen(),
      },
    );
  }
}
