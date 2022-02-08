import 'package:flutter/foundation.dart';

String apiBaseUrl = kDebugMode
    ? 'http://localhost:5000/api'
    : '${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}/api';
