import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/order/order.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/error_message.dart';

import 'widgets/dest_select_dialog.dart';
import 'widgets/order_item.dart';
import 'widgets/pending_payment_section.dart';

class CusOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const CusOrderDetailScreen(this.orderId, {Key? key}) : super(key: key);

  @override
  State<CusOrderDetailScreen> createState() => _CusOrderDetailScreenState();
}

class _CusOrderDetailScreenState extends State<CusOrderDetailScreen> {
  bool _isLoading = true;
  Order? _order;

  String _errMsg = '';

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errMsg = '';
      _order = null;
    });
    var resp = await getOrderById(widget.orderId);
    if (resp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    setState(() {
      _isLoading = false;
      _order = resp.data!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng #${widget.orderId}'),
        backgroundColor: Colors.brown,
      ),
      body: _errMsg != ''
          ? Center(child: ErrorMessage(_errMsg))
          : _isLoading
              ? const Center(child: Text('Loading...'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _stateText(),
                        const SizedBox(height: 10),
                        _stateExtraSection(),
                        const SizedBox(height: 10),
                        _infoText('Tên người nhận: ', _order!.customerName),
                        _infoText('Số điện thoại: ', _order!.customerPhone),
                        _infoText('Tạo lúc: ', '${_order!.createdAt.toLocal()}'),
                        _infoText(
                          'Nhận tại: ',
                          _order!.deliveryDestination,
                          onEditPressed: _onEditDestPressed(context),
                        ),
                        if (_order!.voucher != null) _infoText('Voucher: ', '${_order!.voucher}'),
                        const SizedBox(height: 10),
                        const Divider(thickness: 1.5),
                        ..._order!.orderItems!.map((item) => OrderItemCard(item)).toList(),
                        const SizedBox(height: 20),
                        _totalSection(),
                        const SizedBox(height: 20),
                        _actionButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  _stateText() {
    switch (_order!.state) {
      case 'pending':
        return _colorText('Pending', Colors.orange.shade800);
      case 'confirmed':
        return _colorText('Confirmed', Colors.green.shade800);
      case 'ready':
        return _colorText('Ready', Colors.green.shade800);
      case 'delivered':
        return _colorText('Delivered', Colors.green.shade800);
      case 'canceled':
        return _colorText('Canceled', Colors.grey);
      case 'failed':
        return _colorText('Failed', Colors.red);
      default:
        return _colorText(_order!.state, Colors.black);
    }
  }

  _colorText(String text, Color color) {
    return Center(
      child: Text(text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: color,
          )),
    );
  }

  _infoText(String label, value, {void Function()? onEditPressed}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 120, child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (onEditPressed != null) const SizedBox(width: 10),
          if (onEditPressed != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEditPressed,
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  _onEditDestPressed(BuildContext context) {
    if (!['pending', 'confirmed'].contains(_order!.state)) {
      return null;
    }
    return () async {
      var result = await showDialog(
        context: context,
        builder: (context) => DestSelectDialog(_order!.deliveryDestination),
      );
      if (result != null) {
        var resp = await changeOrderDest(_order!.id, result);
        if (resp.error != null) {
          setState(() {
            _errMsg = translateErrMsg(resp.error);
          });
          return;
        }
        _loadOrder();
      }
    };
  }

  _totalSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('Tổng giá trị: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            )),
        Text('${_order!.total} đ',
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
            )),
      ],
    );
  }

  _stateExtraSection() {
    switch (_order!.state) {
      case 'pending':
        return PendingPaymentSection(_order!.id);
      case 'confirmed':
        return _stateInfoText(
            'Đơn hàng đã được xác nhận!\n\nFWCX đang chuẩn bị món.', Colors.green);
      case 'ready':
        return _stateInfoText(
            'Đơn hàng đã được chuẩn bị xong!\n\nFWCX đang chuẩn bị giao.', Colors.green);
      case 'delivered':
        return _stateInfoText('Đơn hàng đã được giao thành công!', Colors.green);
      case 'canceled':
        return _stateInfoText('Đơn hàng đã được huỷ!', Colors.grey);
      case 'failed':
        return _stateInfoText(
            'Đơn hàng đã thất bại!\n\nNguyên do: ${_order!.failReason}', Colors.red);
      default:
        return Container();
    }
  }

  _stateInfoText(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: TextStyle(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  _actionButtons() {
    var shouldShowUpdateButton =
        ['pending', 'confirmed', 'ready', 'delivered'].contains(_order!.state);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_order!.state == 'pending') CustomButton('Huỷ', _onCancel, color: Colors.red),
        const SizedBox(width: 10),
        if (shouldShowUpdateButton) CustomButton('Cập nhật', _loadOrder, color: Colors.brown),
      ],
    );
  }

  void _onCancel() async {
    var resp = await cancelOrder(widget.orderId);
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    _loadOrder();
  }
}
