import 'package:flutter/material.dart';
import 'package:qrmos/widgets/big_screen.dart';
import 'package:qrmos/widgets/screen_name.dart';

import 'create_order/create_order.dart';
import 'store_config_management.dart';
import 'widgets/custom_button.dart';
import 'widgets/order_table.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({Key? key}) : super(key: key);

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return BigScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenNameText("Quản lý đơn hàng"),
          Container(height: 20),
          const StoreConfigManagement(),
          Container(height: 20),
          _createOrderButton(context),
          Container(height: 20),
          const OrderTable(),
        ],
      ),
    );
  }

  _createOrderButton(BuildContext context) {
    onPressed() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const CreateOrderScreen()));
    }

    return CustomButton('Tạo đơn', onPressed);
  }
}
