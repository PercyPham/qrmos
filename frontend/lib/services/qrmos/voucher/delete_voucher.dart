import '../utils/utils.dart';

Future<ApiBoolResponse> deleteVoucher(String voucherCode) async {
  var apiRawResp = await delete('/vouchers/$voucherCode');
  var resp = ApiBoolResponse.fromJson(apiRawResp);
  return resp;
}
