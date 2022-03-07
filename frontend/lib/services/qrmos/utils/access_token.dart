import 'package:shared_preferences/shared_preferences.dart';

const _accessTokenKey = 'qrmos_token';

Future<bool> saveAccessToken(String accessToken) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.setString(_accessTokenKey, accessToken);
}

Future<String> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  var accessToken = prefs.getString(_accessTokenKey);
  if (accessToken == null || accessToken.isEmpty) {
    return "";
  }
  return accessToken;
}

Future<bool> removeAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.remove(_accessTokenKey);
}
