import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/providers/auth_model.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/store_config/store_config.dart';
import 'package:qrmos/widgets/custom_button.dart';

import 'widgets/edit_store_cfg_open_dialog.dart';

class StoreConfigManagement extends StatefulWidget {
  final void Function(bool) onStoreOpeningChanged;
  const StoreConfigManagement({
    Key? key,
    required this.onStoreOpeningChanged,
  }) : super(key: key);

  @override
  State<StoreConfigManagement> createState() => _StoreConfigManagementState();
}

class _StoreConfigManagementState extends State<StoreConfigManagement> {
  bool _isLoading = false;
  StoreConfigOpeningHours? _openCfg;
  bool _isOpening = false;
  String _errMsg = "";

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadStoreConfig();
    _timer = _periodicReload();
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }

  _periodicReload() {
    const duration = Duration(seconds: 10);
    return Timer.periodic(duration, (Timer t) {
      _loadStoreConfig();
    });
  }

  void _loadStoreConfig() async {
    setState(() {
      _isLoading = true;
      _isOpening = false;
      _errMsg = "";
      _openCfg = null;
    });

    var resp = await getStoreCfgOpeningHours();
    if (resp.error != null) {
      setState(() {
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _openCfg = resp.data;
      _isOpening = _openCfg!.isOpenAt(DateTime.now());
      _errMsg = "";
    });
    widget.onStoreOpeningChanged(_isOpening);
  }

  @override
  Widget build(BuildContext context) {
    var isManager = Provider.of<AuthModel>(context).staffRole == StaffRole.manager;

    return Row(
      children: [
        _storeOpeningStatus(),
        if (isManager) const SizedBox(width: 10),
        if (isManager) CustomButton("Chỉnh", () => _onEditButtonPressed(context)),
      ],
    );
  }

  _storeOpeningStatus() {
    late Widget content;
    if (_errMsg != "") {
      content = Text(_errMsg, style: const TextStyle(color: Colors.red));
    } else if (_isLoading) {
      content = const Text("...đang kiểm tra");
    } else if (_isOpening) {
      content =
          const Text("Mở Cửa", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
    } else {
      content =
          const Text("Đóng Cửa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Cửa hàng đang: '),
        content,
      ],
    );
  }

  void _onEditButtonPressed(BuildContext context) async {
    var result = await showDialog<bool>(
      context: context,
      builder: (_) => EditStoreOpeningCfgDialog(_openCfg!),
    );
    if (result == true) {
      _loadStoreConfig();
    }
  }
}
