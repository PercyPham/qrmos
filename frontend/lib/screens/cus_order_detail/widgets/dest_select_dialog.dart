import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/delivery/delivery.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/error_message.dart';

class DestSelectDialog extends StatefulWidget {
  final String currentDestName;

  const DestSelectDialog(this.currentDestName, {Key? key}) : super(key: key);

  @override
  State<DestSelectDialog> createState() => _DestSelectDialogState();
}

class _DestSelectDialogState extends State<DestSelectDialog> {
  bool _isLoading = true;
  String _chosenDest = '';
  List<String> _dests = [];
  String _errMsg = '';

  @override
  void initState() {
    super.initState();
    _chosenDest = widget.currentDestName;
    _loadDests();
  }

  _loadDests() async {
    setState(() {
      _isLoading = true;
    });

    var resp = await getAllDests();
    if (resp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _dests = resp.data!.map((d) => d.name).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chọn Điểm Giao Mới',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            const SizedBox(height: 10),
            if (_errMsg != '') ErrorMessage(_errMsg),
            if (_errMsg != '') const SizedBox(height: 10),
            _isLoading
                ? const Center(child: Text('Loading...'))
                : DropdownButton<String>(
                    value: _chosenDest,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _chosenDest = val;
                          _errMsg = "";
                        });
                      }
                    },
                    items: _dests.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton('Huỷ', () => _onCancel(context), color: Colors.grey),
                const SizedBox(width: 10),
                CustomButton('Lưu', () => _onSave(context), color: Colors.brown),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onCancel(BuildContext context) {
    Navigator.of(context).pop<String>(null);
  }

  _onSave(BuildContext context) {
    Navigator.of(context).pop<String>(_chosenDest);
  }
}
