import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show MenuItem;
import 'package:qrmos/widgets/table/table.dart';

class ItemTable extends StatelessWidget {
  final bool isLoading;
  final List<MenuItem> items;
  final void Function(int, bool) onToggleItemAvailabilityPressed;
  final void Function(int) onItemDetailButtonPressed;

  const ItemTable({
    Key? key,
    required this.isLoading,
    required this.items,
    required this.onToggleItemAvailabilityPressed,
    required this.onItemDetailButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTable(
          columnWidths: const {
            0: FixedColumnWidth(80),
            1: FixedColumnWidth(150),
            2: FixedColumnWidth(300),
            3: FixedColumnWidth(100),
            4: FixedColumnWidth(100),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
              ),
              children: const [
                TableHeaderText("ID"),
                TableHeaderText("Tên"),
                TableHeaderText("Mô Tả"),
                TableHeaderText("Còn Hàng"),
                TableHeaderText("Hoạt động"),
                TableHeaderText("Chi Tiết"),
              ],
            ),
            ...items.map((cat) => _catRow(cat, context)),
          ],
        ),
        if (isLoading) const Text("Loading..."),
      ],
    );
  }

  TableRow _catRow(MenuItem item, BuildContext context) {
    return TableRow(children: [
      _catRowText('${item.id}'),
      _catRowText(item.name),
      _catRowText(item.description),
      Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
        child: Switch(
            value: item.available,
            onChanged: (val) => onToggleItemAvailabilityPressed(item.id, val)),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
        child: Center(
          child: item.isChoosable
              ? const Text('Có', style: TextStyle(color: Colors.green))
              : const Text('Không', style: TextStyle(color: Colors.red)),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
        child: ElevatedButton(
          child: const Text("Chi Tiết"),
          onPressed: () {
            onItemDetailButtonPressed(item.id);
          },
        ),
      ),
    ]);
  }

  _catRowText(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
