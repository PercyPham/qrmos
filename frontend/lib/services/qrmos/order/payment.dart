import '../utils/utils.dart';

Future<ApiBoolResponse> markOrderAsPaidByCash(int orderId) async {
  var apiRawResp = await patch('/orders/$orderId/payment/cash');
  return ApiBoolResponse.fromJson(apiRawResp);
}

Future<MoMoPaymentLinkResponse> createMoMoPaymentLink(int orderId) async {
  var apiRawResp = await post('/orders/$orderId/payment/momo/payment-link');
  return MoMoPaymentLinkResponse.fromJson(apiRawResp);
}

class MoMoPaymentLinkResponse {
  String? data;
  ApiError? error;

  MoMoPaymentLinkResponse.fromJson(ApiResponse apiResp)
      : data = apiResp.dataJson,
        error = apiResp.error;
}
