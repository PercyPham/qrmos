import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show createDest, translateErrMsg;

class CreateDestDialog extends StatefulWidget {
  const CreateDestDialog({Key? key}) : super(key: key);

  @override
  State<CreateDestDialog> createState() => _CreateDestDialogState();
}

class _CreateDestDialogState extends State<CreateDestDialog> {
  String _name = "";
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
              child: TextField(
                autofocus: true,
                onChanged: (val) {
                  setState(() {
                    _name = val;
                    _errMsg = "";
                  });
                },
              ),
            ),
            Text(_errMsg, style: const TextStyle(color: Colors.red)),
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
    if (_name == "") {
      setState(() {
        _errMsg = "Tên điểm giao nhận không được để trống";
      });
      return;
    }

    var resp = await createDest(_name);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    Navigator.of(context).pop<bool>(true);
  }
}
