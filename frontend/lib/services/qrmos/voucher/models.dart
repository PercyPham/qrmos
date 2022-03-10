class Voucher {
  final String code;
  final int discount;
  final bool isUsed;
  final String createdBy;

  Voucher({
    required this.code,
    required this.discount,
    required this.isUsed,
    required this.createdBy,
  });

  Voucher.fromJson(Map<String, dynamic> data)
      : code = data["code"],
        discount = data["discount"],
        isUsed = data["isUsed"],
        createdBy = data["createdBy"];
}
