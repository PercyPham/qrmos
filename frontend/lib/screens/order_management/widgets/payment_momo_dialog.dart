import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/order.dart';

class PaymentMoMoDialog extends StatefulWidget {
  final Order order;
  final void Function() onCancel;
  final void Function() onDone;

  const PaymentMoMoDialog(
    this.order, {
    Key? key,
    required this.onCancel,
    required this.onDone,
  }) : super(key: key);

  @override
  State<PaymentMoMoDialog> createState() => _PaymentMoMoDialogState();
}

class _PaymentMoMoDialogState extends State<PaymentMoMoDialog> {
  bool _isLoading = true;
  String _paymentLink = "";
  String _errMsg = "";
  bool _isSuccess = false;
  String _checkMsg = "";
  Color? _checkMsgColor;

  @override
  void initState() {
    super.initState();
    _loadPaymentLink();
  }

  _loadPaymentLink() async {
    setState(() {
      _isLoading = true;
      _paymentLink = "";
      _errMsg = "";
      _checkMsg = "";
    });

    var resp = await createMoMoPaymentLink(widget.order.id);
    if (resp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _paymentLink = resp.data!;
      _errMsg = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _boldText('Đơn hàng #${widget.order.id}'),
          _boldText('Tổng: ${widget.order.total} vnđ'),
          _boldText('Quét QR để thanh toán:'),
          _mainDisplay(),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 10),
            child: Text(_checkMsg, style: TextStyle(color: _checkMsgColor)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _button("Huỷ", !_isSuccess ? widget.onCancel : null),
              const SizedBox(width: 15),
              _button("Làm mới", !_isSuccess ? _loadPaymentLink : null),
              const SizedBox(width: 15),
              _isSuccess
                  ? _button("Đóng", widget.onDone)
                  : _button("Kiểm tra", _onCheckButtonPressed),
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

  _mainDisplay() {
    Widget? content;
    if (_errMsg != "") {
      content = Center(
        child: Text(_errMsg, style: const TextStyle(color: Colors.red)),
      );
    } else if (_isLoading) {
      content = const Center(child: Text("Loading..."));
    } else if (_paymentLink != "") {
      content = QrImage(
        data: _paymentLink,
        version: QrVersions.auto,
        size: 200.0,
      );
    } else {
      content = const Center(child: Text("Something wrong happens"));
    }
    return SizedBox(
      width: 200,
      height: 200,
      child: content,
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

  _onCheckButtonPressed() async {
    setState(() {
      _checkMsg = "Đang kiểm tra ...";
      _checkMsgColor = Colors.blue;
    });
    var resp = await getOrderById(widget.order.id);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    var order = resp.data!;
    if (order.payment != null && order.payment!.success) {
      setState(() {
        _isSuccess = true;
        _checkMsg = "Đơn hàng đã được thanh toán";
        _checkMsgColor = Colors.green[800];
      });
    } else {
      setState(() {
        _checkMsg = "Đơn hàng chưa được thanh toán";
        _checkMsgColor = Colors.red;
      });
    }
  }
}
