import '../utils/utils.dart';

Future<ApiBoolResponse> setItemAvailable(int itemId, bool available) async {
  var apiRawResp = await put('/menu/items/$itemId/available?val=$available');
  return ApiBoolResponse.fromJson(apiRawResp);
}
