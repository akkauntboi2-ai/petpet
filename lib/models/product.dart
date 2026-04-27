class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final double rating;
  final String? breed;
  final String? age;
  final String? gender; // Пол: male/female
  final bool isVaccinated; // Привит
  final bool isNegotiable; // Цена договорная
  final String? color; // Окрас
  final String? city; // Город
  final bool isTop;
  final String? sellerName;
  final String? sellerPhone;
  final String? sellerTelegram;
  final DateTime? createdAt;
  final List<String> images; // Дополнительные фото
  final String currency; // sum or usd

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    this.rating = 4.5,
    this.breed,
    this.age,
    this.gender,
    this.isVaccinated = false,
    this.isNegotiable = false,
    this.color,
    this.city,
    this.isTop = false,
    this.sellerName,
    this.sellerPhone,
    this.sellerTelegram,
    this.createdAt,
    this.images = const [],
    this.currency = 'sum',
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > price;
  double get discountPercent => hasDiscount ? ((oldPrice! - price) / oldPrice! * 100) : 0;

  String get genderText {
    if (gender == 'male') return 'Мальчик';
    if (gender == 'female') return 'Девочка';
    return '';
  }

  String get priceText {
    if (isNegotiable) return 'Договорная';
    if (currency == 'usd') {
      return '\$${price.toStringAsFixed(0)}';
    }
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)} млн сум';
    }
    return '${_formatNumber(price.toInt())} сум';
  }

  String _formatNumber(int number) {
    String result = '';
    String numStr = number.toString();
    int count = 0;
    for (int i = numStr.length - 1; i >= 0; i--) {
      count++;
      result = numStr[i] + result;
      if (count % 3 == 0 && i > 0) {
        result = ' $result';
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'rating': rating,
      'breed': breed,
      'age': age,
      'gender': gender,
      'isVaccinated': isVaccinated,
      'isNegotiable': isNegotiable,
      'color': color,
      'city': city,
      'isTop': isTop,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'sellerTelegram': sellerTelegram,
      'createdAt': createdAt?.toIso8601String(),
      'images': images,
      'currency': currency,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      oldPrice: json['oldPrice']?.toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      breed: json['breed'],
      age: json['age'],
      gender: json['gender'],
      isVaccinated: json['isVaccinated'] ?? false,
      isNegotiable: json['isNegotiable'] ?? false,
      color: json['color'],
      city: json['city'],
      isTop: json['isTop'] ?? false,
      sellerName: json['sellerName'],
      sellerPhone: json['sellerPhone'],
      sellerTelegram: json['sellerTelegram'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      images: List<String>.from(json['images'] ?? []),
      currency: json['currency'] ?? 'sum',
    );
  }
}
