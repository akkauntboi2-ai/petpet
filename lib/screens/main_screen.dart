import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final _screens = const [HomeScreen(), CatalogScreen(), FavoritesScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
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
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Главная',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.apps_outlined),
              activeIcon: Icon(Icons.apps),
              label: 'Каталог',
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
              label: 'Избранное',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
