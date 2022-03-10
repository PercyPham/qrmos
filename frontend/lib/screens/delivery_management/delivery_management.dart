import 'package:flutter/material.dart';
import 'package:qrmos/widgets/screen_name.dart';
import 'package:qrmos/widgets/table/table.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show DeliveryDestination, getAllDests, deleteDest;

import 'widgets/create_dest_dialog.dart';
import 'widgets/dest_qr_dialog.dart';

class DeliveryManagementScreen extends StatefulWidget {
  const DeliveryManagementScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryManagementScreen> createState() => _DeliveryManagementScreenState();
}

class _DeliveryManagementScreenState extends State<DeliveryManagementScreen> {
  bool _isLoading = true;
  List<DeliveryDestination> _dests = [];

  @override
  void initState() {
    super.initState();
    _loadDests();
  }

  Future<void> _loadDests() async {
    setState(() {
      _isLoading = true;
      _dests = [];
    });
    var resp = await getAllDests();
    setState(() {
      _isLoading = false;
      if (resp.error == null) {
        _dests = resp.data!;
        _dests.sort((u1, u2) => u1.name.compareTo(u2.name));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenNameText("Quản lý điểm giao nhận"),
          Container(height: 20),
          const Text("Ghi chú: click vào tên điểm giao nhận để xem QR code và làm mới mã bảo vệ."),
          Container(height: 10),
          CustomTable(
            columnWidths: const {
              0: FixedColumnWidth(100.0),
              1: FixedColumnWidth(200.0),
              2: FixedColumnWidth(100.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.lightBlue[100],
                ),
                children: const [
                  TableHeaderText("Tên"),
                  TableHeaderText("Mã bảo vệ"),
                  TableHeaderText("Xoá"),
                ],
              ),
              ..._dests.map((dest) => _destRow(dest, context)).toList(),
            ],
          ),
          if (_isLoading) const Text("Loading..."),
          Container(height: 10),
          ElevatedButton(
              child: const Text("Tạo"),
              onPressed: () {
                _onCreateButtonPressed(context);
              }),
        ],
      ),
    );
  }

  TableRow _destRow(DeliveryDestination dest, BuildContext context) {
    onTap() async {
      await showDialog(
        context: context,
        builder: (_) => DestQrDialog(
          name: dest.name,
          securityCode: dest.securityCode!,
        ),
      );
      await _loadDests();
    }

    onDeleteTap() async {
      bool? result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Xoá ${dest.name}?"),
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

      var resp = await deleteDest(dest.name);
      if (resp.error != null) {
        // ignore: avoid_print
        print(resp.error);
        return;
      }

      await _loadDests();
    }

    return TableRow(
      children: [
        _destRowText(dest.name, onTap),
        _destRowText(dest.securityCode!, onTap),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: ElevatedButton(
              child: const Text("Xoá"),
              onPressed: () {
                onDeleteTap();
              }),
        ),
      ],
    );
  }

  Widget _destRowText(String text, void Function() onTap) {
    return TableRowInkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  _onCreateButtonPressed(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => const CreateDestDialog(),
    );
    if (result == true) await _loadDests();
  }
}
