import '../utils/utils.dart';
import 'models.dart';

Future<ApiBoolResponse> createMenuItem(MenuItem item) async {
  var apiRawResp = await post("/menu/items", body: {
    "name": item.name,
    "description": item.description,
    "image": item.image,
    "available": item.available,
    "baseUnitPrice": item.baseUnitPrice,
    "options": item.options,
  });
  return ApiBoolResponse.fromJson(apiRawResp);
}
