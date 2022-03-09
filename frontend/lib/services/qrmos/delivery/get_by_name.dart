import '../utils/utils.dart';
import './models.dart';

Future<GetDestByNameResponse> getDestByName(String destName) async {
  var apiRawResp = await get('/delivery-destinations/$destName');
  var resp = GetDestByNameResponse.fromJson(apiRawResp);
  return resp;
}

class GetDestByNameResponse {
  DeliveryDestination? data;
  ApiError? error;

  GetDestByNameResponse.fromJson(ApiResponse apiResp)
      : error = apiResp.error,
        data = apiResp.dataJson == null ? null : DeliveryDestination.fromJson(apiResp.dataJson);
}
