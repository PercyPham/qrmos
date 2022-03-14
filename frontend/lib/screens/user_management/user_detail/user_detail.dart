import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show User, getUserByUsername;
import 'package:qrmos/widgets/big_screen.dart';
import '../edit_user/edit_user.dart';

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
    _loadUserDetail(widget.username);
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
          : BigScreen(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên đăng nhập: ${_user!.username}'),
                  Text('Họ và Tên: ${_user!.fullName}'),
                  Text('Chức vụ: ${_user!.role}'),
                  Text('Hoạt động: ${_user!.active == true ? "Có" : "Không"}'),
                  Container(height: 20),
                  ElevatedButton(
                    child: const Text('Chỉnh sửa'),
                    onPressed: () {
                      _onEditButtonPress(context);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  void _onEditButtonPress(BuildContext context) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => EditUserScreen(_user!)));
    await _loadUserDetail(widget.username);
  }
}
