import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'my_ads_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _telegramController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  void _openAuthScreen(BuildContext context, AuthProvider auth) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AuthScreen(
          onAuthSuccess: (name, phone, telegramId) {
            auth.completeAuth(name, phone, telegramId);
          },
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    _nameController.text = auth.user?.name ?? '';
    _phoneController.text = auth.user?.phone ?? '';
    _telegramController.text = auth.user?.telegramUsername ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Редактировать профиль',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telegramController,
              decoration: const InputDecoration(
                labelText: 'Telegram username',
                prefixIcon: Icon(Icons.send),
                hintText: '@username',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  auth.updateProfile(
                    name: _nameController.text,
                    phone: _phoneController.text,
                    telegramUsername: _telegramController.text,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите язык',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Text('🇷🇺', style: TextStyle(fontSize: 24)),
              title: const Text('Русский'),
              trailing: const Icon(Icons.check, color: AppTheme.primary),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Text('🇺🇿', style: TextStyle(fontSize: 24)),
              title: const Text("O'zbekcha"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Скоро будет доступно')),
                );
              },
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          bool messagesEnabled = true;
          bool adsEnabled = true;
          bool newsEnabled = false;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Уведомления',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Сообщения'),
                  subtitle: const Text('Уведомления о новых сообщениях'),
                  value: messagesEnabled,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setModalState(() => messagesEnabled = val),
                ),
                SwitchListTile(
                  title: const Text('Объявления'),
                  subtitle: const Text('Новые объявления в избранных категориях'),
                  value: adsEnabled,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setModalState(() => adsEnabled = val),
                ),
                SwitchListTile(
                  title: const Text('Новости'),
                  subtitle: const Text('Акции и специальные предложения'),
                  value: newsEnabled,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setModalState(() => newsEnabled = val),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('PetPet'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Версия 1.0.0',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'PetPet - удобная площадка для покупки и продажи животных в Узбекистане.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Контакты:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => launchUrl(Uri.parse('https://t.me/petpetuz_bot')),
              child: const Row(
                children: [
                  Icon(Icons.send, size: 18, color: Color(0xFF0088cc)),
                  SizedBox(width: 8),
                  Text(
                    '@petpetuz_bot',
                    style: TextStyle(color: Color(0xFF0088cc)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Профиль', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: auth.isLoggedIn
                    ? Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: AppTheme.primary,
                                child: Text(
                                  (auth.user?.name ?? 'П')[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      auth.user!.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      auth.user!.phone,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (auth.user!.telegramUsername != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        auth.user!.telegramUsername!,
                                        style: const TextStyle(
                                          color: Color(0xFF0088cc),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showEditProfileDialog(context, auth),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Изменить'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Выйти?'),
                                        content: const Text('Вы уверены что хотите выйти из аккаунта?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Отмена'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              auth.logout();
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text(
                                              'Выйти',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                                  label: const Text('Выйти', style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Войдите чтобы размещать объявления',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _openAuthScreen(context, auth),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0088cc),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.send),
                              label: const Text(
                                'Войти через Telegram',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              if (auth.isLoggedIn) ...[
                const SizedBox(height: 24),
                _buildMenuItem(
                  icon: Icons.article_outlined,
                  title: 'Мои объявления',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyAdsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.favorite_outline,
                  title: 'Избранное',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    );
                  },
                ),
              ],

              const SizedBox(height: 24),
              _buildMenuItem(
                icon: Icons.language_outlined,
                title: 'Язык',
                subtitle: 'Русский',
                onTap: () => _showLanguageDialog(context),
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Уведомления',
                onTap: () => _showNotificationsDialog(context),
              ),

              const SizedBox(height: 24),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'О приложении',
                onTap: () => _showAboutDialog(context),
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Помощь',
                onTap: () {
                  launchUrl(Uri.parse('https://t.me/petpetuz_bot'));
                },
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'PetPet v1.0.0',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600)) : null,
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}
