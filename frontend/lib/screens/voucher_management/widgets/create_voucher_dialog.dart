import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show createVoucher, translateErrMsg;
import 'package:qrmos/widgets/input/number_input_field.dart';

class CreateVoucherDialog extends StatefulWidget {
  const CreateVoucherDialog({Key? key}) : super(key: key);

  @override
  State<CreateVoucherDialog> createState() => _CreateVoucherDialogState();
}

class _CreateVoucherDialogState extends State<CreateVoucherDialog> {
  String _code = "";
  int _discount = 0;
  String _errMsg = "";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 10.0,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Code",
                  constraints: BoxConstraints(maxWidth: 300),
                ),
                autofocus: true,
                onChanged: (val) {
                  setState(() {
                    _code = val;
                    _errMsg = "";
                  });
                },
              ),
            ),
            SizedBox(
              width: 150,
              child: NumberInputField(
                decoration: const InputDecoration(
                  labelText: "Giá trị",
                  constraints: BoxConstraints(maxWidth: 300),
                ),
                onChanged: (val) {
                  setState(() {
                    _discount = val;
                    _errMsg = "";
                  });
                },
              ),
            ),
            const SizedBox(height: 10, width: 5),
            Text(_errMsg, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10, width: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: const Text("Huỷ"),
                  onPressed: () {
                    Navigator.of(context).pop<bool>(false);
                  },
                ),
                Container(width: 10),
                ElevatedButton(
                    child: const Text("Tạo"),
                    onPressed: () {
                      _onCreateButtonPressed(context);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onCreateButtonPressed(BuildContext context) async {
    if (_code == "") {
      setState(() {
        _errMsg = "Mã code không được để trống";
      });
      return;
    }
    if (_discount <= 0) {
      setState(() {
        _errMsg = "Giá trị phải lớn hơn 0";
      });
      return;
    }
    var resp = await createVoucher(_code, _discount);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    Navigator.of(context).pop<bool>(true);
  }
}
