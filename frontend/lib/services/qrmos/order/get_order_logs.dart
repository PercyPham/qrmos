import '../utils/utils.dart';
import 'models.dart';

Future<GetOrderLogsResponse> getOrderLogs(int orderId) async {
  var apiRawResp = await get('/orders/$orderId/logs');
  return GetOrderLogsResponse.fromJson(apiRawResp);
}

class GetOrderLogsResponse {
  List<OrderLog>? data;
  ApiError? error;
  GetOrderLogsResponse.fromJson(ApiResponse apiResp)
      : error = apiResp.error,
        data = apiResp.dataJson == null
            ? null
            : (apiResp.dataJson as List).map((data) => OrderLog.fromJson(data)).toList();
}
