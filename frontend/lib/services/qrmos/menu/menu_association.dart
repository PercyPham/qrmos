import '../utils/utils.dart';

Future<ApiBoolResponse> createMenuAssociation(int catId, int itemId) async {
  var apiRawResp = await post('/menu/categories/$catId/items/$itemId');
  return ApiBoolResponse.fromJson(apiRawResp);
}

Future<ApiBoolResponse> deleteMenuAssociation(int catId, int itemId) async {
  var apiRawResp = await delete('/menu/categories/$catId/items/$itemId');
  return ApiBoolResponse.fromJson(apiRawResp);
}
