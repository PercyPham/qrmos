import 'dart:convert';
import 'package:qrmos/models/auth_model.dart';
import '../utils/utils.dart';

Future<AccessTokenInfo> loadAccessTokenFromLocal() async {
  var accessToken = await getAccessToken();
  if (accessToken == "") {
    return AccessTokenInfo(userType: UserType.unauthenticated);
  }
  return _extractAccessTokenInfo(accessToken);
}

AccessTokenInfo _extractAccessTokenInfo(String accessToken) {
  var parts = accessToken.split(".");
  if (parts.length != 3) {
    return AccessTokenInfo(userType: UserType.unauthenticated);
  }

  var infoPart = parts[1];
  infoPart = base64.normalize(infoPart);
  var base64DecodedInfoPart = utf8.decode(base64.decode(infoPart));
  var decodedJson = jsonDecode(base64DecodedInfoPart);

  var userType = decodedJson['type'];

  if (userType == 'customer') {
    return AccessTokenInfo(
      userType: UserType.customer,
      userFullName: decodedJson['fullName'],
      customerId: decodedJson['customerId'],
      phoneNumber: decodedJson['phoneNumber'],
    );
  }

  if (userType != 'staff') {
    return AccessTokenInfo(userType: UserType.unauthenticated);
  }

  var expireAt = decodedJson['exp'] as int;
  var now = DateTime.now().microsecondsSinceEpoch * 1000;
  if (expireAt < now) {
    return AccessTokenInfo(userType: UserType.unauthenticated);
  }

  var roles = {
    'admin': StaffRole.admin,
    'manager': StaffRole.manager,
    'normal-staff': StaffRole.normalStaff,
  };

  StaffRole? role = roles[decodedJson['role']];
  if (role == null) {
    return AccessTokenInfo(userType: UserType.unauthenticated);
  }

  return AccessTokenInfo(
    userType: UserType.staff,
    userFullName: decodedJson['fullName'],
    staffUsername: decodedJson['username'],
    staffRole: role,
  );
}
