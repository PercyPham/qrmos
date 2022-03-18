import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/error_message.dart';

class CusInfoInputScreen extends StatefulWidget {
  const CusInfoInputScreen({Key? key}) : super(key: key);

  @override
  State<CusInfoInputScreen> createState() => _CusInfoInputScreenState();
}

class _CusInfoInputScreenState extends State<CusInfoInputScreen> {
  String _name = '';
  String _phone = '';
  String _errMsg = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity, height: 1),
          const Text(
            'FlyWithCodeX\nCoffee',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _textInput(
              label: 'Chúng mình gọi bạn như thế nào?',
              onChanged: (val) {
                setState(() {
                  _name = val;
                });
              }),
          const SizedBox(height: 10),
          _textInput(
              label: 'Số điện thoại của bạn?',
              onChanged: (val) {
                setState(() {
                  _phone = val;
                });
              }),
          const SizedBox(height: 20),
          ErrorMessage(_errMsg),
          const SizedBox(height: 10),
          CustomButton('Tiếp Tục', _onContinueButtonPressed, color: Colors.green),
        ],
      ),
    );
  }

  _textInput({
    required String label,
    required void Function(String) onChanged,
  }) {
    return SizedBox(
      width: 250,
      child: TextFormField(
        decoration: InputDecoration(
          label: Text(label),
        ),
        onChanged: onChanged,
      ),
    );
  }

  void _onContinueButtonPressed() async {
    setState(() {
      _errMsg = '';
    });
    var errMsg = await Provider.of<AuthModel>(context, listen: false).createCustomer(_name, _phone);
    if (errMsg != "") {
      setState(() {
        _errMsg = errMsg;
      });
    }
  }
}
