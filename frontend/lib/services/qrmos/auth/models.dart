import '../utils/api.dart';

class AccessTokenApiResponse {
  AccessToken? data;
  ApiError? error;

  AccessTokenApiResponse.fromApiResponse(ApiResponse apiResp)
      : data = apiResp.dataJson != null ? AccessToken.fromJson(apiResp.dataJson) : null,
        error = apiResp.error;
}

class AccessToken {
  final String accessToken;

  AccessToken.fromJson(Map<String, dynamic> dataJson) : accessToken = dataJson['accessToken'];
}
