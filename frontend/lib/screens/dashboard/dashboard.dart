import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import 'package:qrmos/widgets/drawer/drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    Provider.of<AuthModel>(context).loadAccessTokenFromLocal();
    return Scaffold(
      appBar: _appBar(context),
      drawer: const AppDrawer(),
      body: _body(),
    );
  }

  AppBar _appBar(BuildContext context) {
    var auth = Provider.of<AuthModel>(context, listen: false);
    return AppBar(
      title: const Text("Dashboard"),
      actions: [
        if (auth.userType == UserType.staff)
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout(context),
          ),
      ],
    );
  }

  Future<void> Function() _logout(BuildContext context) {
    return () async {
      var auth = Provider.of<AuthModel>(context, listen: false);
      await auth.logout();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logged out!")));
    };
  }

  Widget _body() {
    return Consumer<AuthModel>(
      builder: (context, auth, _) {
        if (auth.userType != UserType.staff) {
          return Center(
            child: TextButton(
                child: const Text("Login"),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed("/login");
                }),
          );
        }

        return Center(child: Text("Hello " + auth.userFullName));
      },
    );
  }
}
