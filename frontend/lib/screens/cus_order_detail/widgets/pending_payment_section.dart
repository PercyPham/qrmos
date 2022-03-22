// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/payment.dart';
import 'package:qrmos/widgets/error_message.dart';

class PendingPaymentSection extends StatefulWidget {
  final int orderID;
  const PendingPaymentSection(this.orderID, {Key? key}) : super(key: key);

  @override
  State<PendingPaymentSection> createState() => _PendingPaymentSectionState();
}

class _PendingPaymentSectionState extends State<PendingPaymentSection> {
  bool _isLoading = true;
  String _momoPaymentLink = '';
  String _errMsg = '';

  @override
  void initState() {
    super.initState();
    _loadMoMoPaymentLink();
  }

  _loadMoMoPaymentLink() async {
    setState(() {
      _isLoading = true;
      _errMsg = '';
    });
    var resp = await createMoMoPaymentLink(widget.orderID);
    if (resp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = 'Không thể thanh toán vì:\n' + translateErrMsg(resp.error);
      });
      return;
    }
    setState(() {
      _isLoading = false;
      _momoPaymentLink = resp.data!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _errMsg != ''
        ? Center(child: ErrorMessage(_errMsg))
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              _greenText('Đơn hàng đã được tạo thành công!'),
              const SizedBox(height: 10),
              _greenText('Thanh toán ngay bằng:'),
              const SizedBox(height: 10),
              _momoPaymentButton(),
              const SizedBox(height: 10),
              _greenText('Hoặc Quý Khách vui lòng di chuyển tới quầy để thanh toán'),
              const SizedBox(height: 10),
            ],
          );
  }

  _greenText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.green),
      textAlign: TextAlign.center,
    );
  }

  _momoPaymentButton() {
    return ElevatedButton(
      child: _isLoading
          ? const Text('Loading...')
          : const Text('MoMo', style: TextStyle(color: Colors.white)),
      onPressed: _momoPaymentLink == '' ? null : _onMomoPaymentButtonPressed,
      style:
          _isLoading ? null : ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.pink)),
    );
  }

  _onMomoPaymentButtonPressed() {
    js.context.callMethod('open', [_momoPaymentLink, '_self']);
  }
}
