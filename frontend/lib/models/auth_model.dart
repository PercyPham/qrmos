import 'package:flutter/foundation.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' as qrmos;

enum UserType {
  staff,
  customer,
  unauthenticated,
}

enum StaffRole {
  admin,
  manager,
  normalStaff,
  unauthenticated,
}

class AccessTokenInfo {
  final UserType userType;
  final String userFullName;
  final String customerId;
  final String phoneNumber;
  final StaffRole staffRole;
  final String staffUsername;

  AccessTokenInfo({
    required this.userType,
    this.userFullName = "",
    this.customerId = "",
    this.phoneNumber = "",
    this.staffUsername = "",
    this.staffRole = StaffRole.unauthenticated,
  });
}

class AuthModel extends ChangeNotifier {
  UserType userType = UserType.unauthenticated;
  String userFullName = "";
  String customerId = "";
  String customerPhone = "";
  String staffUsername = "";
  StaffRole staffRole = StaffRole.unauthenticated;

  bool get isAuthenticated => userType == UserType.unauthenticated;
  String get staffRoleStr {
    switch (staffRole) {
      case StaffRole.admin:
        return "admin";
      case StaffRole.manager:
        return "manager";
      case StaffRole.normalStaff:
        return "normal staff";
      default:
        return "";
    }
  }

  Future<String> login(String username, String password) async {
    var loginResp = await qrmos.login(username, password);
    if (loginResp.error != null) {
      return qrmos.translateErrMsg(loginResp.error!);
    }
    return "";
  }

  Future<void> logout() async {
    await qrmos.logout();
    await loadAccessTokenFromLocal();
  }

  Future<void> loadAccessTokenFromLocal() async {
    var accessTokenInfo = await qrmos.loadAccessTokenFromLocal();
    userType = accessTokenInfo.userType;
    userFullName = accessTokenInfo.userFullName;
    customerId = accessTokenInfo.customerId;
    customerPhone = accessTokenInfo.phoneNumber;
    staffUsername = accessTokenInfo.staffUsername;
    staffRole = accessTokenInfo.staffRole;
    notifyListeners();
  }
}

class AuthCustomer {
  String customerId = "";
  String fullName = "";
  String phoneNumber = "";
}
