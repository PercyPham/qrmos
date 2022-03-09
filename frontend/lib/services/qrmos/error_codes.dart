import './utils/utils.dart';

String getErrorMessageFrom(ApiError? err) {
  if (err == null) {
    return "";
  }
  if (errorCodes[err.code] != null) {
    return errorCodes[err.code]!;
  }
  return "Lỗi chưa được định danh: " + err.message;
}

const errorCodes = {
  // Login
  2000: "Tên đăng nhập hoặc mật khẩu không hợp lệ.",
  2001: "Tài khoản đã bị vô hiệu hóa, vui lòng liên hệ quản trị viên để được hỗ trợ.",

  // Create user
  3000: "Tên đăng nhập đã tồn tại",
};
