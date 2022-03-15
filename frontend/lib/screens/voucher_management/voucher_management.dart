import 'package:flutter/material.dart';
import 'package:qrmos/widgets/big_screen.dart';
import 'package:qrmos/widgets/screen_name.dart';
import 'package:qrmos/widgets/table/table.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' show Voucher, getVouchers, deleteVoucher;

import 'widgets/create_voucher_dialog.dart';

class VoucherManagementScreen extends StatefulWidget {
  const VoucherManagementScreen({Key? key}) : super(key: key);

  @override
  State<VoucherManagementScreen> createState() => _VoucherManagementScreenState();
}

class _VoucherManagementScreenState extends State<VoucherManagementScreen> {
  bool _isLoading = true;
  List<Voucher> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _isLoading = true;
      _vouchers = [];
    });
    var resp = await getVouchers();
    setState(() {
      _isLoading = false;
      if (resp.error == null) {
        _vouchers = resp.data!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BigScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenNameText("Quản lý voucher"),
          Container(height: 20),
          CustomTable(
            columnWidths: const {
              0: FixedColumnWidth(100.0),
              1: FixedColumnWidth(100.0),
              2: FixedColumnWidth(100.0),
              3: FixedColumnWidth(150.0),
              4: FixedColumnWidth(100.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.lightBlue[100],
                ),
                children: const [
                  TableHeaderText("Code"),
                  TableHeaderText("Giá trị"),
                  TableHeaderText("Đã sử dụng"),
                  TableHeaderText("Người tạo"),
                  TableHeaderText("Xoá"),
                ],
              ),
              ..._vouchers.map((voucher) => _voucherRow(voucher, context)).toList(),
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

  TableRow _voucherRow(Voucher voucher, BuildContext context) {
    onDeleteTap() async {
      bool? result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Xoá ${voucher.code}?"),
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

      var resp = await deleteVoucher(voucher.code);
      if (resp.error != null) {
        // ignore: avoid_print
        print(resp.error);
        return;
      }

      await _loadVouchers();
    }

    return TableRow(
      children: [
        _voucherRowText(voucher.code),
        _voucherRowText('${voucher.discount}'),
        _voucherRowText(voucher.isUsed ? "Rồi" : "Chưa"),
        _voucherRowText(voucher.createdBy),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: ElevatedButton(
            child: const Text("Xoá"),
            onPressed: voucher.isUsed ? null : onDeleteTap,
          ),
        ),
      ],
    );
  }

  Widget _voucherRowText(String text) {
    return TableRowInkWell(
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
      builder: (_) => const CreateVoucherDialog(),
    );
    if (result == true) await _loadVouchers();
  }
}
