import '../utils/utils.dart';

Future<ApiBoolResponse> deleteVoucher(String voucherCode) async {
  var apiRawResp = await delete('/vouchers/$voucherCode');
  return ApiBoolResponse.fromJson(apiRawResp);
}
