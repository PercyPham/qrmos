import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';
import 'package:qrmos/services/qrmos/order/create_order.dart';

import '../../widgets/error_message.dart';
import 'bold_text.dart';
import 'menu_item_card.dart';
import 'order_item_dialog.dart';

class MenuSection extends StatelessWidget {
  final bool isLoading;
  final String errMsg;
  final List<MenuItem> menuItems;
  final void Function(MenuItem, CreateOrderItem) onAddOrderItem;

  const MenuSection({
    Key? key,
    this.isLoading = false,
    this.errMsg = '',
    this.menuItems = const [],
    required this.onAddOrderItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: Colors.grey[300],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoldText('Menu'),
            const SizedBox(height: 10),
            ErrorMessage(errMsg),
            const SizedBox(height: 10),
            ...menuItems
                .map((mItem) => MenuItemCard(
                      item: mItem,
                      onTap: () => _onTap(context, mItem),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  _onTap(BuildContext context, MenuItem mItem) async {
    var result = await showDialog<CreateOrderItem>(
      context: context,
      builder: (_) => OrderItemDialog(menuItem: mItem),
    );
    if (result != null) {
      onAddOrderItem(mItem, result);
    }
  }
}
