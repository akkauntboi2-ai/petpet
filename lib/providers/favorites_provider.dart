import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => _favorites;
  int get count => _favorites.length;

  bool isFavorite(String productId) {
    return _favorites.any((p) => p.id == productId);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product.id)) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _favorites.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clear() {
    _favorites.clear();
    notifyListeners();
  }

  void clearAll() {
    _favorites.clear();
    notifyListeners();
  }
}
