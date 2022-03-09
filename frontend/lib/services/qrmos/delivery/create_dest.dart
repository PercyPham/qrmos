import '../utils/utils.dart';

Future<CreateDestResponse> createDest(String destName) async {
  var apiRawResp = await post('/delivery-destinations', body: {'name': destName});
  var resp = CreateDestResponse.fromJson(apiRawResp);
  return resp;
}

class CreateDestResponse {
  bool? data;
  ApiError? error;

  CreateDestResponse.fromJson(ApiResponse apiResp)
      : error = apiResp.error,
        data = apiResp.dataJson == true ? true : false;
}
