class OrderItem {
  final String cropId;
  final String cropName;
  final String image;
  final String farmerName;
  final int quantity;
  final String unit;
  final double pricePerUnit;
  final double subtotal;

  OrderItem({
    required this.cropId,
    required this.cropName,
    required this.image,
    required this.farmerName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final crop = json['crop'] is Map
        ? Map<String, dynamic>.from(json['crop'])
        : <String, dynamic>{};

    final farmer = json['farmer'] is Map
        ? Map<String, dynamic>.from(json['farmer'])
        : <String, dynamic>{};

    return OrderItem(
      cropId: crop['_id'] ?? json['crop'] ?? '',
      cropName: json['cropName'] ?? crop['name'] ?? '',
      image: json['image'] ?? '',
      farmerName: farmer['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toInt(),
      unit: json['unit'] ?? '',
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String notes;
  final String trackingNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.notes,
    required this.trackingNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final shipping = json['shippingAddress'] is Map
        ? Map<String, dynamic>.from(json['shippingAddress'])
        : <String, dynamic>{};

    return OrderModel(
      id: json['_id'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      notes: json['notes'] ?? '',
      trackingNumber: json['trackingNumber'] ?? '',
      address: shipping['address'] ?? '',
      city: shipping['city'] ?? '',
      state: shipping['state'] ?? '',
      pincode: shipping['pincode'] ?? '',
      items: (json['items'] as List? ?? [])
          .map(
            (item) => OrderItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}