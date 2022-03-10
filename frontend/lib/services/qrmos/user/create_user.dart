import '../utils/utils.dart';
import './models.dart';

Future<ApiBoolResponse> createUser(User user) async {
  var apiRawResp = await post("/users", body: {
    "username": user.username,
    "password": user.password,
    "fullName": user.fullName,
    "role": user.role,
  });
  var resp = ApiBoolResponse.fromJson(apiRawResp);
  return resp;
}
