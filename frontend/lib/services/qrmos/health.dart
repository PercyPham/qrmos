import 'utils/utils.dart';

Future<HealthCheckResponse> checkHealth() async {
  var apiResp = await get("/health");
  return HealthCheckResponse.fromApiResponse(apiResp);
}

class HealthCheckResponse {
  String? data;
  ApiError? error;
  HealthCheckResponse.fromApiResponse(ApiResponse apiResp)
      : data = apiResp.dataJson,
        error = apiResp.error;
}
