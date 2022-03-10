import '../utils/utils.dart';

Future<ApiBoolResponse> deleteDest(String destName) async {
  var apiRawResp = await delete('/delivery-destinations/$destName');
  var resp = ApiBoolResponse.fromJson(apiRawResp);
  return resp;
}
