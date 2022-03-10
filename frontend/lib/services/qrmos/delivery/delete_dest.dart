import '../utils/utils.dart';

Future<ApiBoolResponse> deleteDest(String destName) async {
  var apiRawResp = await delete('/delivery-destinations/$destName');
  return ApiBoolResponse.fromJson(apiRawResp);
}
