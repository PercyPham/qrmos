import '../utils/utils.dart';
import 'models.dart';

Future<MenuResponse> getMenu() async {
  var apiRawResp = await get("/menu");
  return MenuResponse.fromApiResponse(apiRawResp);
}

class MenuResponse {
  Menu? data;
  ApiError? error;

  MenuResponse.fromApiResponse(ApiResponse apiResp)
      : data = apiResp.dataJson != null ? Menu.fromJson(apiResp.dataJson) : null,
        error = apiResp.error;
}
