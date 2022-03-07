import '../utils/utils.dart';
import './models.dart';

Future<GetUserByUsernameResponse> getUserByUsername(String username) async {
  var apiRawResp = await get("/users/" + username);
  var resp = GetUserByUsernameResponse.fromJson(apiRawResp);
  return resp;
}

class GetUserByUsernameResponse {
  User? data;
  ApiError? error;

  GetUserByUsernameResponse.fromJson(ApiResponse apiResp)
      : data = apiResp.dataJson == null ? null : User.fromJson(apiResp.dataJson),
        error = apiResp.error;
}
