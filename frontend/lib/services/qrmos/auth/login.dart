import '../utils/utils.dart';
import 'models.dart';

Future<AccessTokenApiResponse> login(String username, String password) async {
  var apiRawResp = await post("/login", body: {
    "username": username,
    "password": password,
  });

  var loginResponse = AccessTokenApiResponse.fromApiResponse(apiRawResp);
  if (loginResponse.data != null) {
    await saveAccessToken(loginResponse.data!.accessToken);
  }

  return loginResponse;
}
