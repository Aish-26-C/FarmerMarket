import 'package:flutter/foundation.dart';

import '../models/crop.dart';

class CartItem {
  final CropModel crop;
  int quantity;

  CartItem({
    required this.crop,
    this.quantity = 1,
  });

  double get subtotal =>
      crop.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items =>
      _items.values.toList();

  int get itemCount {
    int count = 0;

    for (final item in _items.values) {
      count += item.quantity;
    }

    return count;
  }

  double get totalAmount {
    double total = 0;

    for (final item in _items.values) {
      total += item.subtotal;
    }

    return total;
  }

  bool contains(String cropId) {
    return _items.containsKey(cropId);
  }

  void addToCart(
    CropModel crop, {
    int quantity = 1,
  }) {
    if (_items.containsKey(crop.id)) {
      _items[crop.id]!.quantity += quantity;
    } else {
      _items[crop.id] = CartItem(
        crop: crop,
        quantity: quantity,
      );
    }

    notifyListeners();
  }

  void increaseQuantity(String cropId) {
    if (!_items.containsKey(cropId)) return;

    final item = _items[cropId]!;

    if (item.quantity < item.crop.quantity) {
      item.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String cropId) {
    if (!_items.containsKey(cropId)) return;

    final item = _items[cropId]!;

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(cropId);
    }

    notifyListeners();
  }

  void removeFromCart(String cropId) {
    _items.remove(cropId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}