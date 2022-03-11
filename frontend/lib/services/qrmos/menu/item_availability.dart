import '../utils/utils.dart';

Future<ApiBoolResponse> setItemAvailable(int itemId, bool available) async {
  var apiRawResp = await put('/menu/items/$itemId/available?val=$available');
  return ApiBoolResponse.fromJson(apiRawResp);
}

Future<ApiBoolResponse> setItemOptionAvailable(int itemId, String optName, bool available) async {
  var apiRawResp = await put('/menu/items/$itemId/options/$optName/available?val=$available');
  return ApiBoolResponse.fromJson(apiRawResp);
}

Future<ApiBoolResponse> setItemOptionChoiceAvailable(
    int itemId, String optName, String choiceName, bool available) async {
  var apiRawResp = await put(
      '/menu/items/$itemId/options/$optName/choices/$choiceName/available?val=$available');
  return ApiBoolResponse.fromJson(apiRawResp);
}
