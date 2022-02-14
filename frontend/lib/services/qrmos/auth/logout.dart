import '../utils/utils.dart';

Future<bool> logout() async {
  return removeAccessToken();
}
