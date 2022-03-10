import '../utils/utils.dart';
import './models.dart';

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
      for (var i = 0; i < dataList.length; i++) {
        data ??= [];
        data!.add(Voucher.fromJson(dataList[i]));
      }
    }
  }
}
