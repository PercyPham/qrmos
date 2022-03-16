import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/store_config/store_config.dart';
import 'package:qrmos/widgets/input/number_input_field.dart';

import 'custom_button.dart';
import 'error_message.dart';

class EditStoreOpeningCfgDialog extends StatefulWidget {
  final StoreConfigOpeningHours cfg;
  const EditStoreOpeningCfgDialog(this.cfg, {Key? key}) : super(key: key);

  @override
  State<EditStoreOpeningCfgDialog> createState() => _EditStoreOpeningCfgDialogState();
}

class _EditStoreOpeningCfgDialogState extends State<EditStoreOpeningCfgDialog> {
  bool _isManual = false;
  bool _isManualOpen = false;
  StoreConfigTime _start = StoreConfigTime(0, 0, 0);
  StoreConfigTime _end = StoreConfigTime(0, 0, 0);

  String _errMsg = "";

  @override
  void initState() {
    super.initState();
    _isManual = widget.cfg.isManual;
    _isManualOpen = widget.cfg.isManualOpen;
    _start = widget.cfg.start;
    _end = widget.cfg.end;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(15),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Quản Lý Giờ Mở Cửa",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            _pickAutoOrManual(),
            if (_isManual) _toggleOpenClose(),
            if (!_isManual) _inputStartEndTimes(),
            ErrorMessage(_errMsg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton("Huỷ", () => _onCancel(context)),
                const SizedBox(width: 15),
                CustomButton("Lưu", () => _onSave(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _pickAutoOrManual() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Tự động: "),
        Switch(
          value: !_isManual,
          onChanged: (val) {
            setState(() {
              _isManual = !val;
              _errMsg = "";
            });
          },
        ),
        const SizedBox(width: 10),
        _isManual
            ? const Text("(Thủ công)")
            : const Text("(Tự động)", style: TextStyle(color: Colors.blue)),
      ],
    );
  }

  _toggleOpenClose() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Trạng thái: '),
        Switch(
          value: _isManualOpen,
          onChanged: (val) {
            setState(() {
              _isManualOpen = val;
              _errMsg = "";
            });
          },
        ),
        const SizedBox(width: 10),
        _isManualOpen
            ? const Text("Mở", style: TextStyle(color: Colors.green))
            : const Text("Đóng", style: TextStyle(color: Colors.red)),
      ],
    );
  }

  _inputStartEndTimes() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _timeInputRow(
          label: 'Mở lúc: ',
          time: _start,
        ),
        _timeInputRow(
          label: 'Đóng lúc: ',
          time: _end,
        ),
      ],
    );
  }

  _timeInputRow({
    required String label,
    required StoreConfigTime time,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(
          height: 80,
          width: 80,
          child: NumberInputField(
              decoration: const InputDecoration(
                label: Text("Giờ"),
              ),
              initialValue: time.hour,
              onChanged: (val) {
                setState(() {
                  time.hour = val;
                  _errMsg = "";
                });
              }),
        ),
        const SizedBox(width: 5),
        SizedBox(
          height: 80,
          width: 80,
          child: NumberInputField(
              decoration: const InputDecoration(
                label: Text("Phút"),
              ),
              initialValue: time.min,
              onChanged: (val) {
                setState(() {
                  time.min = val;
                  _errMsg = "";
                });
              }),
        ),
        const SizedBox(width: 5),
        SizedBox(
          height: 80,
          width: 80,
          child: NumberInputField(
              decoration: const InputDecoration(
                label: Text("Giây"),
              ),
              initialValue: time.sec,
              onChanged: (val) {
                setState(() {
                  time.sec = val;
                  _errMsg = "";
                });
              }),
        ),
      ],
    );
  }

  _onCancel(BuildContext context) {
    Navigator.of(context).pop<bool>(false);
  }

  _onSave(BuildContext context) async {
    var resp = await updateStoreCfgOpeningHours(StoreConfigOpeningHours(
      isManual: _isManual,
      isManualOpen: _isManualOpen,
      start: _start,
      end: _end,
    ));
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    Navigator.of(context).pop<bool>(true);
  }
}
