class VetClinic {
  final String id;
  final String name;
  final String imageUrl;
  final String address;
  final String phone;
  final String? description;
  final String? experience;
  final List<String> services;
  final double? rating;
  final String? workingHours;
  final String? city;

  VetClinic({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.phone,
    this.description,
    this.experience,
    this.services = const [],
    this.rating,
    this.workingHours,
    this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
      'phone': phone,
      'description': description,
      'experience': experience,
      'services': services,
      'rating': rating,
      'workingHours': workingHours,
      'city': city,
    };
  }

  factory VetClinic.fromJson(Map<String, dynamic> json) {
    return VetClinic(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'],
      experience: json['experience'],
      services: List<String>.from(json['services'] ?? []),
      rating: json['rating']?.toDouble(),
      workingHours: json['workingHours'],
      city: json['city'],
    );
  }
}

// Sample data for demo purposes
class SampleVetData {
  static List<VetClinic> get clinics => [
    VetClinic(
      id: '1',
      name: 'Vet clinic Ramazan',
      imageUrl: '',
      address: 'ул. Навои 25, Ташкент',
      phone: '+998 90 123 45 67',
      description: 'Современная ветеринарная клиника с полным спектром услуг для ваших питомцев.',
      experience: '10 лет опыта',
      services: ['Вакцинация', 'Хирургия', 'УЗИ', 'Стоматология', 'Груминг'],
      rating: 4.8,
      workingHours: '09:00 - 21:00',
      city: 'Ташкент',
    ),
    VetClinic(
      id: '2',
      name: 'Vet clinic Айболит',
      imageUrl: '',
      address: 'ул. Амира Темура 50, Ташкент',
      phone: '+998 90 987 65 43',
      description: 'Забота о здоровье ваших питомцев - наша главная миссия.',
      experience: '15 лет опыта',
      services: ['Терапия', 'Вакцинация', 'Анализы', 'Рентген', 'Стационар'],
      rating: 4.9,
      workingHours: '08:00 - 22:00',
      city: 'Ташкент',
    ),
    VetClinic(
      id: '3',
      name: 'Happy Pets',
      imageUrl: '',
      address: 'ул. Шота Руставели 15, Ташкент',
      phone: '+998 91 234 56 78',
      description: 'Профессиональная помощь для кошек, собак и экзотических животных.',
      experience: '8 лет опыта',
      services: ['Кастрация', 'Стерилизация', 'Чипирование', 'Груминг'],
      rating: 4.7,
      workingHours: '10:00 - 20:00',
      city: 'Ташкент',
    ),
    VetClinic(
      id: '4',
      name: 'Zoo Doctor',
      imageUrl: '',
      address: 'ул. Мирзо Улугбека 100, Самарканд',
      phone: '+998 93 456 78 90',
      description: 'Ветеринарная клиника европейского уровня.',
      experience: '12 лет опыта',
      services: ['Диагностика', 'Лечение', 'Профилактика', 'Консультации'],
      rating: 4.6,
      workingHours: '09:00 - 19:00',
      city: 'Самарканд',
    ),
  ];
}
