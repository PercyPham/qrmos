import 'package:flutter/foundation.dart';

String apiBaseUrl = kDebugMode
    ? 'http://localhost:5000/api'
    : '${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}/api';

class ApiResponse<T> {
  T? data;
  ApiError? error;

  ApiResponse({this.data, this.error});
}

class ApiError {
  final int code;
  final String message;

  ApiError({required this.code, required this.message});
}
