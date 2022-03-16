class Order {
  int id;
  final String state;
  final String customerName;
  final String customerPhone;
  final String deliveryDestination;
  final String? voucher;
  final int? discount;
  final int total;
  final OrderCreator creator;
  final OrderPayment? payment;
  final String? failReason;
  final List<OrderItem>? orderItems;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.state,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryDestination,
    this.voucher,
    this.discount,
    required this.total,
    required this.creator,
    this.payment,
    this.failReason,
    this.orderItems,
    required this.createdAt,
  });

  Order.fromJson(Map<String, dynamic> dataJson)
      : id = dataJson['id'],
        state = dataJson['state'],
        customerName = dataJson['customerName'],
        customerPhone = dataJson['customerPhone'],
        deliveryDestination = dataJson['deliveryDestination'],
        voucher = dataJson['voucher'],
        discount = dataJson['discount'],
        total = dataJson['total'],
        creator = OrderCreator.fromJson(dataJson['creator']),
        payment = dataJson['payment'] == null ? null : OrderPayment.fromJson(dataJson['payment']),
        failReason = dataJson['failReason'],
        orderItems =
            dataJson['orderItems'] == null ? null : _extractOrderItems(dataJson['orderItems']),
        createdAt = tryParseDateTime(dataJson['createdAt'])!;

  static List<OrderItem> _extractOrderItems(List<dynamic> datas) {
    List<OrderItem> orderItems = [];
    for (var data in datas) {
      orderItems.add(OrderItem.fromJson(data));
    }
    return orderItems;
  }
}

class OrderCreator {
  final String type;
  final String? customerId;
  final String? staffUsername;

  OrderCreator({required this.type, this.customerId, this.staffUsername});
  OrderCreator.fromJson(Map<String, dynamic> dataJson)
      : type = dataJson['type'],
        customerId = dataJson['customerId'],
        staffUsername = dataJson['staffUsername'];
}

class OrderPayment {
  final String type;
  final bool success;
  final DateTime? successAt;
  final bool refund;
  final DateTime? refundAt;
  final MoMoPayment? momoPayment;
  OrderPayment({
    required this.type,
    required this.success,
    this.successAt,
    this.refund = false,
    this.refundAt,
    this.momoPayment,
  });
  OrderPayment.fromJson(Map<String, dynamic> dataJson)
      : type = dataJson['type'],
        success = dataJson['success'],
        successAt = tryParseDateTime(dataJson['successAt']),
        refund = dataJson['refund'] == true,
        refundAt = tryParseDateTime(dataJson['refundAt']),
        momoPayment =
            dataJson['momoPayment'] == null ? null : MoMoPayment.fromJson(dataJson['momoPayment']);
}

class MoMoPayment {
  final String? requestId;
  final String? transId;
  final String? paymentLink;
  final DateTime? paymentLinkCreatedAt;

  MoMoPayment({
    this.requestId,
    this.transId,
    this.paymentLink,
    this.paymentLinkCreatedAt,
  });
  MoMoPayment.fromJson(Map<String, dynamic> dataJson)
      : requestId = dataJson['requestId'],
        transId = dataJson['transId'],
        paymentLink = dataJson['paymentLink'],
        paymentLinkCreatedAt = tryParseDateTime(dataJson['paymentLinkCreatedAt']);
}

class OrderItem {
  final String name;
  final int unitPrice;
  final int quantity;
  final String note;
  final Map<String, List<String>> options;

  OrderItem.fromJson(Map<String, dynamic> dataJson)
      : name = dataJson['name'],
        unitPrice = dataJson['unitPrice'],
        quantity = dataJson['quantity'],
        note = dataJson['note'],
        options = _extractOrderItemOptions(dataJson['options']);

  static Map<String, List<String>> _extractOrderItemOptions(Map<String, dynamic> data) {
    Map<String, List<String>> opts = {};
    for (var optName in data.keys) {
      opts[optName] = [];
      for (var choice in (data[optName] as List)) {
        opts[optName]!.add(choice as String);
      }
    }
    return opts;
  }
}

DateTime? tryParseDateTime(dynamic t) {
  return t == null ? null : DateTime.parse(t);
}

class OrderLog {
  final int orderId;
  final String action;
  final OrderLogActor actor;
  final DateTime createdAt;
  final String? extra;

  OrderLog.fromJson(Map<String, dynamic> dataJson)
      : orderId = dataJson['orderId'],
        action = dataJson['action'],
        extra = dataJson['extra'],
        actor = OrderLogActor.fromJson(dataJson['actor']),
        createdAt = DateTime.parse(dataJson['createdAt']);
}

class OrderLogActor {
  final String type;
  final String? customerId;
  final String? staffUsername;

  OrderLogActor.fromJson(Map<String, dynamic> dataJson)
      : type = dataJson['type'],
        customerId = dataJson['customerId'],
        staffUsername = dataJson['staffUsername'];
}
