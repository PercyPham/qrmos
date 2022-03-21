import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';
import 'package:qrmos/widgets/tray_item.dart';
import 'package:qrmos/services/local/get_dest_info.dart';

import 'widgets/edit_name_dialog.dart';
import 'widgets/edit_phone_dialog.dart';

class CusTrayScreen extends StatefulWidget {
  final List<TrayItem> trayItems;

  const CusTrayScreen({
    Key? key,
    required this.trayItems,
  }) : super(key: key);

  @override
  State<CusTrayScreen> createState() => _CusTrayScreenState();
}

class _CusTrayScreenState extends State<CusTrayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Khay'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cusInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  _cusInfoSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Consumer<AuthModel>(
          builder: (ctx, auth, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gửi tới:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),
              _infoText('Tên: ', auth.userFullName, () => _editNamePressed(context)),
              _infoText('Sđt: ', auth.customerPhone, () => _editPhonePressed(context)),
              const SizedBox(height: 10),
              _infoText('Tại: ', _getDestNameFromLocal(), null),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  _infoText(String label, val, void Function()? onEditTap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label),
        Text(val),
        if (onEditTap != null) const SizedBox(width: 5),
        if (onEditTap != null) IconButton(icon: const Icon(Icons.edit), onPressed: onEditTap),
      ],
    );
  }

  _editNamePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EditCusNameDialog(),
    );
  }

  _editPhonePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EditCusPhoneDialog(),
    );
  }

  String _getDestNameFromLocal() {
    final destName = getDestInfo();
    return destName?.name ?? 'Vui lòng quét mã QR tại quán';
  }
}
