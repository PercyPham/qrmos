import '../utils/utils.dart';

Future<LoginResponse> login(String username, String password) async {
  var apiRawResp = await post("/login", body: {
    "username": username,
    "password": password,
  });

  var loginResponse = LoginResponse.fromApiResponse(apiRawResp);
  if (loginResponse.data != null) {
    await saveAccessToken(loginResponse.data!.accessToken);
  }

  return loginResponse;
}

class LoginResponse {
  AccessToken? data;
  ApiError? error;
  LoginResponse.fromApiResponse(ApiResponse apiResp)
      : data = AccessToken.fromJson(apiResp.dataJson),
        error = apiResp.error;
}

class AccessToken {
  final String accessToken;
  AccessToken(this.accessToken);
  static AccessToken? fromJson(Map<String, dynamic>? dataJson) {
    if (dataJson == null) {
      return null;
    }
    return AccessToken(dataJson['accessToken']);
  }
}
