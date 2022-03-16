import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/delivery/delivery.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/order.dart';

import 'custom_button.dart';
import 'error_message.dart';

class ChangeDestDialog extends StatefulWidget {
  final Order order;
  const ChangeDestDialog(this.order, {Key? key}) : super(key: key);

  @override
  State<ChangeDestDialog> createState() => _ChangeDestDialogState();
}

class _ChangeDestDialogState extends State<ChangeDestDialog> {
  bool _isLoading = true;
  List<DeliveryDestination> _dests = [];
  String _chosenDestName = "";
  String _errMsg = "";

  @override
  void initState() {
    super.initState();
    _chosenDestName = widget.order.deliveryDestination;
    _loadDests();
  }

  _loadDests() async {
    setState(() {
      _isLoading = true;
      _dests = [];
    });
    var resp = await getAllDests();
    setState(() {
      _isLoading = false;
      if (resp.error == null) {
        _dests = resp.data!;
        _dests.sort((u1, u2) => u1.name.compareTo(u2.name));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 350,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text("Đổi điểm giao của đơn hàng #${widget.order.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Text("Loading...")
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Điểm giao: "),
                        _dropdownDestList(),
                      ],
                    ),
              const SizedBox(height: 20),
              ErrorMessage(_errMsg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton('Huỷ', () => _onCancel(context)),
                  CustomButton('Lưu', () => _onSave(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _dropdownDestList() {
    return SizedBox(
      width: 150,
      child: DropdownButton<String>(
        value: _chosenDestName,
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _chosenDestName = val;
            });
          }
        },
        items: _dests
            .map((dest) => DropdownMenuItem(
                  value: dest.name,
                  child: Text(dest.name),
                ))
            .toList(),
      ),
    );
  }

  _onCancel(BuildContext context) {
    Navigator.of(context).pop<bool>(false);
  }

  _onSave(BuildContext context) async {
    var resp = await changeOrderDest(widget.order.id, _chosenDestName);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    Navigator.of(context).pop<bool>(true);
  }
}
