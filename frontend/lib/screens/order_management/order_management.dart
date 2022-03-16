import 'package:flutter/material.dart';
import 'package:qrmos/widgets/big_screen.dart';
import 'package:qrmos/widgets/screen_name.dart';

import 'store_config_management.dart';
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
          const OrderTable(),
        ],
      ),
    );
  }
}
