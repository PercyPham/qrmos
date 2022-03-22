import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/order/order.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItem orderItem;

  const OrderItemCard(this.orderItem, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text('x${orderItem.quantity}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderItem.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ..._choices(),
                    if (orderItem.note != '') Text('Ghi chú: ${orderItem.note}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1.5),
      ],
    );
  }

  _choices() {
    List<String> choices = [];
    for (var optName in orderItem.options.keys) {
      var optChoices = orderItem.options[optName]!;
      choices.addAll(optChoices);
    }
    return choices.map((choice) => Text('- $choice')).toList();
  }
}
