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
      color: Colors.grey,
    ),
    Category(
      id: 'dogs',
      name: 'Собаки',
      icon: '🐕',
      imagePath: 'assets/categories/dog.png',
      color: Colors.grey,
    ),
    Category(
      id: 'birds',
      name: 'Птицы',
      icon: '🦜',
      imagePath: 'assets/categories/bird.png',
      color: Colors.grey,
    ),
    Category(
      id: 'horses',
      name: 'Лошади',
      icon: '🐴',
      imagePath: 'assets/categories/horse.jpg',
      color: Colors.grey,
    ),
    Category(
      id: 'fish',
      name: 'Рыбки',
      icon: '🐟',
      imagePath: 'assets/categories/fish.png',
      color: Colors.grey,
    ),
    Category(
      id: 'rodents',
      name: 'Грызуны',
      icon: '🐹',
      imagePath: 'assets/categories/rodent.jpg',
      color: Colors.grey,
    ),
    Category(
      id: 'reptiles',
      name: 'Рептилии',
      icon: '🦎',
      imagePath: 'assets/categories/reptile.jpg',
      color: Colors.grey,
    ),
    Category(
      id: 'insects',
      name: 'Насекомые',
      icon: '🐞',
      imagePath: 'assets/categories/insects.png',
      color: Colors.grey,
    ),
    Category(
      id: 'wild',
      name: 'Дикие',
      icon: '🐺',
      imagePath: 'assets/categories/wild.png',
      color: Colors.grey,
    ),
  ];

  static final List<Category> accessories = [
    Category(id: 'food', name: 'Корма', icon: '🍖', color: Colors.grey),
    Category(id: 'cages', name: 'Клетки', icon: '🏠', color: Colors.grey),
    Category(id: 'toys', name: 'Игрушки', icon: '🎾', color: Colors.grey),
  ];
}
