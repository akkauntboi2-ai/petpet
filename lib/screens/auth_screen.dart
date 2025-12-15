import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  final Function(String name, String phone, String? telegramId) onAuthSuccess;

  const AuthScreen({super.key, required this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with WidgetsBindingObserver {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  int _step = 1; // 1 = phone, 2 = waiting for telegram, 3 = name
  bool _isLoading = false;
  String _phoneNumber = '';
  String? _telegramUsername;
  String? _telegramName;
  Timer? _checkTimer;
  int _lastUpdateId = 0;

  static const String botToken = '8024293449:AAEfyTzZerNUxxo-f13yO4ikZR45yUuh-1U';
  static const String botUsername = 'petpetuz_bot';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phoneController.dispose();
    _nameController.dispose();
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Когда пользователь возвращается в приложение, проверяем авторизацию
    if (state == AppLifecycleState.resumed && _step == 2) {
      _checkTelegramAuth();
    }
  }

  String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  Future<void> _requestAuth() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный номер')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneNumber = phone;
    });

    // Получаем последний update_id чтобы игнорировать старые сообщения
    try {
      final url = 'https://api.telegram.org/bot$botToken/getUpdates?offset=-1&limit=1';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true && (data['result'] as List).isNotEmpty) {
          _lastUpdateId = data['result'][0]['update_id'];
        }
      }
    } catch (e) {
      // ignore
    }

    setState(() {
      _isLoading = false;
      _step = 2;
    });

    // Автоматически открываем Telegram
    _openTelegram();

    // Начинаем проверять авторизацию
    _startCheckingAuth();
  }

  void _startCheckingAuth() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _checkTelegramAuth();
    });
  }

  Future<void> _checkTelegramAuth() async {
    try {
      // Получаем новые сообщения после нашего запроса
      final url = 'https://api.telegram.org/bot$botToken/getUpdates?offset=${_lastUpdateId + 1}&limit=20';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          final updates = data['result'] as List;

          for (var update in updates) {
            _lastUpdateId = update['update_id'];

            if (update['message'] != null) {
              final message = update['message'];
              final contact = message['contact'];

              if (contact != null) {
                final contactPhone = _cleanPhone(contact['phone_number'] ?? '');
                final myPhone = _cleanPhone(_phoneNumber);

                // Проверяем совпадение номеров (с учетом кода страны)
                if (contactPhone.endsWith(myPhone) ||
                    myPhone.endsWith(contactPhone) ||
                    contactPhone == myPhone ||
                    contactPhone.contains(myPhone) ||
                    myPhone.contains(contactPhone)) {

                  // Нашли совпадение!
                  _checkTimer?.cancel();

                  final user = message['from'];
                  _telegramUsername = user['username'];
                  _telegramName = user['first_name'] ?? '';

                  // Заполняем имя из Telegram
                  _nameController.text = _telegramName ?? '';

                  if (mounted) {
                    setState(() => _step = 3);
                  }
                  return;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking auth: $e');
    }
  }

  void _openTelegram() {
    launchUrl(
      Uri.parse('https://t.me/$botUsername?start=auth'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _completeAuth() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите ваше имя')),
      );
      return;
    }

    widget.onAuthSuccess(name, _phoneNumber, _telegramUsername);
    Navigator.pop(context);
  }

  // Ручная проверка - пользователь может нажать чтобы проверить статус
  void _manualCheck() async {
    setState(() => _isLoading = true);
    await _checkTelegramAuth();
    setState(() => _isLoading = false);

    if (_step == 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Контакт не найден. Отправьте контакт в боте.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Регистрация'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.primary,
                      child: const Icon(Icons.pets, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'PetPet',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),

            // Step indicator
            Row(
              children: [
                _buildStepCircle(1, _step >= 1),
                Expanded(child: Container(height: 2, color: _step >= 2 ? AppTheme.primary : Colors.grey.shade300)),
                _buildStepCircle(2, _step >= 2),
                Expanded(child: Container(height: 2, color: _step >= 3 ? AppTheme.primary : Colors.grey.shade300)),
                _buildStepCircle(3, _step >= 3),
              ],
            ),
            const SizedBox(height: 32),

            if (_step == 1) ...[
              // Step 1: Phone
              const Text(
                'Введите номер телефона',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Мы подтвердим его через Telegram',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+998 90 123 45 67',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestAuth,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Продолжить', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ] else if (_step == 2) ...[
              // Step 2: Waiting for Telegram
              const Text(
                'Подтвердите в Telegram',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Номер: $_phoneNumber',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.send, size: 48, color: Color(0xFF0088cc)),
                    const SizedBox(height: 16),
                    const Text(
                      '1. Откройте Telegram бот\n2. Нажмите кнопку "Отправить номер"\n3. Вернитесь в приложение',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openTelegram,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0088cc),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          'Открыть Telegram',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isLoading) ...[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      _isLoading ? 'Проверяю...' : 'Ожидание подтверждения...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Кнопка ручной проверки
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _manualCheck,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Проверить вручную'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    _checkTimer?.cancel();
                    setState(() => _step = 1);
                  },
                  child: const Text('Изменить номер'),
                ),
              ),
            ] else if (_step == 3) ...[
              // Step 3: Name
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Telegram подтвержден!',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (_telegramUsername != null)
                            Text(
                              '@$_telegramUsername',
                              style: const TextStyle(color: Color(0xFF0088cc)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Как вас зовут?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ваше имя',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _completeAuth,
                  child: const Text('Завершить регистрацию', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(int step, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
