import 'package:flutter/material.dart';
import 'package:qrmos/common/hcm_time.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/order.dart';
import 'package:qrmos/widgets/big_screen.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/error_message.dart';
import 'package:qrmos/widgets/table/table.dart';

import 'widgets/datetime_range_picker.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _reportForToday = true;
  late DateTime _chosenStart;
  late DateTime _chosenEnd;

  bool _isLoadingReport = false;
  List<Order> _orders = [];

  String _errMsg = '';

  @override
  void initState() {
    super.initState();

    var now = DateTime.now();
    now = now.subtract(Duration(
      milliseconds: now.millisecond,
      microseconds: now.microsecond,
    ));
    _chosenStart = now.subtract(const Duration(days: 1));
    _chosenEnd = now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Báo Cáo"),
      ),
      body: BigScreen(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _todayToggle(),
              if (!_reportForToday) _datetimeRangePicker(),
              const SizedBox(height: 10),
              CustomButton('Kiểm Tra', _loadOrdersForReport),
              const SizedBox(height: 10),
              ErrorMessage(_errMsg),
              const SizedBox(height: 10),
              if (_isLoadingReport) const Text("Loading..."),
              if (_orders.isNotEmpty) _reportSection(),
            ],
          ),
        ),
      ),
    );
  }

  _todayToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Báo cáo cho hôm nay:'),
        const SizedBox(width: 5),
        Switch(
            value: _reportForToday,
            onChanged: (val) {
              setState(() {
                _reportForToday = val;
              });
            }),
      ],
    );
  }

  _datetimeRangePicker() {
    return DateTimeRangePicker(
      initialStartDateTime: _chosenStart,
      initialEndDateTime: _chosenEnd,
      onStartChanged: (start) {
        setState(() {
          _chosenStart = start;
        });
      },
      onEndChanged: (end) {
        setState(() {
          _chosenEnd = end;
        });
      },
    );
  }

  void _loadOrdersForReport() async {
    setState(() {
      _isLoadingReport = true;
      _orders = [];
    });

    if (_reportForToday) {
      setState(() {
        _chosenStart = getStartOfTodayInHcmTz();
        _chosenEnd = getNowInHcmTz();
      });
    }

    int start = _chosenStart.microsecondsSinceEpoch * 1000;
    int end = _chosenEnd.microsecondsSinceEpoch * 1000;

    var resp = await getOrders(
      from: start,
      to: end,
      itemPerPage: 1,
      page: 1,
    );
    if (resp.error != null) {
      setState(() {
        _isLoadingReport = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    int total = resp.data!.total;
    resp = await getOrders(
      from: start,
      to: end,
      itemPerPage: total,
      page: 1,
    );
    if (resp.error != null) {
      setState(() {
        _isLoadingReport = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    setState(() {
      _isLoadingReport = false;
      _orders = resp.data!.orders.where((o) => !['pending', 'canceled'].contains(o.state)).toList();
    });
  }

  _reportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Từ: ${_chosenStart.toLocal()} - Đến: ${_chosenEnd.toLocal()}'),
        const Text('Tức:'),
        Text('Từ: ${_chosenStart.toString()} - Đến: ${_chosenEnd.toString()} (Asia/Ho_Chi_Minh)'),
        const SizedBox(height: 10),
        Text('Tiền mặt thay đổi: ${_calculateCashChange()} đ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        Text('Tiền tài khoản MoMo thay đổi: ${_calculateMoMoChange()} đ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        CustomTable(
          columnWidths: const {
            0: FixedColumnWidth(60),
            1: FixedColumnWidth(180),
            2: FixedColumnWidth(100),
            3: FixedColumnWidth(100),
            4: FixedColumnWidth(150),
          },
          children: [
            const TableRow(
              children: [
                TableHeaderText('Order ID'),
                TableHeaderText('Tạo lúc'),
                TableHeaderText('Trạng thái'),
                TableHeaderText('Phương thức thanh toán'),
                TableHeaderText('Giá trị'),
              ],
            ),
            ..._orders.map((o) => _orderRow(o)).toList(),
          ],
        ),
      ],
    );
  }

  TableRow _orderRow(Order order) {
    return TableRow(
      children: [
        _rowText('${order.id}'),
        _rowText('${order.createdAt.toLocal()}'),
        _rowText(order.state),
        _rowText(order.payment!.type),
        _rowText('${order.total}'),
      ],
    );
  }

  _rowText(String text) {
    return Padding(padding: const EdgeInsets.all(5), child: Text(text));
  }

  _calculateCashChange() {
    int change = 0;
    for (var order in _orders) {
      if (_isMoneyCollectable(order)) {
        if (order.payment!.type == 'cash') {
          change += order.total;
        }
      }
    }
    return change;
  }

  _calculateMoMoChange() {
    int change = 0;
    for (var order in _orders) {
      if (_isMoneyCollectable(order)) {
        if (order.payment!.type == 'momo') {
          change += order.total;
        }
      }
    }
    return change;
  }

  bool _isMoneyCollectable(Order order) {
    if (['pending', 'canceled', 'failed'].contains(order.state)) {
      return false;
    }
    return true;
  }
}
