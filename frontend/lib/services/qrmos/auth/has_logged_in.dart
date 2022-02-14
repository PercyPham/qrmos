import '../utils/utils.dart';

Future<bool> hasLoggedIn() async {
  return await getAccessToken() != null;
}
