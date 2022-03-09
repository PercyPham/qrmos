import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import "dart:convert";
import 'dart:collection';
import 'access_token.dart';

final String _apiBaseUrl = kDebugMode
    ? 'http://localhost:5000/api'
    : '${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}/api';

Future<ApiResponse> get(
  String apiRelativePath, {
  Map<String, String>? headers,
}) async {
  var response = await http.get(
    _prepFullUrl(apiRelativePath),
    headers: await _prepHeaders(headers),
  );
  return ApiResponse.fromHttpResponse(response);
}

Future<ApiResponse> post(
  String apiRelativePath, {
  Map<String, String>? headers,
  Object? body,
}) async {
  var response = await http.post(
    _prepFullUrl(apiRelativePath),
    headers: await _prepHeaders(headers),
    body: json.encode(body),
  );
  return ApiResponse.fromHttpResponse(response);
}

Future<ApiResponse> put(
  String apiRelativePath, {
  Map<String, String>? headers,
  Object? body,
}) async {
  var response = await http.put(
    _prepFullUrl(apiRelativePath),
    headers: await _prepHeaders(headers),
    body: json.encode(body),
  );
  return ApiResponse.fromHttpResponse(response);
}

Future<ApiResponse> delete(
  String apiRelativePath, {
  Map<String, String>? headers,
}) async {
  var response = await http.delete(
    _prepFullUrl(apiRelativePath),
    headers: await _prepHeaders(headers),
  );
  return ApiResponse.fromHttpResponse(response);
}

Uri _prepFullUrl(String url) {
  return Uri.parse(_apiBaseUrl + url);
}

Future<Map<String, String>> _prepHeaders(Map<String, String>? headers) async {
  headers ??= HashMap<String, String>();
  headers.putIfAbsent("Content-Type", () => "application/json");
  var accessToken = await getAccessToken();
  if (accessToken != "") {
    headers.putIfAbsent("Authorization", () => "Bearer " + accessToken);
  }
  return headers;
}

class ApiResponse {
  dynamic dataJson;
  ApiError? error;

  ApiResponse.fromHttpResponse(http.Response response) {
    if (response.statusCode != 200) {
      error = ApiError(500, 'something wrong happened');
      return;
    }
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
    dataJson = decodedResponse['data'];
    error = decodedResponse['error'] != null ? ApiError.fromJson(decodedResponse['error']) : null;
  }
}

class ApiError {
  final int code;
  final String message;

  ApiError(this.code, this.message);
  ApiError.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        message = json['message'];
}
