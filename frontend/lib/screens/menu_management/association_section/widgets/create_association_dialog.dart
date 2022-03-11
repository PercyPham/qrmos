import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';

class CreateAssociationDialog extends StatefulWidget {
  final int catId;
  final List<MenuItem> items;
  const CreateAssociationDialog({Key? key, required this.catId, required this.items})
      : super(key: key);

  @override
  State<CreateAssociationDialog> createState() => _CreateAssociationDialogState();
}

class _CreateAssociationDialogState extends State<CreateAssociationDialog> {
  int? _pickedItemId;
  String _errMsg = "";

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      _pickedItemId = widget.items[0].id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 10.0,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<int>(
              value: _pickedItemId,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _pickedItemId = val;
                    _errMsg = "";
                  });
                }
              },
              items: widget.items
                  .map((item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ))
                  .toList(),
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
                    child: const Text("Thêm"),
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
    if (_pickedItemId == null) {
      setState(() {
        _errMsg = "Phải chọn item";
      });
      return;
    }

    var resp = await createMenuAssociation(widget.catId, _pickedItemId!);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    Navigator.of(context).pop<bool>(true);
  }
}
