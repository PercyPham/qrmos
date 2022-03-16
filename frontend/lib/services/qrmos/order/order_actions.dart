import '../utils/utils.dart';

Future<ApiBoolResponse> cancelOrder(int orderId) async {
  var apiRawResp = await patch('/orders/$orderId/cancel');
  return ApiBoolResponse.fromJson(apiRawResp);
}

Future<ApiBoolResponse> readyOrder(int orderId) async {
  var apiRawResp = await patch('/orders/$orderId/ready');
  return ApiBoolResponse.fromJson(apiRawResp);
}

Future<ApiBoolResponse> deliverOrder(int orderId) async {
  var apiRawResp = await patch('/orders/$orderId/delivered');
  return ApiBoolResponse.fromJson(apiRawResp);
}

Future<ApiBoolResponse> failOrder(int orderId, String failReason) async {
  var apiRawResp = await patch('/orders/$orderId/failed', body: {"failReason": failReason});
  return ApiBoolResponse.fromJson(apiRawResp);
}
