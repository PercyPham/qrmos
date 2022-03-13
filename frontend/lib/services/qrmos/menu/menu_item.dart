import '../utils/utils.dart';
import 'models.dart';

Future<ApiBoolResponse> createMenuItem(MenuItem item) async {
  var apiRawResp = await post("/menu/items", body: item.toJson());
  return ApiBoolResponse.fromJson(apiRawResp);
}

Future<ApiBoolResponse> updateMenuItem(MenuItem item) async {
  var apiRawResp = await put("/menu/items/${item.id}", body: item.toJson());
  return ApiBoolResponse.fromJson(apiRawResp);
}

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

Future<MenuItemResponse> getMenuItem(int itemId) async {
  var apiRawResp = await get("/menu/items/$itemId");
  return MenuItemResponse.fromApiResponse(apiRawResp);
}

class MenuItemResponse {
  MenuItem? data;
  ApiError? error;

  MenuItemResponse.fromApiResponse(ApiResponse apiResp)
      : data = apiResp.dataJson != null ? MenuItem.fromJson(apiResp.dataJson) : null,
        error = apiResp.error;
}

Future<ApiBoolResponse> deleteMenuItem(int itemId) async {
  var apiRawResp = await delete('/menu/items/$itemId');
  return ApiBoolResponse.fromJson(apiRawResp);
}
