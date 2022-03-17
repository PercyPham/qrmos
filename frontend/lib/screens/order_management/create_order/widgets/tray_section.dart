import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/delivery/delivery.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';

import '../../widgets/error_message.dart';
import '../models/temp_create_order_item.dart';
import 'bold_text.dart';

class TraySection extends StatefulWidget {
  final List<TempCreateOrderItem> items;

  const TraySection({
    Key? key,
    this.items = const [],
  }) : super(key: key);

  @override
  State<TraySection> createState() => _TraySectionState();
}

class _TraySectionState extends State<TraySection> {
  bool _isLoading = false;
  List<DeliveryDestination> _dests = [];

  String _cusName = "unknown";
  String _cusPhone = "unknown";
  DeliveryDestination? _dest;

  String _errMsg = '';

  @override
  void initState() {
    super.initState();
    _loadDests();
  }

  Future<void> _loadDests() async {
    setState(() {
      _isLoading = true;
      _dests = [];
    });

    var resp = await getAllDests();
    if (resp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _dests = resp.data!;
      _dests.sort((u1, u2) => u1.name.compareTo(u2.name));
      if (_dests.isNotEmpty) {
        _dest = _dests.firstWhere(
          (d) => d.name == 'counter',
          orElse: () => _dests[0],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoldText('Khay'),
          const SizedBox(height: 10),
          _textInputRow('Tên khách hàng: ', _cusName, (val) {
            setState(() {
              _cusName = val;
            });
          }),
          _textInputRow('Số điện thoại: ', _cusPhone, (val) {
            setState(() {
              _cusPhone = val;
            });
          }),
          _destDropdown(),
          ..._orderItemList(context),
          ErrorMessage(_errMsg),
        ],
      ),
    );
  }

  _textInputRow(String label, initialValue, void Function(String) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        const SizedBox(width: 10),
        SizedBox(
          height: 50,
          width: 150,
          child: TextFormField(initialValue: initialValue, onChanged: onChanged),
        ),
      ],
    );
  }

  _destDropdown() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Điểm giao: '),
        const SizedBox(width: 10),
        SizedBox(
          height: 50,
          width: 150,
          child: DropdownButton<DeliveryDestination>(
            value: _dest,
            onChanged: (val) {
              setState(() {
                _dest = val;
              });
            },
            items: _dests.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
          ),
        ),
        if (_isLoading) const Text('Loading...'),
      ],
    );
  }

  List<Card> _orderItemList(BuildContext context) {
    return widget.items.map((orderItem) => _orderItemCard(context, orderItem)).toList();
  }

  Card _orderItemCard(BuildContext context, TempCreateOrderItem orderItem) {
    return Card(
      elevation: 10,
      child: Text('${orderItem.menuItem.name} x ${orderItem.orderItem.quantity}'),
    );
  }
}
