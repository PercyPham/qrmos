import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/order/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard(this.order, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _orderId(),
            _orderDetail(),
            _orderActions(),
          ],
        ),
      ),
    );
  }

  _orderId() {
    return Text(
      '#${order.id}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  _orderDetail() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _orderItems(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _orderDelivery(),
            Container(height: 30),
            _orderStatus(),
          ],
        ),
      ],
    );
  }

  _orderItems() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(300),
        1: FixedColumnWidth(100),
      },
      children: [
        ...order.orderItems!.map((item) => _orderItem(item)).toList(),
      ],
    );
  }

  _orderItem(OrderItem item) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ...item.options.keys
                  .map((opt) => Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text('- $opt'),
                            ...item.options[opt]!
                                .map((choice) => Text('       + $choice'))
                                .toList(),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            const Text('Số lượng: '),
            Text('${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
          ]),
        ),
      ],
    );
  }

  _orderDelivery() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(80),
        },
        children: [
          _orderDeliveryRow("Điểm giao:", order.deliveryDestination),
          _orderDeliveryRow("Tên:", order.customerName),
          _orderDeliveryRow("Điện thoại:", order.customerPhone),
        ],
      ),
    );
  }

  _orderDeliveryRow(String label, value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
          child: Text(label),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              )),
        ),
      ],
    );
  }

  _orderStatus() {
    return Text(
      order.state,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  _orderActions() {
    return Container();
  }
}
