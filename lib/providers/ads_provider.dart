import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class AdsProvider with ChangeNotifier {
  List<Product> _myAds = [];
  List<Product> _serverAds = [];
  bool _isLoading = false;
  bool _isServerOnline = false;

  static const String _myAdsKey = 'petpet_my_ads';

  List<Product> get myAds => _myAds;
  List<Product> get serverAds => _serverAds;
  List<Product> get allAds => [..._serverAds, ..._myAds];
  int get count => _myAds.length;
  bool get isLoading => _isLoading;
  bool get isServerOnline => _isServerOnline;

  // Load saved ads from SharedPreferences
  Future<void> loadSavedAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString(_myAdsKey);
      if (adsJson != null) {
        final List<dynamic> adsList = json.decode(adsJson);
        _myAds = adsList.map((e) => Product.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved ads: $e');
    }
  }

  // Save ads to SharedPreferences
  Future<void> _saveAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = json.encode(_myAds.map((e) => e.toJson()).toList());
      await prefs.setString(_myAdsKey, adsJson);
    } catch (e) {
      print('Error saving ads: $e');
    }
  }

  // Load ads from server
  Future<void> loadAds() async {
    _isLoading = true;
    notifyListeners();

    // First load saved ads
    await loadSavedAds();

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

  // Add ad locally and sync to server in background
  void addAd(Product product, {File? imageFile}) {
    _myAds.insert(0, product);
    notifyListeners();
    _saveAds();

    // Sync with server in background
    _syncToServer(product, imageFile: imageFile);
  }

  Future<void> _syncToServer(Product product, {File? imageFile}) async {
    if (_isServerOnline) {
      final serverProduct = await ApiService.createPet(product, imageFile: imageFile);
      if (serverProduct != null) {
        final index = _myAds.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _myAds[index] = serverProduct;
          notifyListeners();
          _saveAds();
        }
      }
    }
  }

  void removeAd(String productId) {
    _myAds.removeWhere((p) => p.id == productId);
    ApiService.deletePet(productId);
    notifyListeners();
    _saveAds();
  }

  void updateAd(Product product) {
    final index = _myAds.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _myAds[index] = product;
      notifyListeners();
      _saveAds();
    }
  }

  // Refresh from server
  Future<void> refresh() async {
    await loadAds();
  }
}
