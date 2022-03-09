import '../utils/utils.dart';

Future<DeleteDestResponse> deleteDest(String destName) async {
  var apiRawResp = await delete('/delivery-destinations/$destName');
  var resp = DeleteDestResponse.fromJson(apiRawResp);
  return resp;
}

class DeleteDestResponse {
  bool? data;
  ApiError? error;

  DeleteDestResponse.fromJson(ApiResponse apiResp)
      : error = apiResp.error,
        data = apiResp.dataJson == true ? true : false;
}
