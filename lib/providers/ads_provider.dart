import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class AdsProvider with ChangeNotifier {
  List<Product> _myAds = [];
  List<Product> _serverAds = [];
  bool _isLoading = false;
  bool _isServerOnline = false;

  List<Product> get myAds => _myAds;
  List<Product> get serverAds => _serverAds;
  List<Product> get allAds => [..._serverAds, ..._myAds];
  int get count => _myAds.length;
  bool get isLoading => _isLoading;
  bool get isServerOnline => _isServerOnline;

  // Load ads from server
  Future<void> loadAds() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isServerOnline = await ApiService.checkHealth();
      if (_isServerOnline) {
        _serverAds = await ApiService.fetchPets();
      }
    } catch (e) {
      print('Error loading ads: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add ad locally and to server
  Future<bool> addAd(Product product, {File? imageFile}) async {
    _myAds.insert(0, product);
    notifyListeners();

    // Try to sync with server
    if (_isServerOnline) {
      final serverProduct = await ApiService.createPet(product, imageFile: imageFile);
      if (serverProduct != null) {
        // Replace local with server version
        final index = _myAds.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _myAds[index] = serverProduct;
          notifyListeners();
        }
        return true;
      }
    }
    return false;
  }

  void removeAd(String productId) {
    _myAds.removeWhere((p) => p.id == productId);
    ApiService.deletePet(productId);
    notifyListeners();
  }

  void updateAd(Product product) {
    final index = _myAds.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _myAds[index] = product;
      notifyListeners();
    }
  }

  // Refresh from server
  Future<void> refresh() async {
    await loadAds();
  }
}
