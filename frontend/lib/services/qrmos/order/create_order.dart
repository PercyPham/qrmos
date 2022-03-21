import '../utils/utils.dart';
import 'models.dart';

Future<CreateOrderResponse> createOrder(CreateOrderPayload payload) async {
  var apiRawResp = await post("/orders", body: payload.toJson());
  return CreateOrderResponse.fromJson(apiRawResp);
}

class CreateOrderResponse {
  Order? data;
  ApiError? error;

  CreateOrderResponse.fromJson(ApiResponse apiResp)
      : error = apiResp.error,
        data = apiResp.dataJson == null ? null : Order.fromJson(apiResp.dataJson);
}

class CreateOrderPayload {
  String customerName;
  String customerPhone;
  String deliveryDest;
  String deliveryDestSecurityCode;
  String voucher;
  List<CreateOrderItem> items;

  CreateOrderPayload({
    this.customerName = "",
    this.customerPhone = "",
    required this.deliveryDest,
    required this.deliveryDestSecurityCode,
    this.voucher = "",
    this.items = const [],
  });

  Map toJson() => {
        'customerName': customerName,
        'customerPhone': customerPhone,
        'deliveryDest': deliveryDest,
        'deliveryDestSecurityCode': deliveryDestSecurityCode,
        'voucher': voucher,
        'items': items,
      };
}

class CreateOrderItem {
  int itemId;
  int quantity;
  String note;
  Map<String, List<String>> options;

  CreateOrderItem({
    this.itemId = 0,
    this.quantity = 1,
    this.note = "",
    this.options = const {},
  });

  Map toJson() => {
        'itemId': itemId,
        'quantity': quantity,
        'note': note,
        'options': options,
      };

  bool hasOptionChoice(String optName, choiceName) {
    if (options[optName] == null) return false;
    return options[optName]!.contains(choiceName);
  }

  void addOptionChoice(String optName, choiceName) {
    if (options[optName] == null) options[optName] = [];
    if (!options[optName]!.contains(choiceName)) options[optName]!.add(choiceName);
  }

  void removeOptionChoice(String optName, choiceName) {
    if (options[optName] == null) return;
    options[optName] = options[optName]!.where((cName) => cName != choiceName).toList();
  }

  void toggleOptionChoice(String optName, choiceName) {
    if (options[optName] == null) return;
    if (options[optName]!.contains(choiceName)) {
      removeOptionChoice(optName, choiceName);
    } else {
      addOptionChoice(optName, choiceName);
    }
  }

  CreateOrderItem clone() {
    Map<String, List<String>> _opts = {};
    for (var optName in options.keys) {
      _opts[optName] = [];
      for (var choice in options[optName]!) {
        _opts[optName]!.add(choice);
      }
    }
    return CreateOrderItem(
      itemId: itemId,
      quantity: quantity,
      note: note,
      options: _opts,
    );
  }
}
