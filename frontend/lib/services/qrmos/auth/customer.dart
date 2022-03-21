import '../utils/utils.dart';
import 'models.dart';

Future<AccessTokenApiResponse> createCustomer(String fullName, String phoneNumber) async {
  var apiRawResp = await post("/customers", body: {
    "fullName": fullName,
    "phoneNumber": phoneNumber,
  });
  var resp = AccessTokenApiResponse.fromApiResponse(apiRawResp);
  if (resp.data != null) {
    await saveAccessToken(resp.data!.accessToken);
  }
  return resp;
}

Future<AccessTokenApiResponse> updateCustomer(String fullName, String phoneNumber) async {
  var apiRawResp = await put("/customers/me", body: {
    "fullName": fullName,
    "phoneNumber": phoneNumber,
  });
  var resp = AccessTokenApiResponse.fromApiResponse(apiRawResp);
  if (resp.data != null) {
    await saveAccessToken(resp.data!.accessToken);
  }
  return resp;
}
