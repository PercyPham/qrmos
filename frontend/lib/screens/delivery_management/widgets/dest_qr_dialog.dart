import 'dart:ui';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:qrmos/services/qrmos/qrmos.dart' show refreshDestSecurityCode, getDestByName;

final String _webBaseUrl = kDebugMode
    ? '${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}'
    : '${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}/web';

class DestQrDialog extends StatefulWidget {
  final String name;
  final String securityCode;

  const DestQrDialog({
    Key? key,
    required this.name,
    required this.securityCode,
  }) : super(key: key);

  @override
  State<DestQrDialog> createState() => _DestQrDialogState();
}

class _DestQrDialogState extends State<DestQrDialog> {
  String _name = "";
  String _securityCode = "";

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _securityCode = widget.securityCode;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 10.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Tên điểm giao nhận: ",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text('Mã bảo vệ: $_securityCode'),
            const SizedBox(height: 20, width: 1),
            QrImage(
              data: _getQrCodeData(),
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20, width: 1),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: const Text("Tải về"),
                  onPressed: _onDownloadButtonPressed,
                ),
                Container(width: 10),
                ElevatedButton(
                  child: const Text("Làm mới mã bảo vệ"),
                  onPressed: _onRefreshButtonPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onDownloadButtonPressed() async {
    final qrValidationResult = QrValidator.validate(
      data: _getQrCodeData(),
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    final painter = QrPainter.withQr(
      qr: qrValidationResult.qrCode!,
      color: const Color(0xFF000000),
      gapless: true,
      embeddedImageStyle: null,
      embeddedImage: null,
    );

    final picData = await painter.toImageData(2048, format: ImageByteFormat.png);
    await FileSaver.instance.saveFile(
      _name,
      picData!.buffer.asUint8List(picData.offsetInBytes, picData.lengthInBytes),
      'png',
      mimeType: MimeType.PNG,
    );

    return;
  }

  String _getQrCodeData() {
    return '$_webBaseUrl/init-qr.html?dest=$_name&securityCode=$_securityCode';
  }

  void _onRefreshButtonPressed() async {
    var resp = await refreshDestSecurityCode(_name);
    if (resp.error != null) {
      // ignore: avoid_print
      print(resp.error);
      return;
    }

    var resp2 = await getDestByName(_name);
    if (resp2.error != null) {
      // ignore: avoid_print
      print(resp2.error);
      return;
    }

    setState(() {
      _securityCode = resp2.data!.securityCode!;
    });
  }
}
