import '../utils/utils.dart';
import './models.dart';

Future<CreateUserResponse> createUser(User user) async {
  var apiRawResp = await post("/users", body: {
    "username": user.username,
    "password": user.password,
    "fullName": user.fullName,
    "role": user.role,
  });
  var resp = CreateUserResponse.fromJson(apiRawResp);
  return resp;
}

class CreateUserResponse {
  bool? data;
  ApiError? error;

  CreateUserResponse.fromJson(ApiResponse apiResp)
      : data = apiResp.dataJson == true ? true : false,
        error = apiResp.error;
}
