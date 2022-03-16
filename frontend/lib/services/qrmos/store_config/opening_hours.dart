import '../utils/utils.dart';
import 'models.dart';

Future<GetStoreCfgOpenHoursResponse> getStoreCfgOpeningHours() async {
  var apiRawResp = await get('/store-configs/opening-hours');
  return GetStoreCfgOpenHoursResponse.fromJson(apiRawResp);
}

class GetStoreCfgOpenHoursResponse {
  StoreConfigOpeningHours? data;
  ApiError? error;

  GetStoreCfgOpenHoursResponse.fromJson(ApiResponse apiResp)
      : error = apiResp.error,
        data = apiResp.dataJson == null ? null : StoreConfigOpeningHours.fromJson(apiResp.dataJson);
}

Future<ApiBoolResponse> updateStoreCfgOpeningHours(StoreConfigOpeningHours cfg) async {
  var apiRawResp = await put('/store-configs/opening-hours', body: cfg.toJson());
  return ApiBoolResponse.fromJson(apiRawResp);
}
