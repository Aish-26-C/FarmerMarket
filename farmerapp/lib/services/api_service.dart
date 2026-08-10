import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/crop.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  // ============================================================
  // HEADERS
  // ============================================================

  static Map<String, String> headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers(null),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // REGISTER
  // ============================================================

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers(null),
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // GET PROFILE
  // ============================================================

  static Future<UserModel> getProfile(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: headers(token),
    );

    final data = _handleResponse(response);

    return UserModel.fromJson(
      Map<String, dynamic>.from(
        data['user'],
      ),
    );
  }

  // ============================================================
  // GET ALL CROPS
  // ============================================================

  static Future<List<CropModel>> getCrops({
    String? search,
    String? category,
    String? city,
    String? sort,
  }) async {
    final query = <String, String>{};

    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    if (category != null && category.isNotEmpty) {
      query['category'] = category;
    }

    if (city != null && city.isNotEmpty) {
      query['city'] = city;
    }

    if (sort != null && sort.isNotEmpty) {
      query['sort'] = sort;
    }

    final uri = Uri.parse(
      '$baseUrl/crops',
    ).replace(
      queryParameters:
          query.isEmpty ? null : query,
    );

    final response = await http.get(
      uri,
      headers: headers(null),
    );

    final data = _handleResponse(response);

    final crops = data['crops'];

    if (crops is! List) {
      return [];
    }

    return crops
        .map(
          (crop) => CropModel.fromJson(
            Map<String, dynamic>.from(crop),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET SINGLE CROP
  // ============================================================

  static Future<CropModel> getCrop(
    String cropId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/crops/$cropId'),
      headers: headers(null),
    );

    final data = _handleResponse(response);

    return CropModel.fromJson(
      Map<String, dynamic>.from(
        data['crop'],
      ),
    );
  }

  // ============================================================
  // ADD NEW CROP
  // POST /api/crops
  // ============================================================

  static Future<Map<String, dynamic>> addCrop({
    required String token,
    required String name,
    required String category,
    required String description,
    required double price,
    required double quantity,
    required String unit,
    required bool isOrganic,
    required String city,
    required String state,
    String? harvestDate,
    String? imagePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/crops'),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    request.fields['name'] = name.trim();

    request.fields['category'] = category;

    request.fields['description'] =
        description.trim();

    request.fields['price'] =
        price.toString();

    request.fields['quantity'] =
        quantity.toString();

    request.fields['unit'] = unit;

    request.fields['isOrganic'] =
        isOrganic.toString();

    request.fields['location'] = jsonEncode({
      'city': city,
      'state': state,
      'address': '',
      'latitude': null,
      'longitude': null,
    });

    if (harvestDate != null &&
        harvestDate.isNotEmpty) {
      request.fields['harvestDate'] =
          harvestDate;
    }

    if (imagePath != null &&
        imagePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          imagePath,
        ),
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    return _handleResponse(response);
  }

  // ============================================================
  // FARMER - GET MY CROPS
  // ============================================================

  static Future<List<CropModel>> getMyCrops(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/crops/farmer/my-crops',
      ),
      headers: headers(token),
    );

    final data = _handleResponse(response);

    final crops = data['crops'];

    if (crops is! List) {
      return [];
    }

    return crops
        .map(
          (crop) => CropModel.fromJson(
            Map<String, dynamic>.from(crop),
          ),
        )
        .toList();
  }

  // ============================================================
  // UPDATE CROP
  // ============================================================

  static Future<Map<String, dynamic>> updateCrop({
    required String token,
    required String cropId,
    String? name,
    String? category,
    String? description,
    double? price,
    double? quantity,
    String? unit,
    bool? isOrganic,
    String? city,
    String? state,
    String? harvestDate,
    String? imagePath,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/crops/$cropId'),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    if (name != null) {
      request.fields['name'] = name.trim();
    }

    if (category != null) {
      request.fields['category'] = category;
    }

    if (description != null) {
      request.fields['description'] =
          description.trim();
    }

    if (price != null) {
      request.fields['price'] =
          price.toString();
    }

    if (quantity != null) {
      request.fields['quantity'] =
          quantity.toString();
    }

    if (unit != null) {
      request.fields['unit'] = unit;
    }

    if (isOrganic != null) {
      request.fields['isOrganic'] =
          isOrganic.toString();
    }

    if (city != null || state != null) {
      request.fields['location'] = jsonEncode({
        'city': city ?? '',
        'state': state ?? '',
        'address': '',
        'latitude': null,
        'longitude': null,
      });
    }

    if (harvestDate != null &&
        harvestDate.isNotEmpty) {
      request.fields['harvestDate'] =
          harvestDate;
    }

    if (imagePath != null &&
        imagePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          imagePath,
        ),
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    return _handleResponse(response);
  }

  // ============================================================
  // DELETE CROP
  // ============================================================

  static Future<Map<String, dynamic>> deleteCrop({
    required String token,
    required String cropId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/crops/$cropId'),
      headers: headers(token),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // BUYER - GET MY ORDERS
  // ============================================================

  static Future<List<OrderModel>> getMyOrders(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my-orders'),
      headers: headers(token),
    );

    final data = _handleResponse(response);

    final orders = data['orders'];

    if (orders is! List) {
      return [];
    }

    return orders
        .map(
          (order) => OrderModel.fromJson(
            Map<String, dynamic>.from(order),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET SINGLE ORDER
  // ============================================================

  static Future<OrderModel> getOrder(
    String token,
    String orderId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: headers(token),
    );

    final data = _handleResponse(response);

    return OrderModel.fromJson(
      Map<String, dynamic>.from(
        data['order'],
      ),
    );
  }

  // ============================================================
  // PLACE ORDER
  // ============================================================

  static Future<OrderModel> placeOrder({
    required String token,
    required String cropId,
    required int quantity,
    required Map<String, dynamic>
        shippingAddress,
    String paymentMethod = 'cod',
    String notes = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: headers(token),
      body: jsonEncode({
        'items': [
          {
            'cropId': cropId,
            'quantity': quantity,
          },
        ],
        'shippingAddress':
            shippingAddress,
        'paymentMethod':
            paymentMethod,
        'notes': notes,
      }),
    );

    final data = _handleResponse(response);

    return OrderModel.fromJson(
      Map<String, dynamic>.from(
        data['order'],
      ),
    );
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  static Future<OrderModel> cancelOrder({
    required String token,
    required String orderId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/orders/$orderId/cancel',
      ),
      headers: headers(token),
    );

    final data = _handleResponse(response);

    return OrderModel.fromJson(
      Map<String, dynamic>.from(
        data['order'],
      ),
    );
  }

  // ============================================================
  // FARMER - GET ORDERS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getFarmerOrders(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/farmer'),
      headers: headers(token),
    );

    final data = _handleResponse(response);

    final orders = data['orders'];

    if (orders == null || orders is! List) {
      return [];
    }

    return orders
        .map<Map<String, dynamic>>(
          (order) =>
              Map<String, dynamic>.from(
            order,
          ),
        )
        .toList();
  }

  // ============================================================
  // FARMER - UPDATE ORDER STATUS
  // ============================================================

  static Future<OrderModel> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/orders/$orderId/status',
      ),
      headers: headers(token),
      body: jsonEncode({
        'status': status,
      }),
    );

    final data = _handleResponse(response);

    return OrderModel.fromJson(
      Map<String, dynamic>.from(
        data['order'],
      ),
    );
  }

  // ============================================================
  // RESPONSE HANDLER
  // ============================================================

  static Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (e) {
      throw Exception(
        'Invalid server response',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (data is Map) {
        return Map<String, dynamic>.from(
          data,
        );
      }

      throw Exception(
        'Invalid server response',
      );
    }

    if (data is Map &&
        data['message'] != null) {
      throw Exception(
        data['message'].toString(),
      );
    }

    throw Exception(
      'Something went wrong. '
      'Status code: ${response.statusCode}',
    );
  }
}