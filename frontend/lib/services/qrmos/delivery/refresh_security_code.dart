import '../utils/utils.dart';

Future<ApiBoolResponse> refreshDestSecurityCode(String destName) async {
  var apiRawResp = await put('/delivery-destinations/$destName/security-code/refresh');
  var resp = ApiBoolResponse.fromJson(apiRawResp);
  return resp;
}
