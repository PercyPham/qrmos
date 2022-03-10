import '../utils/utils.dart';
import './models.dart';

Future<GetAllUsersResponse> getAllUsers() async {
  var apiRawResp = await get("/users");
  return GetAllUsersResponse.fromJson(apiRawResp);
}

class GetAllUsersResponse {
  List<User>? data;
  ApiError? error;

  GetAllUsersResponse.fromJson(ApiResponse apiResp) {
    error = apiResp.error;
    if (apiResp.dataJson != null) {
      var dataList = apiResp.dataJson as List<dynamic>;
      data = [];
      for (var i = 0; i < dataList.length; i++) {
        data!.add(User.fromJson(dataList[i]));
      }
    }
  }
}
