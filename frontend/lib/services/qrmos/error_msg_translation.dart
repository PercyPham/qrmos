import './utils/utils.dart';

String translateErrMsg(ApiError? err) {
  if (err == null) {
    return "";
  }
  if (_errMsgTrans[err.message] != null) {
    return _errMsgTrans[err.message]!;
  }
  return "Lỗi chưa được dịch: " + err.message;
}

final _errMsgTrans = {
  "invalid username or password": "Tên đăng nhập hoặc mật khẩu không hợp lệ",
  "user is not active":
      "Tài khoản đã bị vô hiệu hóa, vui lòng liên hệ quản trị viên để được hỗ trợ",
  "username already exists": "Tên đăng nhập đã tồn tại",
  "delivery destination already exists": "Điểm giao nhận đã tồn tại",
  "voucher already exists": "Mã code đã tồn tại",
  "not in same creation date": "Không cùng ngày khởi tạo",
};
