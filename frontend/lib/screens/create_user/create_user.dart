import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show User, createUser;

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({Key? key}) : super(key: key);

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  String _username = "";
  String _fullName = "";
  String _password = "";
  String _role = "normal-staff";

  String _errMsg = "";
  String _successMsg = "";

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
            _textInputRow(
                label: "Tên Đăng Nhập: ",
                onChanged: (val) {
                  setState(() {
                    _username = val;
                    _errMsg = "";
                    _successMsg = "";
                  });
                }),
            _textInputRow(
                label: "Họ và Tên: ",
                onChanged: (val) {
                  setState(() {
                    _fullName = val;
                    _errMsg = "";
                    _successMsg = "";
                  });
                }),
            _textInputRow(
                label: "Mật khẩu: ",
                onChanged: (val) {
                  setState(() {
                    _password = val;
                    _errMsg = "";
                    _successMsg = "";
                  });
                }),
            _roleInputRow(),
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
              child: const Text("Tạo"),
              onPressed: _onCreateButtonClicked,
            ),
          ],
        ),
      ),
    );
  }

  Row _textInputRow({
    required String label,
    required void Function(String) onChanged,
  }) {
    return Row(
      children: [
        Text(label),
        Container(width: 20),
        SizedBox(
          width: 200,
          child: TextFormField(
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Row _roleInputRow() {
    return Row(children: [
      const Text("Chức vụ: "),
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

  void _onCreateButtonClicked() async {
    var resp = await createUser(User(
      username: _username,
      fullName: _fullName,
      password: _password,
      role: _role,
    ));

    if (resp.error != null) {
      setState(() {
        _errMsg = resp.error!.message;
      });
      return;
    }

    setState(() {
      _successMsg = "Tạo thành công!";
    });
  }
}
