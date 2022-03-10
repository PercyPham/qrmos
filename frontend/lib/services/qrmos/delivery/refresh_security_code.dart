import '../utils/utils.dart';

Future<ApiBoolResponse> refreshDestSecurityCode(String destName) async {
  var apiRawResp = await put('/delivery-destinations/$destName/security-code/refresh');
  return ApiBoolResponse.fromJson(apiRawResp);
}
