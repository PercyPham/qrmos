import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  final List<TableRow> children;
  final Map<int, TableColumnWidth>? columnWidths;
  const CustomTable({
    Key? key,
    required this.children,
    this.columnWidths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Colors.black,
        style: BorderStyle.solid,
        width: 2,
      ),
      columnWidths: columnWidths,
      defaultColumnWidth: const FixedColumnWidth(150.0),
      children: children,
    );
  }
}
