import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/order.dart';
import 'package:qrmos/widgets/big_screen.dart';
import 'package:qrmos/widgets/table/table.dart';

import '../widgets/custom_button.dart';
import '../widgets/error_message.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen(this.orderId, {Key? key}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = false;
  Order? _order;
  List<OrderLog> _orderLogs = [];
  String _errMsg = "";

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _order = null;
      _orderLogs = [];
      _errMsg = "";
    });

    var orderResp = await getOrderById(widget.orderId);
    if (orderResp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(orderResp.error);
      });
      return;
    }

    var logsResp = await getOrderLogs(widget.orderId);
    if (logsResp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(logsResp.error);
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _order = orderResp.data;
      _orderLogs = logsResp.data!;
      _orderLogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng #${widget.orderId}'),
      ),
      body: BigScreen(
        child: _isLoading
            ? const Text("Loading...")
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomButton('Làm mới', _loadOrderDetails),
                  const SizedBox(height: 10),
                  ErrorMessage(_errMsg),
                  _boldText('Trạng thái: ${_order!.state}'),
                  _boldText('Tạo lúc: ${_order!.createdAt.toLocal()} [Asia/Ho_Chi_Minh]'),
                  _boldText('Tên khách hàng: ${_order!.customerName}'),
                  _boldText('Số điện thoại: ${_order!.customerPhone}'),
                  _boldText('Điểm giao hàng: ${_order!.deliveryDestination}'),
                  _boldText('Chi tiết món:'),
                  _orderItems(),
                  _boldText('Logs của đơn hàng:'),
                  _orderLogsTable(),
                ],
              ),
      ),
    );
  }

  _boldText(String text) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      height: 30,
      child: Text(text,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 18,
          )),
    );
  }

  _orderItems() {
    return CustomTable(
      columnWidths: const {
        0: FixedColumnWidth(300),
        1: FixedColumnWidth(100),
      },
      children: [
        ..._order!.orderItems!.map((item) => _orderItem(item)).toList(),
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

  _orderLogsTable() {
    return CustomTable(
      columnWidths: const {
        0: FixedColumnWidth(200),
        1: FixedColumnWidth(220),
        2: FixedColumnWidth(350),
        3: FixedColumnWidth(250),
      },
      children: [
        const TableRow(
          children: [
            TableHeaderText("Thời điểm"),
            TableHeaderText("Hành động"),
            TableHeaderText("Thực hiện bởi"),
            TableHeaderText("Thông tin thêm"),
          ],
        ),
        ..._orderLogs.map((orderLog) => _orderLogRow(orderLog)).toList(),
      ],
    );
  }

  _orderLogRow(OrderLog log) {
    return TableRow(
      children: [
        Text('  ${log.createdAt.toLocal()}'),
        Text('  ' + log.action),
        log.actor.type == 'staff'
            ? Text('  Nhân viên: ${log.actor.staffUsername}')
            : Text('  Khách hàng: ${log.actor.customerId}'),
        Text(log.extra != null ? '  ' + log.extra! : ''),
      ],
    );
  }
}
