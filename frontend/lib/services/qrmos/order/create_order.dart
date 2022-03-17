import '../utils/utils.dart';

Future<ApiBoolResponse> createOrder(CreateOrderPayload payload) async {
  var apiRawResp = await post("/orders", body: payload.toJson());
  return ApiBoolResponse.fromJson(apiRawResp);
}

class CreateOrderPayload {
  String customerName;
  String customerPhone;
  String deliveryDest;
  String deliveryDestSecurity;
  String voucher;
  List<CreateOrderItem> items;

  CreateOrderPayload({
    this.customerName = "",
    this.customerPhone = "",
    required this.deliveryDest,
    required this.deliveryDestSecurity,
    this.voucher = "",
    this.items = const [],
  });

  Map toJson() => {
        'customerName': customerName,
        'customerPhone': customerPhone,
        'deliveryDest': deliveryDest,
        'deliveryDestSecurity': deliveryDestSecurity,
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
