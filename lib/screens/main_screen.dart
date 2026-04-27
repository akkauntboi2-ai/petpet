import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static _MainScreenState? _instance;

  static void switchToTab(int index) {
    _instance?.switchTab(index);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    MainScreen._instance = this;
  }

  void switchTab(int index) {
    setState(() => _index = index);
  }
  final _screens = const [HomeScreen(), CatalogScreen(), FavoritesScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: lang.tr('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.apps_outlined),
              activeIcon: const Icon(Icons.apps),
              label: lang.tr('catalog'),
            ),
            BottomNavigationBarItem(
              icon: Consumer<FavoritesProvider>(
                builder: (_, fav, __) => Badge(
                  isLabelVisible: fav.count > 0,
                  backgroundColor: AppTheme.favorite,
                  label: Text('${fav.count}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  child: const Icon(Icons.favorite_outline),
                ),
              ),
              activeIcon: Consumer<FavoritesProvider>(
                builder: (_, fav, __) => Badge(
                  isLabelVisible: fav.count > 0,
                  backgroundColor: AppTheme.favorite,
                  label: Text('${fav.count}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  child: const Icon(Icons.favorite),
                ),
              ),
              label: lang.tr('favorites'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: lang.tr('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
