import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';
import 'package:qrmos/widgets/table/table.dart';

class AssociationTable extends StatelessWidget {
  final bool isLoading;
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final List<MenuAssociation> associations;
  final void Function(int, int) onDeleteButtonPressed;
  final void Function(int) onCreateButtonPressed;

  const AssociationTable({
    Key? key,
    required this.isLoading,
    required this.categories,
    required this.items,
    required this.associations,
    required this.onDeleteButtonPressed,
    required this.onCreateButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTable(
          columnWidths: const {
            0: FixedColumnWidth(200),
            1: FixedColumnWidth(430),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
              ),
              children: const [
                TableHeaderText("Danh mục"),
                TableHeaderText("Món"),
              ],
            ),
            ...categories.map((cat) => _catRow(cat, context)).toList(),
          ],
        ),
        if (isLoading) const Text("Loading..."),
      ],
    );
  }

  TableRow _catRow(MenuCategory cat, BuildContext context) {
    return TableRow(
      children: [
        _rowText(cat.name),
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTable(
                columnWidths: const {
                  0: FixedColumnWidth(150),
                  1: FixedColumnWidth(100),
                },
                children: _getItemOfCat(cat.id)
                    .map((item) => TableRow(
                          children: [
                            _rowText(item.name),
                            _button(
                              label: "Gỡ",
                              onPressed: () {
                                onDeleteButtonPressed(cat.id, item.id);
                              },
                            ),
                          ],
                        ))
                    .toList(),
              ),
              _button(
                label: "Thêm",
                onPressed: () {
                  onCreateButtonPressed(cat.id);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  _rowText(String text) {
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

  List<MenuItem> _getItemOfCat(int catId) {
    Map<int, MenuItem> itemMap = {};
    for (var item in items) {
      itemMap[item.id] = item;
    }

    return associations.where((a) => a.catId == catId).map((a) => itemMap[a.itemId]!).toList();
  }

  _button({
    required String label,
    required void Function() onPressed,
  }) {
    return SizedBox(
      // padding: const EdgeInsets.all(5),
      width: 80,
      height: 30,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: ElevatedButton(
          child: Text(label),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
