import 'package:flutter/material.dart';
import 'package:qrmos/widgets/tray_item.dart';

class TrayItemSummary extends StatelessWidget {
  final TrayItem trayItem;
  final void Function() onEditPressed;
  final void Function() onDeletePressed;

  const TrayItemSummary({
    Key? key,
    required this.trayItem,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text('x${trayItem.orderItem.quantity}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trayItem.menuItem.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ..._choices(),
                    _editButton(),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${trayItem.price} đ'),
                  _deleteButton(),
                ],
              )
            ],
          ),
        ),
        const Divider(thickness: 1.5),
      ],
    );
  }

  _choices() {
    List<String> choices = [];
    for (var optName in trayItem.orderItem.options.keys) {
      var optChoices = trayItem.orderItem.options[optName]!;
      choices.addAll(optChoices);
    }
    return choices.map((choice) => Text(choice)).toList();
  }

  _editButton() {
    return GestureDetector(
      onTap: onEditPressed,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
        child: Text('Chỉnh',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.blue[800],
            )),
      ),
    );
  }

  _deleteButton() {
    return GestureDetector(
      onTap: onDeletePressed,
      child: const Padding(
        padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
        child: Text('Xoá', style: TextStyle(color: Colors.red)),
      ),
    );
  }
}
