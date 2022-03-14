import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';
import 'package:qrmos/widgets/table/table.dart';

import 'edit_item.dart';

class MenuItemDetailScreen extends StatefulWidget {
  final int itemId;
  const MenuItemDetailScreen(this.itemId, {Key? key}) : super(key: key);

  @override
  State<MenuItemDetailScreen> createState() => _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends State<MenuItemDetailScreen> {
  bool _isLoading = false;
  MenuItem? _item;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  _loadItem() async {
    setState(() {
      _isLoading = true;
      _item = null;
    });
    var resp = await getMenuItem(widget.itemId);
    if (resp.error != null) {
      // ignore: avoid_print
      print(resp.error);
      return;
    }
    setState(() {
      _isLoading = false;
      _item = resp.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthModel>(context).staffRole;
    var isManager = auth == StaffRole.manager;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết món"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: _isLoading
            ? const Text("Loading...")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tên món: ${_item!.name}'),
                  Text('Mô tả: ${_item!.description}'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Còn hàng:"),
                      Switch(
                          value: _item!.available,
                          onChanged: (val) async {
                            await setItemAvailable(_item!.id, val);
                            _loadItem();
                          }),
                    ],
                  ),
                  SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.network(_item!.image, fit: BoxFit.cover)),
                  const Text("Lựa chọn:"),
                  _itemOptions(),
                  if (isManager) Container(height: 10),
                  if (isManager)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          child: const Text('Chỉnh sửa'),
                          onPressed: () async {
                            await _openEditPage(context);
                            _loadItem();
                          },
                        ),
                        const SizedBox(height: 10, width: 10),
                        ElevatedButton(
                          child: const Text("Xoá"),
                          onPressed: () {
                            _onDeleteItemButtonPressed(context);
                          },
                        ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }

  Widget _itemOptions() {
    MenuItem item = _item!;
    return CustomTable(
      columnWidths: const {
        0: FixedColumnWidth(200),
        1: FixedColumnWidth(100),
        2: FixedColumnWidth(200),
        3: FixedColumnWidth(300),
      },
      children: [
        const TableRow(
          children: [
            TableHeaderText("Tuỳ Chọn"),
            TableHeaderText("Còn Hàng"),
            TableHeaderText("Điều Kiện"),
            TableHeaderText("Lựa Chọn"),
          ],
        ),
        ...item.options.keys
            .map((optName) => _itemOptionRow(item.id, optName, item.options[optName]!))
            .toList(),
      ],
    );
  }

  TableRow _itemOptionRow(int itemId, String optName, MenuItemOption opt) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Text(optName),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Switch(
            value: opt.available,
            onChanged: (val) async {
              await setItemOptionAvailable(itemId, optName, val);
              _loadItem();
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Text('Chọn\n+ Ít nhất: ${opt.minChoice}\n+ Nhiều nhất: ${opt.maxChoice}'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Table(
            children: [
              ...opt.choices.keys
                  .map((choiceName) =>
                      _choiceRow(itemId, optName, choiceName, opt.choices[choiceName]!))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _choiceRow(int itemId, String optName, String choiceName, MenuItemOptionChoice choice) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(choiceName),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text('${choice.price}'),
        ),
        Switch(
          value: choice.available,
          onChanged: (val) async {
            await setItemOptionChoiceAvailable(itemId, optName, choiceName, val);
            _loadItem();
          },
        ),
      ],
    );
  }

  _openEditPage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MenuItemEditScreen(_item!.id)),
    );
    _loadItem();
  }

  void _onDeleteItemButtonPressed(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Xoá ${_item!.name}?"),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Huỷ'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Xoá'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    var resp = await deleteMenuItem(widget.itemId);
    if (resp.error != null) {
      // ignore: avoid_print
      print(resp.error);
      return;
    }

    Navigator.of(context).pop();
  }
}
