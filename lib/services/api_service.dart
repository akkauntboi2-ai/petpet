import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://217.145.226.216:3000/api';

  // Get all pets from server
  static Future<List<Product>> fetchPets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pets'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _productFromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching pets: $e');
      return [];
    }
  }

  // Create new pet
  static Future<Product?> createPet(Product product, {File? imageFile}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/pets'));

      request.fields['name'] = product.name;
      request.fields['category'] = product.categoryName;
      request.fields['breed'] = product.breed ?? '';
      request.fields['age'] = product.age ?? '';
      request.fields['price'] = product.price.toString();
      request.fields['location'] = product.city ?? '';
      request.fields['description'] = product.description;
      request.fields['sellerName'] = product.sellerName ?? '';

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      } else if (product.imageUrl.isNotEmpty) {
        request.fields['image'] = product.imageUrl;
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return _productFromJson(data);
      }
      return null;
    } catch (e) {
      print('Error creating pet: $e');
      return null;
    }
  }

  // Delete pet
  static Future<bool> deletePet(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/pets/$id'),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting pet: $e');
      return false;
    }
  }

  // Check server health
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Convert JSON to Product
  static Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image'] ?? '',
      categoryId: json['category'] ?? '',
      categoryName: json['category'] ?? '',
      breed: json['breed'],
      age: json['age'],
      city: json['location'],
      sellerName: json['seller']?['name'],
      rating: (json['rating'] ?? 4.5).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
