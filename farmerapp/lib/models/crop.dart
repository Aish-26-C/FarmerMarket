class CropModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final double quantity;
  final String unit;
  final List<String> images;
  final bool isOrganic;
  final bool isAvailable;
  final double rating;
  final int totalReviews;
  final int views;
  final String farmerId;
  final String farmerName;
  final String city;
  final String state;

  CropModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.images,
    required this.isOrganic,
    required this.isAvailable,
    required this.rating,
    required this.totalReviews,
    required this.views,
    required this.farmerId,
    required this.farmerName,
    required this.city,
    required this.state,
  });

  factory CropModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final farmer = json['farmer'] is Map
        ? Map<String, dynamic>.from(
            json['farmer'],
          )
        : <String, dynamic>{};

    final location = json['location'] is Map
        ? Map<String, dynamic>.from(
            json['location'],
          )
        : <String, dynamic>{};

    return CropModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      images: List<String>.from(
        json['images'] ?? [],
      ),
      isOrganic: json['isOrganic'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews:
          json['totalReviews'] ?? 0,
      views: json['views'] ?? 0,
      farmerId: farmer['_id'] ?? '',
      farmerName: farmer['name'] ?? '',
      city: location['city'] ?? '',
      state: location['state'] ?? '',
    );
  }
}