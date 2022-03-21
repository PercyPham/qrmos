// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:qrmos/services/qrmos/delivery/models.dart';

DeliveryDestination? getDestInfo() {
  final name = window.localStorage['destName'];
  final securityCode = window.localStorage['securityCode'];

  if (name == null || securityCode == null) {
    return null;
  }

  return DeliveryDestination(name: name, securityCode: securityCode);
}
