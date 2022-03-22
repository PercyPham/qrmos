import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/order.dart';
import 'package:qrmos/widgets/error_message.dart';

import 'widgets/order_card.dart';

class CusOrderHistoryScreen extends StatefulWidget {
  const CusOrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CusOrderHistoryScreen> createState() => _CusOrderHistoryScreenState();
}

class _CusOrderHistoryScreenState extends State<CusOrderHistoryScreen> {
  bool _isLoading = true;
  int _page = 1;
  int _totalItemCount = 0;
  List<Order> _orders = [];

  String _errMsg = '';

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  _loadOrderHistory() async {
    setState(() {
      _isLoading = true;
      _errMsg = '';
      _orders = [];
    });

    var resp = await getOrders(
      page: _page,
      itemPerPage: 10,
    );
    if (resp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    setState(() {
      _isLoading = false;
      _orders = resp.data!.orders;
      _totalItemCount = resp.data!.total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Lịch sử'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading) const Center(child: Text('Loading...')),
              if (!_isLoading) ..._ordersCards(),
              ErrorMessage(_errMsg),
            ],
          ),
        ),
      ),
    );
  }

  _ordersCards() {
    List<Widget> widgets = [];
    for (int i = 0; i < _orders.length; i++) {
      widgets.add(OrderCard(_orders[i]));
      if (i < _orders.length - 1) widgets.add(const SizedBox(height: 5));
    }
    return widgets;
  }
}
