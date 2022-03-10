import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show MenuCategory;
import 'package:qrmos/widgets/table/table.dart';

class CategoryTable extends StatelessWidget {
  final bool isLoading;
  final List<MenuCategory> categories;
  final void Function(int) onCatDeleteButtonPressed;

  const CategoryTable({
    Key? key,
    required this.isLoading,
    required this.categories,
    required this.onCatDeleteButtonPressed,
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
                TableHeaderText("Hành động"),
              ],
            ),
            ...categories.map((cat) => _catRow(cat, context)),
          ],
        ),
        if (isLoading) const Text("Loading..."),
      ],
    );
  }

  TableRow _catRow(MenuCategory cat, BuildContext context) {
    return TableRow(children: [
      _catRowText('${cat.id}'),
      _catRowText(cat.name),
      _catRowText(cat.description),
      Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
        child: ElevatedButton(
          child: const Text("Xoá"),
          onPressed: () {
            onCatDeleteButtonPressed(cat.id);
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
