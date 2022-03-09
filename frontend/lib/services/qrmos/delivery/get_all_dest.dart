import '../utils/utils.dart';
import './models.dart';

Future<GetAllDestsResponse> getAllDests() async {
  var apiRawResp = await get("/delivery-destinations");
  var resp = GetAllDestsResponse.fromJson(apiRawResp);
  return resp;
}

class GetAllDestsResponse {
  List<DeliveryDestination>? data;
  ApiError? error;

  GetAllDestsResponse.fromJson(ApiResponse apiResp) {
    error = apiResp.error;
    if (apiResp.dataJson != null) {
      var dataList = apiResp.dataJson as List<dynamic>;
      for (var i = 0; i < dataList.length; i++) {
        data ??= [];
        data!.add(DeliveryDestination.fromJson(dataList[i]));
      }
    }
  }
}
