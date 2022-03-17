import 'package:flutter/material.dart';
import 'package:qrmos/screens/order_management/widgets/order_card.dart';
import 'package:qrmos/services/qrmos/order/order.dart';
import 'package:qrmos/widgets/big_screen.dart';

class OrderCreatedScreen extends StatelessWidget {
  final Order order;
  const OrderCreatedScreen(this.order, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn Hàng Tạo Thành Công'),
      ),
      body: BigScreen(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn hàng #${order.id} đã được tạo thành công',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                )),
            const SizedBox(height: 20),
            OrderCard(order: order, onActionHappened: () {}),
          ],
        ),
      ),
    );
  }
}
