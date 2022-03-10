import '../utils/utils.dart';

Future<ApiBoolResponse> createVoucher(String voucherCode, int voucherDiscount) async {
  var apiRawResp = await post('/vouchers', body: {
    'code': voucherCode,
    'discount': voucherDiscount,
  });
  return ApiBoolResponse.fromJson(apiRawResp);
}
