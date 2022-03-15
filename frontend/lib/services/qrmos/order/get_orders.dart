import '../utils/utils.dart';
import 'models.dart';

Future<GetOrdersResponse> getOrders({
  int page = 1,
  int itemPerPage = 20,
  String? state,
  String sortCreatedAt = "desc",
  int? from,
  int? to,
}) async {
  var queryStr = "page=$page&itemPerPage=$itemPerPage&sortCreatedAt=$sortCreatedAt";
  if (state != null) queryStr += "&state=$state";
  if (from != null) queryStr += "&from=$from";
  if (to != null) queryStr += "&to=$to";

  var apiRawResp = await get('/orders?$queryStr');
  return GetOrdersResponse.fromJson(apiRawResp);
}

class GetOrdersResponse {
  GetOrdersData? data;
  ApiError? error;

  GetOrdersResponse.fromJson(ApiResponse apiResp)
      : data = apiResp.dataJson == null ? null : GetOrdersData.fromJson(apiResp.dataJson),
        error = apiResp.error;
}

class GetOrdersData {
  final List<Order> orders;
  final int total;
  GetOrdersData.fromJson(Map<String, dynamic> dataJson)
      : total = dataJson["total"],
        orders = (dataJson["orders"] as List).map((e) => Order.fromJson(e)).toList();
}
