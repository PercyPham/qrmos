import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import "dart:convert";
import 'dart:collection';
import 'access_token.dart';

final String _apiBaseUrl = kDebugMode
    ? 'http://localhost:5000/api'
    : '${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}/api';

Future<ApiResponse> get(
  String url, {
  Map<String, String>? headers,
  Object? body,
}) async {
  var fullUrl = Uri.parse(_apiBaseUrl + url);
  var response = await http.get(
    fullUrl,
    headers: await _prepHeaders(headers),
  );

  if (response.statusCode != 200) {
    return ApiResponse(null, ApiError(500, 'something wrong happened'));
  }

  var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
  return ApiResponse.fromJson(decodedResponse);
}

Future<ApiResponse> post(
  String url, {
  Map<String, String>? headers,
  Object? body,
}) async {
  var fullUrl = Uri.parse(_apiBaseUrl + url);
  var response = await http.post(
    fullUrl,
    headers: await _prepHeaders(headers),
    body: json.encode(body),
  );

  if (response.statusCode != 200) {
    return ApiResponse(null, ApiError(500, 'something wrong happened'));
  }

  var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
  return ApiResponse.fromJson(decodedResponse);
}

Future<Map<String, String>> _prepHeaders(Map<String, String>? headers) async {
  headers ??= HashMap<String, String>();
  headers.putIfAbsent("Content-Type", () => "application/json");
  var accessToken = await getAccessToken();
  if (accessToken != null) {
    headers.putIfAbsent("Authorization", () => accessToken);
  }
  return headers;
}

class ApiResponse {
  dynamic dataJson;
  ApiError? error;

  ApiResponse(this.dataJson, this.error);
  ApiResponse.fromJson(Map<String, dynamic> json)
      : dataJson = json['data'],
        error = json['error'] != null ? ApiError.fromJson(json['error']) : null;
}

class ApiError {
  final int code;
  final String message;

  ApiError(this.code, this.message);
  ApiError.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        message = json['message'];
}
