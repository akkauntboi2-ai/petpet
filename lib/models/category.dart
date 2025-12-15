import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final String? imagePath;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.imagePath,
    required this.color,
  });
}

class AppCategories {
  static final List<Category> animals = [
    Category(
      id: 'cats',
      name: 'Кошки',
      icon: '🐱',
      imagePath: 'assets/categories/cat.jpg',
      color: Colors.pink,
    ),
    Category(
      id: 'dogs',
      name: 'Собаки',
      icon: '🐕',
      imagePath: 'assets/categories/dog.png',
      color: Colors.blue,
    ),
    Category(
      id: 'birds',
      name: 'Птицы',
      icon: '🦜',
      imagePath: 'assets/categories/bird.png',
      color: Colors.amber,
    ),
    Category(
      id: 'horses',
      name: 'Лошади',
      icon: '🐴',
      imagePath: 'assets/categories/horse.jpg',
      color: Colors.brown,
    ),
  ];

  static final List<Category> accessories = [
    Category(id: 'food', name: 'Корма', icon: '🍖', color: Colors.orange),
    Category(id: 'cages', name: 'Клетки', icon: '🏠', color: Colors.blueGrey),
    Category(id: 'toys', name: 'Игрушки', icon: '🎾', color: Colors.purple),
  ];
}
