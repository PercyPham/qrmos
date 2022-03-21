import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/error_message.dart';

class EditCusPhoneDialog extends StatefulWidget {
  const EditCusPhoneDialog({Key? key}) : super(key: key);

  @override
  State<EditCusPhoneDialog> createState() => _EditCusPhoneDialogState();
}

class _EditCusPhoneDialogState extends State<EditCusPhoneDialog> {
  String _newPhone = '';
  String _errMsg = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(label: Text('Số điện thoại mới')),
              onChanged: (val) {
                setState(() {
                  _newPhone = val;
                  _errMsg = '';
                });
              },
            ),
            const SizedBox(height: 5),
            ErrorMessage(_errMsg),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton('Huỷ', () => _onCancel(context), color: Colors.brown),
                const SizedBox(width: 10),
                CustomButton('Cập nhật', () => _onUpdate(context), color: Colors.brown),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onCancel(BuildContext context) {
    Navigator.of(context).pop();
  }

  _onUpdate(BuildContext context) async {
    if (_newPhone == '') {
      setState(() {
        _errMsg = 'Số điện thoại mới không được để trống';
      });
    }
    var auth = Provider.of<AuthModel>(context, listen: false);
    var errMsg = await auth.updateCustomer(auth.userFullName, _newPhone);
    if (errMsg != "") {
      setState(() {
        _errMsg = errMsg;
      });
      return;
    }
    Navigator.of(context).pop();
  }
}
