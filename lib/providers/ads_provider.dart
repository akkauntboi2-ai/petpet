import 'package:flutter/foundation.dart';
import '../models/product.dart';

class AdsProvider with ChangeNotifier {
  final List<Product> _myAds = [];

  List<Product> get myAds => _myAds;
  int get count => _myAds.length;

  void addAd(Product product) {
    _myAds.insert(0, product);
    notifyListeners();
  }

  void removeAd(String productId) {
    _myAds.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void updateAd(Product product) {
    final index = _myAds.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _myAds[index] = product;
      notifyListeners();
    }
  }
}
