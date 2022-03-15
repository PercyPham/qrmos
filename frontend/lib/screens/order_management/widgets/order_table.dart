import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';

import 'order_card.dart';

class OrderTable extends StatefulWidget {
  const OrderTable({Key? key}) : super(key: key);

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  final double _pageWidth = 800;
  final int _itemPerPage = 5;

  bool _isLoading = true;
  int _page = 1;
  int _totalPage = 1;
  String _state = "pending";

  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    setState(() {
      _isLoading = true;
      _orders = [];
      _totalPage = 0;
    });

    var resp = await getOrders(
      page: _page,
      itemPerPage: _itemPerPage,
      state: _state,
      sortCreatedAt: "desc",
    );
    if (resp.error != null) {
      // ignore: avoid_print
      print(resp.error);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _orders = resp.data!.orders;
      _totalPage = (resp.data!.total / _itemPerPage).ceil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _stateMenu(),
        _isLoading
            ? const Center(child: Text("Loading..."))
            : Table(
                columnWidths: {0: FixedColumnWidth(_pageWidth)},
                children: [
                  ..._orders
                      .map((order) => TableRow(children: [
                            OrderCard(
                              order: order,
                              onActionHappened: _loadOrders,
                            )
                          ]))
                      .toList(),
                ],
              ),
        _tablePageNav(),
      ],
    );
  }

  _stateMenu() {
    var stateNames = {
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'ready': 'Ready',
      'delivered': 'Delivered',
      'failed': 'Failed',
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...stateNames.keys
            .map((state) => _stateMenuItem(
                  state: state,
                  stateName: stateNames[state]!,
                  isHighlighted: _state == state,
                  width: _pageWidth / (stateNames.keys.length),
                  onPressed: () {
                    setState(() {
                      _state = state;
                      _page = 1;
                      _loadOrders();
                    });
                  },
                ))
            .toList(),
      ],
    );
  }

  _stateMenuItem({
    required String state,
    required String stateName,
    bool isHighlighted = false,
    double width = 120,
    bool hasNewOrder = false,
    required void Function() onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        color: isHighlighted ? Colors.blue[200] : null,
        width: width,
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stateName,
                style: TextStyle(
                  fontWeight: isHighlighted ? FontWeight.bold : null,
                  fontSize: isHighlighted ? 18 : 15,
                  decoration: isHighlighted ? TextDecoration.underline : null,
                )),
            if (hasNewOrder) const Icon(Icons.new_releases, color: Colors.red, size: 10),
          ],
        ),
      ),
    );
  }

  _tablePageNav() {
    var currentPage = _page;
    var hasPrevPage = currentPage > 1;
    var hasNextPage = currentPage < _totalPage;

    onPrevButtonPressed() {
      setState(() {
        _page -= 1;
        _loadOrders();
      });
    }

    onNextButtonPressed() {
      setState(() {
        _page += 1;
        _loadOrders();
      });
    }

    return Container(
      width: _pageWidth,
      height: 100,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _smallButton("<", hasPrevPage ? onPrevButtonPressed : null),
          Container(width: 10),
          Text('$currentPage', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Container(width: 10),
          _smallButton(">", hasNextPage ? onNextButtonPressed : null),
          Container(width: 30),
          Text('Total pages: $_totalPage'),
        ],
      ),
    );
  }

  _smallButton(String char, void Function()? onPressed) {
    return ElevatedButton(
      child: Text(char),
      onPressed: onPressed,
    );
  }
}
