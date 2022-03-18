import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/order.dart';
import 'package:qrmos/widgets/big_screen.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/error_message.dart';
import 'package:qrmos/widgets/input/number_input_field.dart';

import '../widgets/order_card.dart';

class FindOrderScreen extends StatefulWidget {
  const FindOrderScreen({Key? key}) : super(key: key);

  @override
  State<FindOrderScreen> createState() => _FindOrderScreenState();
}

class _FindOrderScreenState extends State<FindOrderScreen> {
  bool _isLoading = false;
  int _orderId = 0;
  Order? _foundOrder;
  String _errMsg = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm Đơn Hàng'),
      ),
      body: BigScreen(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 10, height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: NumberInputField(
                      autofocus: true,
                      initialValue: _orderId,
                      decoration: const InputDecoration(
                        label: Text('Mã đơn hàng'),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _orderId = val;
                          _errMsg = "";
                        });
                      }),
                ),
                const SizedBox(width: 10, height: 10),
                CustomButton('Tìm', _onFindButtonPressed),
                const SizedBox(width: 10, height: 10),
                if (_isLoading) const Text("Loading..."),
                ErrorMessage(_errMsg),
              ],
            ),
            if (_foundOrder != null) const SizedBox(height: 20),
            if (_foundOrder != null) OrderCard(order: _foundOrder!),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _onFindButtonPressed() async {
    setState(() {
      _isLoading = true;
      _foundOrder = null;
    });
    var resp = await getOrderById(_orderId);
    if (resp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    setState(() {
      _isLoading = false;
      _foundOrder = resp.data;
    });
  }
}
