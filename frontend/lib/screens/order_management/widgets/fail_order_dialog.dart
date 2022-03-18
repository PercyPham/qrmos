import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/order.dart';
import 'package:qrmos/widgets/error_message.dart';

class FailOrderDialog extends StatefulWidget {
  final Order order;

  const FailOrderDialog(this.order, {Key? key}) : super(key: key);

  @override
  State<FailOrderDialog> createState() => _FailOrderDialogState();
}

class _FailOrderDialogState extends State<FailOrderDialog> {
  String _failReason = "";
  String _errMsg = "";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 10.0,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _boldText('Đơn hàng #${widget.order.id}'),
            _boldText('Tổng: ${widget.order.total} vnđ'),
            _reasonInput(),
            ErrorMessage(_errMsg),
            const SizedBox(height: 15),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _button("Huỷ", () => _onCancel(context)),
                const SizedBox(width: 15),
                _button("Xác nhận", _failReason == "" ? null : () => _onConfirm(context))
              ],
            ),
          ],
        ),
      ),
    );
  }

  _boldText(String text) {
    return SizedBox(
      height: 30,
      child: Text(text,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 18,
          )),
    );
  }

  _reasonInput() {
    return SizedBox(
      width: 300,
      child: TextFormField(
        maxLines: null,
        decoration: const InputDecoration(
          labelText: "Nguyên do thất bại: ",
          constraints: BoxConstraints(maxWidth: 300),
        ),
        onChanged: (val) {
          setState(() {
            _failReason = val;
            _errMsg = "";
          });
        },
      ),
    );
  }

  _button(String label, void Function()? onPressed, {Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ElevatedButton(
          child: Text(label),
          onPressed: onPressed,
          style: color == null
              ? null
              : ButtonStyle(backgroundColor: MaterialStateProperty.all(color))),
    );
  }

  _onCancel(BuildContext context) {
    Navigator.of(context).pop<bool>(false);
  }

  _onConfirm(BuildContext context) async {
    var resp = await failOrder(widget.order.id, _failReason);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    Navigator.of(context).pop<bool>(true);
  }
}
