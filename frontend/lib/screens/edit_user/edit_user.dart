import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show User, updateUser;

class EditUserScreen extends StatefulWidget {
  static const routeName = "/create-user";
  final User user;

  const EditUserScreen(this.user, {Key? key}) : super(key: key);

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  String _fullName = "";
  String _password = "";
  String _role = "";
  bool _active = true;

  String _errMsg = "";
  String _successMsg = "";

  @override
  void initState() {
    super.initState();
    _fullName = widget.user.fullName;
    _password = "";
    _role = widget.user.role;
    _active = widget.user.active!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh Sửa Thông Tin Người Dùng"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Tên Đăng Nhập: "),
                Text(widget.user.username),
              ],
            ),
            _textInputRow(
                label: "Họ và Tên: ",
                initialValue: _fullName,
                onChanged: (val) {
                  setState(() {
                    _fullName = val;
                    _errMsg = "";
                    _successMsg = "";
                  });
                }),
            _textInputRow(
                label: "Mật khẩu: ",
                initialValue: "",
                onChanged: (val) {
                  setState(() {
                    _password = val;
                    _errMsg = "";
                    _successMsg = "";
                  });
                }),
            _roleInputRow(),
            Row(
              children: [
                const Text("Hoạt động; "),
                Container(width: 20),
                Switch(
                  value: _active,
                  onChanged: (val) {
                    setState(() {
                      _active = val;
                      _errMsg = "";
                      _successMsg = "";
                    });
                  },
                ),
              ],
            ),
            Container(height: 10),
            if (_errMsg != "")
              Text(
                _errMsg,
                style: const TextStyle(color: Colors.red),
              ),
            if (_successMsg != "")
              Text(
                _successMsg,
                style: const TextStyle(color: Colors.green),
              ),
            Container(height: 10),
            ElevatedButton(
              child: const Text("Lưu"),
              onPressed: _onSaveButtonClicked,
            ),
          ],
        ),
      ),
    );
  }

  Row _textInputRow({
    required String label,
    required String initialValue,
    required void Function(String) onChanged,
  }) {
    return Row(
      children: [
        Text(label),
        Container(width: 20),
        SizedBox(
          width: 200,
          child: TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Row _roleInputRow() {
    return Row(children: [
      const Text("Họ và Tên: "),
      Container(width: 20),
      DropdownButton<String>(
        value: _role,
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _role = val;
              _errMsg = "";
              _successMsg = "";
            });
          }
        },
        items: const [
          DropdownMenuItem(
            value: "admin",
            child: Text("Admin"),
          ),
          DropdownMenuItem(
            value: "manager",
            child: Text("Manager"),
          ),
          DropdownMenuItem(
            value: "normal-staff",
            child: Text("Normal Staff"),
          ),
        ],
      )
    ]);
  }

  void _onSaveButtonClicked() async {
    var resp = await updateUser(User(
      username: widget.user.username,
      fullName: _fullName,
      password: _password,
      role: _role,
      active: _active,
    ));

    if (resp.error != null) {
      setState(() {
        _errMsg = resp.error!.message;
      });
      return;
    }

    setState(() {
      _successMsg = "Lưu thành công!";
    });
  }
}
