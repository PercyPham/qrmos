import '../utils/utils.dart';

Future<ApiBoolResponse> createDest(String destName) async {
  var apiRawResp = await post('/delivery-destinations', body: {'name': destName});
  var resp = ApiBoolResponse.fromJson(apiRawResp);
  return resp;
}
