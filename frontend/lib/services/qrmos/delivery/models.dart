class DeliveryDestination {
  final String name;
  final String? securityCode;

  DeliveryDestination({
    required this.name,
    this.securityCode,
  });

  DeliveryDestination.fromJson(Map<String, dynamic> data)
      : name = data["name"],
        securityCode = data["securityCode"] ?? "";
}
