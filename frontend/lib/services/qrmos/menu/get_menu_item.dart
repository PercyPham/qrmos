import '../utils/utils.dart';
import 'models.dart';

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
