import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';
import 'package:qrmos/services/qrmos/order/create_order.dart';

class TrayItem {
  final Key key;
  final MenuItem menuItem;
  final CreateOrderItem orderItem;

  TrayItem({
    required this.menuItem,
    required this.orderItem,
  }) : key = UniqueKey();

  int get price {
    var unitPrice = menuItem.baseUnitPrice;

    for (var optName in orderItem.options.keys) {
      var choiceNames = orderItem.options[optName]!;
      for (var choiceName in choiceNames) {
        unitPrice += menuItem.options[optName]!.choices[choiceName]!.price;
      }
    }

    return unitPrice * orderItem.quantity;
  }
}
