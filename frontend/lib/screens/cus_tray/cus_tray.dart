import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import 'package:qrmos/services/qrmos/order/create_order.dart';
import 'package:qrmos/widgets/tray_item.dart';
import 'package:qrmos/services/local/get_dest_info.dart';

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
              const SizedBox(height: 10),
              _orderSummarySection(context),
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
              _infoText('Tên: ', auth.userFullName, () => _editNamePressed(context)),
              _infoText('Sđt: ', auth.customerPhone, () => _editPhonePressed(context)),
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
                    onDeletePressed: () => widget.onDeleteTrayItem(trayItem),
                  ))
              .toList(),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  flex: 1,
                  child: Text('Tổng tạm:'),
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
          ),
        ],
      ),
    );
  }

  _onEditTrayItemPressed(BuildContext context, TrayItem trayItem) async {
    var result = await Navigator.of(context).push<CreateOrderItem>(
        MaterialPageRoute(builder: (context) => EditTrayItemScreen(trayItem)));
    if (result != null) {
      widget.onUpdateOrderItem(trayItem, result);
    }
  }

  _calculateSubtotal() {
    var total = 0;
    for (var trayItem in widget.trayItems) {
      total += trayItem.price;
    }
    return total;
  }
}
