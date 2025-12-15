import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ads_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class AddAdScreen extends StatefulWidget {
  const AddAdScreen({super.key});

  @override
  State<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends State<AddAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _colorController = TextEditingController();
  final _telegramController = TextEditingController();

  String _selectedCategory = 'cats';
  String _selectedCity = 'Ташкент';
  String? _selectedGender;
  String _selectedCurrency = 'sum'; // sum or usd
  bool _isVaccinated = false;
  bool _isNegotiable = false;
  bool _isTopPromotion = false;
  int _topDays = 3;
  List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _categories = {
    'cats': 'Кошки',
    'dogs': 'Собаки',
    'birds': 'Птицы',
    'horses': 'Лошади',
    'rodents': 'Грызуны',
    'fish': 'Рыбки',
    'reptiles': 'Рептилии',
    'other': 'Другое',
  };

  final List<String> _cities = [
    'Ташкент',
    'Самарканд',
    'Бухара',
    'Наманган',
    'Андижан',
    'Фергана',
    'Нукус',
    'Карши',
    'Ургенч',
    'Джиззах',
    'Навои',
    'Термез',
  ];

  final Map<int, int> _topPrices = {
    3: 15000,
    7: 25000,
    30: 50000,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        _phoneController.text = auth.user!.phone;
        if (auth.user!.telegramUsername != null) {
          _telegramController.text = auth.user!.telegramUsername!.replaceFirst('@', '');
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _colorController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photos.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Максимум 8 фотографий')),
      );
      return;
    }

    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (images.isNotEmpty) {
          setState(() {
            final remaining = 8 - _photos.length;
            _photos.addAll(images.take(remaining));
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            _photos.add(image);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Добавить фото',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: AppTheme.primary),
              ),
              title: const Text('Выбрать из галереи'),
              subtitle: const Text('Можно выбрать несколько'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: AppTheme.primary),
              ),
              title: const Text('Сделать фото'),
              subtitle: const Text('Открыть камеру'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _submitAd() {
    if (_formKey.currentState!.validate()) {
      if (_photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Добавьте хотя бы одно фото'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create Product and save to provider
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final adsProvider = Provider.of<AdsProvider>(context, listen: false);

      final product = Product(
        id: 'ad_${DateTime.now().millisecondsSinceEpoch}',
        name: _titleController.text,
        description: _descriptionController.text,
        price: _isNegotiable ? 0 : (double.tryParse(_priceController.text.replaceAll(' ', '')) ?? 0),
        imageUrl: _photos.isNotEmpty ? _photos.first.path : '',
        categoryId: _selectedCategory,
        categoryName: _categories[_selectedCategory] ?? '',
        breed: _breedController.text.isNotEmpty ? _breedController.text : null,
        age: _ageController.text.isNotEmpty ? _ageController.text : null,
        gender: _selectedGender,
        isVaccinated: _isVaccinated,
        isNegotiable: _isNegotiable,
        color: _colorController.text.isNotEmpty ? _colorController.text : null,
        city: _selectedCity,
        isTop: _isTopPromotion,
        sellerName: auth.user?.name ?? 'Продавец',
        sellerPhone: _phoneController.text,
        sellerTelegram: _telegramController.text.isNotEmpty ? '@${_telegramController.text}' : null,
        createdAt: DateTime.now(),
        images: _photos.skip(1).map((p) => p.path).toList(),
        currency: _selectedCurrency,
      );

      adsProvider.addAd(product);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppTheme.primary, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Объявление опубликовано!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Ваше объявление успешно добавлено и уже доступно для просмотра',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              if (_isTopPromotion) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'TOP на $_topDays дней активирован!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Отлично!', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Новое объявление',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Free badge
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.1),
                          AppTheme.primaryLight.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Размещение БЕСПЛАТНО',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Объявление будет активно 30 дней',
                                style: TextStyle(color: AppTheme.primary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Photos section
                  _buildSectionCard(
                    title: 'Фотографии',
                    subtitle: 'Добавьте до 8 фото. Первое фото будет главным',
                    icon: Icons.photo_library,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ..._photos.asMap().entries.map((entry) {
                                final index = entry.key;
                                final photo = entry.value;
                                return Stack(
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 110,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(
                                          File(photo.path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    if (index == 0)
                                      Positioned(
                                        left: 6,
                                        top: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Главное',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      right: 16,
                                      top: 4,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _photos.removeAt(index)),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              if (_photos.length < 8)
                                GestureDetector(
                                  onTap: _showImagePickerOptions,
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.primary.withOpacity(0.3),
                                        width: 2,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add_photo_alternate,
                                            size: 28,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${_photos.length}/8',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category & City
                  _buildSectionCard(
                    title: 'Категория и город',
                    icon: Icons.category,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildPremiumDropdown(
                          label: 'Категория',
                          icon: Icons.pets,
                          value: _selectedCategory,
                          items: _categories.entries.map((e) {
                            return DropdownMenuItem(value: e.key, child: Text(e.value));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value!),
                        ),
                        const SizedBox(height: 16),
                        _buildPremiumDropdown(
                          label: 'Город',
                          icon: Icons.location_city,
                          value: _selectedCity,
                          items: _cities.map((city) {
                            return DropdownMenuItem(value: city, child: Text(city));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCity = value!),
                        ),
                      ],
                    ),
                  ),

                  // Main info
                  _buildSectionCard(
                    title: 'Основная информация',
                    icon: Icons.info_outline,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildPremiumTextField(
                          controller: _titleController,
                          label: 'Название объявления',
                          hint: 'Например: Британский котёнок, мальчик',
                          icon: Icons.title,
                          validator: (v) => v?.isEmpty == true ? 'Введите название' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildPremiumTextField(
                                controller: _priceController,
                                label: 'Цена',
                                hint: _selectedCurrency == 'sum' ? '500 000' : '100',
                                icon: Icons.payments,
                                keyboardType: TextInputType.number,
                                enabled: !_isNegotiable,
                                validator: (v) {
                                  if (_isNegotiable) return null;
                                  return v?.isEmpty == true ? 'Введите цену' : null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Currency selector
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _isNegotiable ? null : () => setState(() => _selectedCurrency = 'sum'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: _selectedCurrency == 'sum' ? AppTheme.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'сум',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: _selectedCurrency == 'sum' ? Colors.white : Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _isNegotiable ? null : () => setState(() => _selectedCurrency = 'usd'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: _selectedCurrency == 'usd' ? AppTheme.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '\$',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: _selectedCurrency == 'usd' ? Colors.white : Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPremiumSwitch(
                          title: 'Цена договорная',
                          subtitle: 'Цена обсуждается с покупателем',
                          value: _isNegotiable,
                          onChanged: (v) => setState(() => _isNegotiable = v),
                        ),
                      ],
                    ),
                  ),

                  // Pet details
                  _buildSectionCard(
                    title: 'Характеристики питомца',
                    icon: Icons.pets,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildPremiumTextField(
                          controller: _breedController,
                          label: 'Порода',
                          hint: 'Например: Британская короткошерстная',
                          icon: Icons.pets,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _ageController,
                                label: 'Возраст',
                                hint: '3 месяца',
                                icon: Icons.cake,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _colorController,
                                label: 'Окрас',
                                hint: 'Серый',
                                icon: Icons.color_lens,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Gender selection
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Пол',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGenderButton(
                                    label: 'Мальчик',
                                    icon: Icons.male,
                                    value: 'male',
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildGenderButton(
                                    label: 'Девочка',
                                    icon: Icons.female,
                                    value: 'female',
                                    color: Colors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPremiumSwitch(
                          title: 'Привит',
                          subtitle: 'Питомец имеет все необходимые прививки',
                          value: _isVaccinated,
                          onChanged: (v) => setState(() => _isVaccinated = v),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),

                  // Description
                  _buildSectionCard(
                    title: 'Описание',
                    icon: Icons.description,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildPremiumTextField(
                          controller: _descriptionController,
                          label: 'Описание объявления',
                          hint: 'Опишите питомца подробнее: характер, особенности, что входит в комплект...',
                          icon: Icons.edit_note,
                          maxLines: 5,
                          validator: (v) => v?.isEmpty == true ? 'Введите описание' : null,
                        ),
                      ],
                    ),
                  ),

                  // Contact info
                  _buildSectionCard(
                    title: 'Контактные данные',
                    icon: Icons.contact_phone,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildPremiumTextField(
                          controller: _phoneController,
                          label: 'Номер телефона',
                          hint: '+998 90 123 45 67',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v?.isEmpty == true ? 'Введите телефон' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildPremiumTextField(
                          controller: _telegramController,
                          label: 'Telegram (необязательно)',
                          hint: 'username без @',
                          icon: Icons.send,
                          prefix: '@',
                        ),
                      ],
                    ),
                  ),

                  // TOP promotion
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: _isTopPromotion
                          ? const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _isTopPromotion ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _isTopPromotion
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isTopPromotion
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.local_fire_department,
                                  color: _isTopPromotion ? Colors.white : Colors.orange,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _isTopPromotion
                                                ? Colors.white
                                                : Colors.orange,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'TOP',
                                            style: TextStyle(
                                              color: _isTopPromotion
                                                  ? Colors.orange
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Продвижение',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _isTopPromotion
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ваше объявление будет в топе',
                                      style: TextStyle(
                                        color: _isTopPromotion
                                            ? Colors.white70
                                            : Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isTopPromotion,
                                onChanged: (v) => setState(() => _isTopPromotion = v),
                                activeColor: Colors.white,
                                activeTrackColor: Colors.white.withOpacity(0.3),
                              ),
                            ],
                          ),
                          if (_isTopPromotion) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: _topPrices.entries.map((e) {
                                final isSelected = _topDays == e.key;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _topDays = e.key),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14),
                                        border: isSelected
                                            ? null
                                            : Border.all(
                                                color: Colors.white.withOpacity(0.3),
                                              ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${e.key}',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.orange
                                                  : Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'дней',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isSelected
                                                  ? Colors.orange
                                                  : Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${e.value} сум',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.grey.shade700
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _submitAd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.publish, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              _isTopPromotion
                                  ? 'Опубликовать (${_topPrices[_topDays]} сум)'
                                  : 'Опубликовать бесплатно',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool enabled = true,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        prefixText: prefix,
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPremiumDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildPremiumSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
    Color? activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: value
            ? (activeColor ?? AppTheme.primary).withOpacity(0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? (activeColor ?? AppTheme.primary).withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: value ? (activeColor ?? AppTheme.primary) : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = isSelected ? null : value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey.shade500, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
