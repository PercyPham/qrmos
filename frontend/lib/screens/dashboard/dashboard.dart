import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import 'package:qrmos/widgets/drawer/drawer.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' as qrmos_api;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    Provider.of<AuthModel>(context).loadAccessTokenFromLocal();
    return Consumer<AuthModel>(
      builder: (ctx, auth, _) => Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard"),
          actions: [
            if (auth.userType == UserType.staff)
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () async {
                  await auth.logout();
                },
              ),
          ],
        ),
        drawer: const AppDrawer(),
        body: _body(),
      ),
    );
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
