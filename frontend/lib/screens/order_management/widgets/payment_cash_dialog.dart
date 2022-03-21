import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/order.dart';
import 'package:qrmos/widgets/error_message.dart';
import 'package:qrmos/widgets/input/number_input_field.dart';

class PaymentCashDialog extends StatefulWidget {
  final Order order;
  final void Function() onCancel;
  final void Function() onDone;

  const PaymentCashDialog(
    this.order, {
    Key? key,
    required this.onCancel,
    required this.onDone,
  }) : super(key: key);

  @override
  State<PaymentCashDialog> createState() => _PaymentCashDialogState();
}

class _PaymentCashDialogState extends State<PaymentCashDialog> {
  int _receive = 0;
  String _errMsg = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _boldText('Đơn hàng #${widget.order.id}'),
          _boldText('Tổng: ${widget.order.total} vnđ'),
          _receiveInput(),
          _boldText(
              'Thối lại: ${_receive > widget.order.total ? _receive - widget.order.total : 0} vnđ'),
          ErrorMessage(_errMsg),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _button("Huỷ", widget.onCancel),
              const SizedBox(width: 15),
              _button("Hoàn thành", _receive < widget.order.total ? null : _onDoneButtonPressed),
            ],
          ),
        ],
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

  _receiveInput() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 80,
          child: NumberInputField(
            decoration: const InputDecoration(
              labelText: "Nhận",
              constraints: BoxConstraints(maxWidth: 300),
            ),
            onChanged: (val) {
              setState(() {
                _receive = val;
              });
            },
          ),
        ),
        const Text('vnđ'),
      ],
    );
  }

  _button(String label, void Function()? onPressed) {
    return ElevatedButton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(label),
      ),
      onPressed: onPressed,
    );
  }

  _onDoneButtonPressed() async {
    var resp = await markOrderAsPaidByCash(widget.order.id);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    widget.onDone();
  }
}
