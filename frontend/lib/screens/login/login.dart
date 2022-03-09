import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login";

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _username = "";
  String _password = "";
  String _errMsg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng nhập"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: _inputDecor("Tên đăng nhập"),
              onChanged: _onUsernameChanged,
              keyboardType: TextInputType.text,
            ),
            TextFormField(
              decoration: _inputDecor("Mật khẩu"),
              onChanged: _onPasswordChanges,
              obscureText: true,
            ),
            Container(height: 10),
            Text(_errMsg, style: const TextStyle(color: Colors.red)),
            Container(height: 10),
            ElevatedButton(
              onPressed: _onLoginButtonPressed(context),
              child: const Text("Đăng nhập"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String labelText) {
    return InputDecoration(
      labelText: labelText,
      constraints: const BoxConstraints(maxWidth: 300),
    );
  }

  void _onUsernameChanged(String username) {
    _username = username;
    setState(() {
      _errMsg = "";
    });
  }

  void _onPasswordChanges(String password) {
    _password = password;
    setState(() {
      _errMsg = "";
    });
  }

  void Function() _onLoginButtonPressed(BuildContext context) {
    return () async {
      if (_username == "") {
        setState(() {
          _errMsg = "Tên đăng nhập không được để trống";
        });
        return;
      }
      if (_password == "") {
        setState(() {
          _errMsg = "Mật khẩu không được để trống";
        });
        return;
      }

      var errMsg = await Provider.of<AuthModel>(context, listen: false).login(_username, _password);
      setState(() {
        _errMsg = errMsg;
      });
      if (errMsg != "") {
        return;
      }
      await Navigator.of(context).pushReplacementNamed("/dashboard");
    };
  }
}
