import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';
import 'package:qrmos/services/qrmos/order/models.dart';
import 'package:qrmos/widgets/tray_item.dart';

import '../order_created/order_created.dart';
import 'widgets/menu_section.dart';
import 'widgets/tray_section.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  bool _isLoading = false;
  List<MenuItem> _menuItems = [];
  String _errMsg = "";

  final List<TrayItem> _trayItems = [];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  _loadMenu() async {
    setState(() {
      _isLoading = true;
    });
    var resp = await getMenu();
    if (resp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }
    setState(() {
      _isLoading = false;
      _menuItems = resp.data!.items;
      _menuItems.sort((a, b) => a.id.compareTo(b.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Đơn Hàng'),
      ),
      body: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: MenuSection(
                isLoading: _isLoading,
                errMsg: _errMsg,
                menuItems: _menuItems,
                onAddOrderItem: (mItem, orderItem) {
                  setState(() {
                    _trayItems.add(TrayItem(
                      menuItem: mItem,
                      orderItem: orderItem,
                    ));
                  });
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: TraySection(
                trayItems: _trayItems,
                onUpdateOrderItem: (trayItem, orderItem) {
                  setState(() {
                    var foundIdx = _trayItems.indexWhere((i) => i.key == trayItem.key);
                    _trayItems[foundIdx] = TrayItem(
                      menuItem: trayItem.menuItem,
                      orderItem: orderItem,
                    );
                  });
                },
                onDeleteTrayItem: (trayItem) {
                  setState(() {
                    _trayItems.remove(trayItem);
                  });
                },
                onOrderCreated: (order) => _onOrderCreated(context, order),
              ),
            ),
          ]),
    );
  }

  _onOrderCreated(BuildContext context, Order order) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => OrderCreatedScreen(order)),
    );
  }
}
