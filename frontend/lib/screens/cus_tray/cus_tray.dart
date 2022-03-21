import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/create_order.dart';
import 'package:qrmos/services/qrmos/voucher/voucher.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/error_message.dart';
import 'package:qrmos/widgets/tray_item.dart';
import 'package:qrmos/services/local/get_dest_info.dart';

import '../cus_created_order/cus_created_order.dart';
import '../cus_menu_item/edit_tray_item.dart';
import 'widgets/edit_name_dialog.dart';
import 'widgets/edit_phone_dialog.dart';
import 'widgets/tray_item_summary.dart';

class CusTrayScreen extends StatefulWidget {
  final List<TrayItem> trayItems;
  final void Function(TrayItem, CreateOrderItem) onUpdateOrderItem;
  final void Function(TrayItem) onDeleteTrayItem;

  const CusTrayScreen({
    Key? key,
    required this.trayItems,
    required this.onUpdateOrderItem,
    required this.onDeleteTrayItem,
  }) : super(key: key);

  @override
  State<CusTrayScreen> createState() => _CusTrayScreenState();
}

class _CusTrayScreenState extends State<CusTrayScreen> {
  String _voucher = '';
  int _discount = 0;
  String _voucherErrMsg = '';
  String _voucherAppliedMsg = '';

  // ignore: unused_field
  var _forceRedraw = Object();

  String _errMsg = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Khay'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cusInfoSection(),
              const SizedBox(height: 15),
              _orderSummarySection(context),
              const SizedBox(height: 15),
              _voucherInputSection(),
              const SizedBox(height: 15),
              _createOrderSection(context),
            ],
          ),
        ),
      ),
    );
  }

  _cusInfoSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Consumer<AuthModel>(
          builder: (ctx, auth, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Gửi tới:'),
              const SizedBox(height: 10),
              _infoText('Tên: ', auth.userFullName, () => _editNamePressed(ctx)),
              _infoText('Sđt: ', auth.customerPhone, () => _editPhonePressed(ctx)),
              const SizedBox(height: 10),
              _infoText('Tại: ', _getDestNameFromLocal(), null),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
  }

  _infoText(String label, val, void Function()? onEditTap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label),
        Text(val),
        if (onEditTap != null) const SizedBox(width: 5),
        if (onEditTap != null) IconButton(icon: const Icon(Icons.edit), onPressed: onEditTap),
      ],
    );
  }

  _editNamePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EditCusNameDialog(),
    );
  }

  _editPhonePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EditCusPhoneDialog(),
    );
  }

  String _getDestNameFromLocal() {
    final destName = getDestInfo();
    return destName?.name ?? 'Vui lòng quét mã QR tại quán';
  }

  _orderSummarySection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Tóm tắt đơn hàng'),
          const SizedBox(height: 10),
          ...widget.trayItems
              .map((trayItem) => TrayItemSummary(
                    key: trayItem.key,
                    trayItem: trayItem,
                    onEditPressed: () => _onEditTrayItemPressed(context, trayItem),
                    onDeletePressed: () => _onDeleteTrayItem(trayItem),
                  ))
              .toList(),
          _subtotalSummary(),
        ],
      ),
    );
  }

  _onEditTrayItemPressed(BuildContext context, TrayItem trayItem) async {
    var result = await Navigator.of(context).push<CreateOrderItem>(
        MaterialPageRoute(builder: (context) => EditTrayItemScreen(trayItem)));
    if (result != null) {
      widget.onUpdateOrderItem(trayItem, result);
      setState(() {
        _forceRedraw = Object();
      });
    }
  }

  _onDeleteTrayItem(TrayItem trayItem) {
    widget.onDeleteTrayItem(trayItem);
    setState(() {
      _forceRedraw = Object();
    });
  }

  _subtotalSummary() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            flex: 1,
            child: Text('Tổng phụ:'),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${_calculateSubtotal()} đ',
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  _calculateSubtotal() {
    var total = 0;
    for (var trayItem in widget.trayItems) {
      total += trayItem.price;
    }
    return total;
  }

  _voucherInputSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                    decoration: const InputDecoration(label: Text('Voucher')),
                    onChanged: (val) {
                      setState(() {
                        _voucher = val;
                        _discount = 0;
                        _errMsg = '';
                        _voucherErrMsg = '';
                        _voucherAppliedMsg = '';
                      });
                    }),
              ),
              CustomButton('Áp dụng', _onVoucherApply, color: Colors.green),
            ],
          ),
          ErrorMessage(_voucherErrMsg),
          if (_voucherAppliedMsg != '')
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 10),
              child: Text(_voucherAppliedMsg, style: const TextStyle(color: Colors.green)),
            )
        ],
      ),
    );
  }

  void _onVoucherApply() async {
    setState(() {
      _errMsg = '';
      _discount = 0;
      _voucherErrMsg = '';
      _voucherAppliedMsg = '';
    });

    if (_voucher == '') {
      setState(() {
        _voucherErrMsg = 'Chưa nhập voucher';
      });
      return;
    }
    var resp = await getVoucherByCode(_voucher);
    if (resp.error != null) {
      setState(() {
        _voucherErrMsg = translateErrMsg(resp.error);
      });
      return;
    }
    var voucher = resp.data!;
    if (voucher.isUsed) {
      setState(() {
        _voucherErrMsg = 'Voucher đã từng được sử dụng';
      });
      return;
    }
    setState(() {
      _discount = voucher.discount;
      _voucherAppliedMsg = 'Voucher đã được áp dụng';
    });
  }

  _createOrderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_discount > 0) const Text('Tổng phụ:'),
                    if (_discount > 0) const Text('Voucher:'),
                    const Text('Tổng:'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_discount > 0) Text('${_calculateSubtotal()} đ'),
                  if (_discount > 0)
                    Text(
                      '- $_discount đ',
                      style: const TextStyle(color: Colors.green),
                    ),
                  Text('${_calculateTotal()} đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            'Tạo Đơn',
            widget.trayItems.isNotEmpty ? () => _createOrder(context) : null,
            color: widget.trayItems.isNotEmpty ? Colors.brown : Colors.grey[300],
          ),
          if (_errMsg != '') const SizedBox(height: 5),
          if (_errMsg != '') ErrorMessage(_errMsg),
        ],
      ),
    );
  }

  _calculateTotal() {
    var total = _calculateSubtotal() - _discount;
    if (total < 0) return 0;
    return total;
  }

  _createOrder(BuildContext context) async {
    setState(() {
      _errMsg = "";
      _voucherErrMsg = "";
    });

    List<CreateOrderItem> items = [];
    for (var trayItem in widget.trayItems) {
      items.add(trayItem.orderItem);
    }

    var dest = getDestInfo();

    CreateOrderPayload payload = CreateOrderPayload(
      deliveryDest: dest!.name,
      deliveryDestSecurityCode: dest.securityCode!,
      voucher: _discount > 0 ? _voucher : '',
      items: items,
    );

    var resp = await createOrder(payload);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    var createdOrder = resp.data!;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CusOrderCreatedScreen(createdOrder)));
  }
}
