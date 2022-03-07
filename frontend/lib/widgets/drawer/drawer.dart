import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(builder: (context, authModel, _) {
      if (authModel.userType != UserType.staff) {
        return const Drawer();
      }
      return Drawer(
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
            if (authModel.staffRole == StaffRole.admin) ..._adminDrawer(),
            if (authModel.staffRole == StaffRole.manager) ..._managerDrawer(),
            if (authModel.staffRole == StaffRole.normalStaff) ..._normalStaffDrawer(),
          ],
        ),
      );
    });
  }

  List<Widget> _adminDrawer() {
    return [
      ..._addListTile("Quản lý nhân viên", null),
    ];
  }

  List<Widget> _managerDrawer() {
    return [
      ..._addListTile("Quản lý điểm giao", null),
      ..._addListTile("Quản lý menu", null),
      ..._addListTile("Quản lý voucher", null),
      ..._addListTile("Quản lý đơn hàng", null),
    ];
  }

  List<Widget> _normalStaffDrawer() {
    return [
      ..._addListTile("Quản lý menu", null),
      ..._addListTile("Quản lý đơn hàng", null),
    ];
  }

  List<Widget> _addListTile(String title, void Function()? onTap) {
    return [
      ListTile(
        title: Text(title),
        onTap: onTap,
      ),
      const Divider(),
    ];
  }
}
