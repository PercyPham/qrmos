import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/widgets/big_screen.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/screen_name.dart';
import 'package:qrmos/providers/auth_model.dart';

import 'create_order/create_order.dart';
import 'find_order/find_order.dart';
import 'report/report.dart';
import 'store_config_management.dart';
import 'widgets/order_table.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({Key? key}) : super(key: key);

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  bool _isStoreOpen = false;

  @override
  Widget build(BuildContext context) {
    return BigScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenNameText("Quản lý đơn hàng"),
          Container(height: 20),
          StoreConfigManagement(
            onStoreOpeningChanged: (isOpen) {
              setState(() {
                _isStoreOpen = isOpen;
              });
            },
          ),
          Container(height: 20),
          _actionButtons(context),
          Container(height: 20),
          const OrderTable(),
        ],
      ),
    );
  }

  _actionButtons(BuildContext context) {
    bool isManager = Provider.of<AuthModel>(context).staffRole == StaffRole.manager;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomButton('Tạo đơn', _isStoreOpen ? () => _onCreateButtonPressed(context) : null),
        const SizedBox(width: 15),
        CustomButton('Tìm đơn', () => _onFindOrderButtonPressed(context)),
        if (isManager) const SizedBox(width: 15),
        if (isManager) CustomButton('Báo cáo', () => _onReportButtonPressed(context)),
      ],
    );
  }

  _onCreateButtonPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateOrderScreen()));
  }

  _onFindOrderButtonPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FindOrderScreen()));
  }

  _onReportButtonPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReportScreen()));
  }
}
