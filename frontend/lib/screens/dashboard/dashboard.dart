import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import './widgets/drawer/drawer.dart';
import '../user_management/user_management.dart';

const screenUserManagement = "Quản lý người dùng";
const screenDeliveryManagement = "Quản lý điểm giao";
const screenMenuManagement = "Quản lý menu";
const screenVoucherManagement = "Quản lý voucher";
const screenOrderManagement = "Quản lý đơn hàng";
const screenNone = "none";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String currentScreen = screenNone;

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthModel>(context).loadAccessTokenFromLocal();
    return Scaffold(
      appBar: _appBar(context),
      drawer: _drawer(context),
      body: _body(),
    );
  }

  AppBar _appBar(BuildContext context) {
    var auth = Provider.of<AuthModel>(context, listen: false);
    return AppBar(
      title: const Text("Bảng điều khiển"),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thoát tài khoản!")),
      );
    };
  }

  Widget _drawer(BuildContext context) {
    List<String> navList = [];

    var staffRole = Provider.of<AuthModel>(context).staffRole;
    switch (staffRole) {
      case StaffRole.admin:
        navList = [
          screenUserManagement,
        ];
        break;
      case StaffRole.manager:
        navList = [
          screenDeliveryManagement,
          screenMenuManagement,
          screenVoucherManagement,
          screenOrderManagement,
        ];
        break;
      case StaffRole.normalStaff:
        navList = [
          screenMenuManagement,
          screenOrderManagement,
        ];
        break;
      default:
        break;
    }

    return AppDrawer(
      navList: navList,
      activeScreen: currentScreen,
      onTap: (tappedNav) {
        setState(() {
          currentScreen = tappedNav;
        });
      },
    );
  }

  Widget _body() {
    return Consumer<AuthModel>(
      builder: (context, auth, _) {
        if (auth.userType != UserType.staff) {
          return _emptyScreenWithLoginButton(context);
        }
        if (currentScreen == screenUserManagement) {
          return const UserManagement();
        }
        return Center(child: Text("Hello " + auth.userFullName));
      },
    );
  }

  Widget _emptyScreenWithLoginButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
          child: const Text("Đăng nhập"),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed("/login");
          }),
    );
  }
}
