import '../utils/utils.dart';
import './models.dart';

Future<ApiBoolResponse> updateUser(User user) async {
  var apiRawResp = await put("/users/" + user.username, body: {
    "username": user.username,
    "password": user.password,
    "fullName": user.fullName,
    "role": user.role,
    "active": user.active,
  });
  return ApiBoolResponse.fromJson(apiRawResp);
}
