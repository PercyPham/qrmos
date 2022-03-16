import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import 'package:qrmos/services/qrmos/order/order.dart';

import 'error_message.dart';
import 'fail_order_dialog.dart';
import 'payment_dialog.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final void Function() onActionHappened;
  const OrderCard({
    Key? key,
    required this.order,
    required this.onActionHappened,
  }) : super(key: key);

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
            _orderValue(),
            _orderFailReason(),
            _orderActions(context),
          ],
        ),
      ),
    );
  }

  _orderId() {
    return Row(
      children: [
        Text(
          '#${order.id}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text('(${order.createdAt.toLocal()})'),
      ],
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
              if (item.note != "")
                Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                    child: Text('Ghi chú: ${item.note}')),
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

  _orderValue() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (order.voucher != null)
          Text('Voucher: ${order.voucher!} [đã giảm: ${order.discount!} vnđ]'),
        Text(
          'Tổng: ${order.total} vnđ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ],
    );
  }

  _orderActions(BuildContext context) {
    var isManager = Provider.of<AuthModel>(context).staffRole == StaffRole.manager;
    var isFailedButtonShown =
        isManager && ['confirmed', 'ready', 'delivered'].contains(order.state);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (order.state == 'pending') _actionButton("Huỷ", _onCancelButtonPressed),
        if (order.state == 'pending')
          _actionButton("Thanh toán", () => _onPayButtonPressed(context)),
        if (isFailedButtonShown)
          _actionButton('Thất bại', () => _onFailedButtonPressed(context), color: Colors.red),
        if (order.state == 'confirmed') _actionButton("Sẵn sàng", _onReadyButtonPressed),
        if (order.state == 'ready') _actionButton("Đã giao", _onDeliveredButtonPressed),
      ],
    );
  }

  _actionButton(String label, void Function() onPressed, {Color? color}) {
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

  void _onCancelButtonPressed() async {
    var resp = await cancelOrder(order.id);
    if (resp.error != null) {
      // ignore: avoid_print
      print(resp.error);
      return;
    }
    onActionHappened();
  }

  void _onPayButtonPressed(BuildContext context) async {
    var result = await showDialog<bool>(
      context: context,
      builder: (_) => PaymentDialog(order),
    );
    if (result == true) {
      onActionHappened();
    }
  }

  void _onFailedButtonPressed(BuildContext context) async {
    var result = await showDialog<bool>(
      context: context,
      builder: (_) => FailOrderDialog(order),
    );
    if (result == true) {
      onActionHappened();
    }
  }

  void _onReadyButtonPressed() async {
    var resp = await readyOrder(order.id);
    if (resp.error != null) {
      // ignore: avoid_print
      print(resp.error);
      return;
    }
    onActionHappened();
  }

  void _onDeliveredButtonPressed() async {
    var resp = await deliverOrder(order.id);
    if (resp.error != null) {
      // ignore: avoid_print
      print(resp.error);
      return;
    }
    onActionHappened();
  }

  _orderFailReason() {
    return order.failReason == null
        ? const SizedBox(height: 0, width: 0)
        : ErrorMessage('Nguyên do thất bại: ${order.failReason}');
  }
}
