import '../utils/utils.dart';

Future<ApiBoolResponse> createDest(String destName) async {
  var apiRawResp = await post('/delivery-destinations', body: {'name': destName});
  return ApiBoolResponse.fromJson(apiRawResp);
}
