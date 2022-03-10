import '../utils/utils.dart';

Future<ApiBoolResponse> createMenuCat(String catName, String catDescription) async {
  var apiRawResp = await post('/menu/categories', body: {
    "name": catName,
    "description": catDescription,
  });
  return ApiBoolResponse.fromJson(apiRawResp);
}

Future<ApiBoolResponse> deleteMenuCat(int catId) async {
  var apiRawResp = await delete('/menu/categories/$catId');
  return ApiBoolResponse.fromJson(apiRawResp);
}
