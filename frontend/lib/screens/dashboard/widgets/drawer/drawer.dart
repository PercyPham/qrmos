import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';

class AppDrawer extends StatelessWidget {
  final String activeScreen;
  final List<String> navList;
  final void Function(String)? onTap;

  const AppDrawer({
    Key? key,
    required this.navList,
    required this.activeScreen,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(builder: (context, authModel, _) {
      if (authModel.userType != UserType.staff) {
        return const Drawer();
      }
      return Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBar(
                title: Column(
                  children: [
                    Text(authModel.userFullName),
                    Text('(${authModel.staffRoleStr})'),
                  ],
                ),
              ),
              ..._listTiles(),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _listTiles() {
    List<Widget> list = [];
    for (var i = 0; i < navList.length; i++) {
      var navName = navList[i];
      list.add(_listTile(
        navName,
        navName == activeScreen,
      ));
      list.add(const Divider());
    }
    return list;
  }

  ListTile _listTile(String nav, bool isBold) {
    return ListTile(
        title: Text(
          nav,
          style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
        onTap: () {
          if (onTap == null) {
            return;
          }
          onTap!(nav);
        });
  }
}
