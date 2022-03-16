import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/order/order.dart';

import 'payment_cash_dialog.dart';
import 'payment_momo_dialog.dart';

class PaymentDialog extends StatefulWidget {
  final Order order;
  const PaymentDialog(this.order, {Key? key}) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

const _paymentMethodCash = 'cash';
const _paymentMethodMoMo = 'momo';

class _PaymentDialogState extends State<PaymentDialog> {
  String _method = _paymentMethodCash;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 10.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _methodMenu(),
          if (_method == _paymentMethodCash)
            PaymentCashDialog(
              widget.order,
              onCancel: () => _onCancel(context),
              onDone: () => _onDone(context),
            ),
          if (_method == _paymentMethodMoMo)
            PaymentMoMoDialog(
              widget.order,
              onCancel: () => _onCancel(context),
              onDone: () => _onDone(context),
            ),
        ],
      ),
    );
  }

  _methodMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _methodMenuItem(
          name: "Tiền mặt",
          isHighlighted: _method == _paymentMethodCash,
          onTap: () {
            setState(() {
              _method = _paymentMethodCash;
            });
          },
        ),
        _methodMenuItem(
          name: "MoMo",
          isHighlighted: _method == _paymentMethodMoMo,
          onTap: () {
            setState(() {
              _method = _paymentMethodMoMo;
            });
          },
        ),
      ],
    );
  }

  _methodMenuItem({
    required String name,
    required bool isHighlighted,
    required void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
        child: Text(
          name,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : null,
            fontSize: isHighlighted ? 15 : 14,
            decoration: isHighlighted ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }

  _onCancel(BuildContext context) {
    Navigator.of(context).pop<bool>(false);
  }

  _onDone(BuildContext context) {
    Navigator.of(context).pop<bool>(true);
  }
}
