import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show createMenuCat, translateErrMsg;

class CreateMenuCatDialog extends StatefulWidget {
  const CreateMenuCatDialog({Key? key}) : super(key: key);

  @override
  State<CreateMenuCatDialog> createState() => _CreateMenuCatDialogState();
}

class _CreateMenuCatDialogState extends State<CreateMenuCatDialog> {
  String _name = "";
  String _description = "";
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
            const Text("Tạo danh mục", style: TextStyle(fontWeight: FontWeight.bold)),
            _textFormField(
              label: "Tên",
              autofocus: true,
              onChanged: (val) {
                setState(() {
                  _name = val;
                  _errMsg = "";
                });
              },
            ),
            const SizedBox(height: 10, width: 10),
            _textFormField(
              label: "Mô tả",
              isMultipleLine: true,
              onChanged: (val) {
                setState(() {
                  _description = val;
                  _errMsg = "";
                });
              },
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
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _textFormField({
    required String label,
    bool autofocus = false,
    bool isMultipleLine = false,
    void Function(String)? onChanged,
  }) {
    return SizedBox(
      width: 250,
      child: TextFormField(
        textAlignVertical: TextAlignVertical.top,
        maxLines: isMultipleLine ? null : 1,
        decoration: InputDecoration(
          labelText: label,
          constraints: const BoxConstraints(maxWidth: 300),
        ),
        autofocus: autofocus,
        onChanged: onChanged,
      ),
    );
  }

  _onCreateButtonPressed(BuildContext context) async {
    if (_name == "") {
      setState(() {
        _errMsg = "Tên danh mục không được để trống";
      });
      return;
    }

    var resp = await createMenuCat(_name, _description);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    Navigator.of(context).pop<bool>(true);
  }
}
