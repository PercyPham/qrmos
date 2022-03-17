import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import '../models/tray_item.dart';

class TrayItemCard extends StatelessWidget {
  final TrayItem trayItem;
  final void Function() onChangeButtonPressed;
  final void Function() onDeleteButtonPressed;

  const TrayItemCard({
    Key? key,
    required this.trayItem,
    required this.onChangeButtonPressed,
    required this.onDeleteButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _itemNameAndQuan(),
            ...trayItem.orderItem.options.keys
                .where((optName) => trayItem.orderItem.options[optName]!.isNotEmpty)
                .map((optName) => _option(optName, trayItem.orderItem.options[optName]!))
                .toList(),
            const SizedBox(height: 10),
            if (trayItem.orderItem.note != "") _note(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton('Xoá', onDeleteButtonPressed, color: Colors.red),
                const SizedBox(width: 10),
                CustomButton('Chỉnh', onChangeButtonPressed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _itemNameAndQuan() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: Text(trayItem.menuItem.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              )),
        ),
        Text('x ${trayItem.orderItem.quantity}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            )),
      ],
    );
  }

  _option(String optName, List<String> choices) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(optName),
        ...choices.map((choice) => Text(' + $choice')).toList(),
      ],
    );
  }

  _note() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ghi chú: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(trayItem.orderItem.note),
      ],
    );
  }
}
