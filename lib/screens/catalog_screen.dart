import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category.dart';
import '../models/sample_data.dart';
import '../theme/app_theme.dart';
import 'category_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  // Fallback images from Unsplash for accessories
  static const Map<String, String> categoryImages = {
    'food': 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=300',
    'toys': 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=300',
    'cages': 'https://images.unsplash.com/photo-1555685812-4b943f1cb0eb?w=300',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Все товары',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search, color: Colors.grey.shade500),
                          const SizedBox(width: 10),
                          Text(
                            'Поиск товаров...',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Animals section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Животные',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Выберите питомца',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text('Ещё', style: TextStyle(color: Colors.grey.shade700)),
                          Icon(Icons.chevron_right, color: Colors.grey.shade700, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildCategoryCard(context, AppCategories.animals[i]),
                  childCount: AppCategories.animals.length,
                ),
              ),
            ),

            // Accessories section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Товары',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Для ваших питомцев',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text('Ещё', style: TextStyle(color: Colors.grey.shade700)),
                          Icon(Icons.chevron_right, color: Colors.grey.shade700, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildCategoryCard(context, AppCategories.accessories[i]),
                  childCount: AppCategories.accessories.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category c) {
    final networkImageUrl = categoryImages[c.id];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CategoryScreen(category: c)),
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Title at top
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
              child: Text(
                c.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Image - use local asset if available, otherwise network
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.white,
                    child: c.imagePath != null
                        ? Image.asset(
                            c.imagePath!,
                            fit: c.id == 'horses' ? BoxFit.contain : BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white,
                              child: Center(
                                child: Text(c.icon, style: const TextStyle(fontSize: 36)),
                              ),
                            ),
                          )
                        : networkImageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: networkImageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (_, __) => Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Text(c.icon, style: const TextStyle(fontSize: 36)),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Text(c.icon, style: const TextStyle(fontSize: 36)),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.white,
                                child: Center(
                                  child: Text(c.icon, style: const TextStyle(fontSize: 36)),
                                ),
                              ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
