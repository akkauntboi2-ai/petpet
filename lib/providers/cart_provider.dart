import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get total => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;
  int get count => _items.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.fold(0, (sum, item) => sum + item.total);

  bool isInCart(String id) => _items.any((i) => i.product.id == id);

  void add(Product p) {
    final idx = _items.indexWhere((i) => i.product.id == p.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(product: p));
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((i) => i.product.id == id);
    notifyListeners();
  }

  void increment(String id) {
    final idx = _items.indexWhere((i) => i.product.id == id);
    if (idx >= 0) { _items[idx].quantity++; notifyListeners(); }
  }

  void decrement(String id) {
    final idx = _items.indexWhere((i) => i.product.id == id);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) { _items[idx].quantity--; }
      else { _items.removeAt(idx); }
      notifyListeners();
    }
  }

  void clear() { _items.clear(); notifyListeners(); }
}
