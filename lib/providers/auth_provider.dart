import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String? telegramUsername;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.telegramUsername,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'telegramUsername': telegramUsername,
    'avatarUrl': avatarUrl,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    telegramUsername: json['telegramUsername'],
    avatarUrl: json['avatarUrl'],
  );
}

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  // Этот метод вызывается из AuthScreen после успешной авторизации
  void completeAuth(String name, String phone, String? telegramUsername) {
    _user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      telegramUsername: telegramUsername != null ? '@$telegramUsername' : null,
    );
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void updateProfile({String? name, String? phone, String? telegramUsername}) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: name ?? _user!.name,
        phone: phone ?? _user!.phone,
        telegramUsername: telegramUsername ?? _user!.telegramUsername,
        avatarUrl: _user!.avatarUrl,
      );
      notifyListeners();
    }
  }
}
