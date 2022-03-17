import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';
import 'package:qrmos/services/qrmos/order/create_order.dart';

class TempCreateOrderItem {
  final Key key;
  final MenuItem menuItem;
  final CreateOrderItem orderItem;

  TempCreateOrderItem({
    required this.menuItem,
    required this.orderItem,
  }) : key = UniqueKey();
}
