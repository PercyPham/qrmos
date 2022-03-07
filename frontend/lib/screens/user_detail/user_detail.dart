import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show User, getUserByUsername;

class UserDetailScreen extends StatefulWidget {
  static const routeName = "/user-detail";

  final String username;

  const UserDetailScreen(
    this.username, {
    Key? key,
  }) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    var username = widget.username;
    _loadUserDetail(username);
  }

  Future<void> _loadUserDetail(String username) async {
    setState(() {
      _isLoading = true;
      _user = null;
    });

    var resp = await getUserByUsername(username);
    if (resp.error != null) {
      return;
    }
    setState(() {
      _isLoading = false;
      _user = resp.data!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông Tin Chi Tiết Người Dùng"),
      ),
      body: _isLoading
          ? const Text("Loading...")
          : Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên đăng nhập: ${_user!.username}'),
                  Text('Họ và Tên: ${_user!.fullName}'),
                  Text('Chức vụ: ${_user!.role}'),
                  Text('Hoạt động: ${_user!.active}'),
                ],
              ),
            ),
    );
  }
}
