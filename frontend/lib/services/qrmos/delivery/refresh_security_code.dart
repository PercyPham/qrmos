import '../utils/utils.dart';

Future<RefreshDestSecurityCodeResponse> refreshDestSecurityCode(String destName) async {
  var apiRawResp = await put('/delivery-destinations/$destName/security-code/refresh');
  var resp = RefreshDestSecurityCodeResponse.fromJson(apiRawResp);
  return resp;
}

class RefreshDestSecurityCodeResponse {
  bool? data;
  ApiError? error;

  RefreshDestSecurityCodeResponse.fromJson(ApiResponse apiResp)
      : data = apiResp.dataJson == true ? true : false,
        error = apiResp.error;
}
