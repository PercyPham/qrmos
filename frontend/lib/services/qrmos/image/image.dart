import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../utils/utils.dart';

Future<UploadImageResponse> uploadImage(PlatformFile image) async {
  var req = http.MultipartRequest('POST', Uri.parse('$baseUrl/images'));
  var accessToken = await getAccessToken();
  req.headers['Authorization'] = "Bearer $accessToken";
  req.files.add(http.MultipartFile.fromBytes('image', image.bytes!, filename: image.name));

  var streamedResp = await req.send();
  final respStr = await streamedResp.stream.bytesToString();
  var jsonData = jsonDecode(respStr);
  if (streamedResp.statusCode != 200) {
    return UploadImageResponse(error: ApiError.fromJson(jsonData['error']));
  }

  return UploadImageResponse(
    data: jsonData['data'] == null ? null : baseUrl + jsonData['data']['imageRelativePath'],
    error: jsonData['error'] == null ? null : ApiError.fromJson(jsonData['error']),
  );
}

class UploadImageResponse {
  String? data;
  ApiError? error;

  UploadImageResponse({this.data, this.error});
}

Future<ApiBoolResponse> deleteImageLink(String imageLink) async {
  var imageName = _extractImageName(imageLink);
  return deleteImage(imageName);
}

String _extractImageName(String imageLink) {
  var baseLinkLength = '$baseUrl/images/'.length;
  if (imageLink.length <= baseLinkLength) {
    return "invalid-image-name";
  }
  return imageLink.substring(baseLinkLength);
}

Future<ApiBoolResponse> deleteImage(String imageName) async {
  var accessToken = await getAccessToken();
  var response = await http.delete(
    Uri.parse('$baseUrl/images/$imageName'),
    headers: {
      "Authorization": "Bearer $accessToken",
    },
  );
  return ApiBoolResponse.fromJson(ApiResponse.fromHttpResponse(response));
}
