import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/order/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final void Function() onTap;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 10,
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${order.createdAt.toLocal()}',
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                    Text('Giá trị: ${order.total}'),
                  ],
                ),
              ),
              _orderState(),
            ],
          ),
        ),
      ),
    );
  }

  _orderState() {
    switch (order.state) {
      case 'pending':
        return _stateText('Pending', Colors.orange.shade800);
      case 'confirmed':
        return _stateText('Confirmed', Colors.green.shade800);
      case 'ready':
        return _stateText('Ready', Colors.green.shade800);
      case 'delivered':
        return _stateText('Delivered', Colors.green.shade800);
      case 'canceled':
        return _stateText('Canceled', Colors.grey);
      case 'failed':
        return _stateText('Failed', Colors.red);
      default:
        return _stateText('Invalid state\n${order.state}', Colors.black);
    }
  }

  _stateText(String text, Color color) {
    return Text(text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: color,
        ));
  }
}
