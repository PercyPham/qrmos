import '../utils/utils.dart';
import './models.dart';

Future<GetVoucherByCodeResponse> getVoucherByCode(String voucherCode) async {
  var apiRawResp = await get("/vouchers/$voucherCode");
  return GetVoucherByCodeResponse.fromJson(apiRawResp);
}

class GetVoucherByCodeResponse {
  Voucher? data;
  ApiError? error;

  GetVoucherByCodeResponse.fromJson(ApiResponse apiResp)
      : error = apiResp.error,
        data = apiResp.dataJson == null ? null : Voucher.fromJson(apiResp.dataJson);
}

Future<GetVouchersResponse> getVouchers() async {
  var apiRawResp = await get("/vouchers");
  return GetVouchersResponse.fromJson(apiRawResp);
}

class GetVouchersResponse {
  List<Voucher>? data;
  ApiError? error;

  GetVouchersResponse.fromJson(ApiResponse apiResp) {
    error = apiResp.error;
    if (apiResp.dataJson != null) {
      var dataList = apiResp.dataJson as List<dynamic>;
      data = [];
      for (var i = 0; i < dataList.length; i++) {
        data!.add(Voucher.fromJson(dataList[i]));
      }
    }
  }
}
