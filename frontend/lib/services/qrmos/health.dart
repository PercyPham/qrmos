import 'package:http/http.dart' as http;
import "dart:convert";
import "utils.dart";

Future<ApiResponse<String>> checkHealth() async {
  var url = Uri.parse(apiBaseUrl + "/health");
  var response = await http.get(url);
  if (response.statusCode != 200) {
    throw Exception("internal server error");
  }

  var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
  var apiResponse = ApiResponse<String>(
    data: decodedResponse["data"],
    error: decodedResponse["error"] == null
        ? null
        : ApiError(
            code: decodedResponse["error"]["code"],
            message: decodedResponse["error"]["message"],
          ),
  );
  return apiResponse;
}
