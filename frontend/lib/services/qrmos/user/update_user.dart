import '../utils/utils.dart';
import './models.dart';

Future<UpdateUserResponse> updateUser(User user) async {
  var apiRawResp = await put("/users/" + user.username, body: {
    "username": user.username,
    "password": user.password,
    "fullName": user.fullName,
    "role": user.role,
    "active": user.active,
  });
  var resp = UpdateUserResponse.fromJson(apiRawResp);
  return resp;
}

class UpdateUserResponse {
  bool? data;
  ApiError? error;

  UpdateUserResponse.fromJson(ApiResponse apiResp)
      : data = apiResp.dataJson == true ? true : false,
        error = apiResp.error;
}
