import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/delivery/delivery.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/voucher/voucher.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/error_message.dart';
import '../models/tray_item.dart';
import 'bold_text.dart';
import 'tray_item_card.dart';

class TraySection extends StatefulWidget {
  final List<TrayItem> trayItems;

  const TraySection({
    Key? key,
    this.trayItems = const [],
  }) : super(key: key);

  @override
  State<TraySection> createState() => _TraySectionState();
}

class _TraySectionState extends State<TraySection> {
  bool _isLoading = false;
  List<DeliveryDestination> _dests = [];

  String _cusName = "unknown";
  String _cusPhone = "unknown";

  String _voucher = "";
  int _discount = 0;
  String _voucherErrMsg = "";

  DeliveryDestination? _dest;

  String _errMsg = '';

  @override
  void initState() {
    super.initState();
    _loadDests();
  }

  _loadDests() async {
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

  _checkVoucher() async {
    setState(() {
      _discount = 0;
      _voucherErrMsg = "";
    });
    if (_voucher == "") {
      return;
    }
    var resp = await getVoucherByCode(_voucher);
    if (resp.error != null) {
      setState(() {
        _discount = 0;
        _voucherErrMsg = translateErrMsg(resp.error);
      });
      return;
    }
    var voucher = resp.data!;
    if (voucher.isUsed) {
      setState(() {
        _discount = 0;
        _voucherErrMsg = "voucher đã được sử dụng";
      });
      return;
    }
    setState(() {
      _discount = voucher.discount;
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
          _voucherInput(),
          const SizedBox(height: 20),
          const Text('Danh sách món:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ..._trayItemList(context),
          const SizedBox(height: 10),
          _total(),
          const SizedBox(height: 10),
          ErrorMessage(_errMsg),
          CustomButton('Tạo', _onCreate),
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

  _voucherInput() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _textInputRow('Voucher: ', _voucher, (val) {
          setState(() {
            _voucher = val;
            _discount = 0;
            _voucherErrMsg = "";
          });
        }),
        const SizedBox(width: 10),
        CustomButton('Kiểm tra', _checkVoucher),
        const SizedBox(width: 10),
        ErrorMessage(_voucherErrMsg),
        if (_discount > 0)
          const Text('Thành công!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      ],
    );
  }

  List<TrayItemCard> _trayItemList(BuildContext context) {
    return widget.trayItems
        .map((trayItem) => TrayItemCard(
              trayItem: trayItem,
              onTap: () {},
            ))
        .toList();
  }

  _total() {
    var total = _calculateTotal();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tổng: $total vnđ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )),
        if (_discount > 0)
          Text('Giảm: $_discount vnđ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              )),
        if (_discount > 0)
          Text('Còn: ${total - _discount > 0 ? total - _discount : 0} vnđ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )),
      ],
    );
  }

  int _calculateTotal() {
    var total = 0;
    for (var trayItem in widget.trayItems) {
      total += trayItem.price;
    }
    return total;
  }

  void _onCreate() {
    // TODO: implement
  }
}
