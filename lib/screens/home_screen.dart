import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/sample_data.dart';
import '../providers/favorites_provider.dart';
import '../providers/ads_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'category_screen.dart';
import 'add_ad_screen.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showLanguageDialog(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              langProvider.tr('select_language'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ...LanguageProvider.availableLanguages.map((lang) => ListTile(
              leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
              title: Text(
                lang['name']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              trailing: langProvider.currentLanguage == lang['code']
                  ? const Icon(Icons.check_circle, color: AppTheme.primary)
                  : null,
              onTap: () {
                langProvider.setLanguage(lang['code']!);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adsProvider = Provider.of<AdsProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    

    // Combine user ads with sample data
    final userTopAds = adsProvider.myAds.where((ad) => ad.isTop).toList();
    final topProducts = [...userTopAds, ...SampleData.topAds];

    final userNewAds = adsProvider.myAds.where((ad) => !ad.isTop).toList();
    final newProducts = [...userNewAds, ...SampleData.newAds];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAdScreen()));
        },
        backgroundColor: AppTheme.primary,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          langProvider.tr('add_ad'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.primary,
                          child: const Icon(Icons.pets, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PetPet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                // Language button
                GestureDetector(
                  onTap: () => _showLanguageDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(langProvider.flagEmoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Text(
                          langProvider.currentLanguage.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 26),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Search bar
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.search, color: Colors.grey.shade400, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        langProvider.tr('search_hint'),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      langProvider.tr('categories'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(langProvider.tr('all'), style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  ],
                ),
              ),
            ),

            // Categories grid
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    ...AppCategories.animals.map((c) => _buildCategoryChip(context, c, langProvider)),
                  ],
                ),
              ),
            ),

            // TOP section
            if (topProducts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'TOP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        langProvider.tr('popular'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: topProducts.length,
                    itemBuilder: (_, i) => _buildLargeProductCard(context, topProducts[i]),
                  ),
                ),
              ),
            ],

            // New ads
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  langProvider.tr('new_ads'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildProductCard(context, newProducts[i]),
                  childCount: newProducts.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(Category c, LanguageProvider langProvider) {
    switch (c.id) {
      case 'cats': return langProvider.tr('cats');
      case 'dogs': return langProvider.tr('dogs');
      case 'birds': return langProvider.tr('birds');
      case 'horses': return langProvider.tr('horses');
      case 'fish': return langProvider.tr('fish');
      case 'rodents': return langProvider.tr('rodents');
      case 'reptiles': return langProvider.tr('reptiles');
      default: return c.name;
    }
  }

  Widget _buildCategoryChip(BuildContext context, Category c, LanguageProvider langProvider) {
    // Use contain for horses to show full image, cover for others
    final fitMode = c.id == 'horses' ? BoxFit.contain : BoxFit.cover;
    

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CategoryScreen(category: c)),
      ),
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  color: Colors.white,
                  child: c.imagePath != null
                      ? (c.id == 'horses'
                          ? FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.centerRight,
                              child: Image.asset(
                                c.imagePath!,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(c.icon, style: const TextStyle(fontSize: 32)),
                                ),
                              ),
                            )
                          : Image.asset(
                              c.imagePath!,
                              fit: fitMode,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(c.icon, style: const TextStyle(fontSize: 32)),
                              ),
                            ))
                      : Center(
                          child: Text(c.icon, style: const TextStyle(fontSize: 32)),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getCategoryName(c, langProvider),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeProductCard(BuildContext context, Product product) {
    
    return Consumer<FavoritesProvider>(
      builder: (context, favorites, _) {
        final isFav = favorites.isFavorite(product.id);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
            );
          },
          child: Container(
            width: 220,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMedium)),
                      child: _buildProductImage(product.imageUrl, double.infinity, 160),
                    ),
                    // TOP badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                            SizedBox(width: 2),
                            Text(
                              'TOP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Favorite
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => favorites.toggleFavorite(product),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_outline,
                            size: 20,
                            color: isFav ? AppTheme.favorite : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            height: 1.2,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Tags
                        Row(
                          children: [
                            if (product.breed != null) ...[
                              _buildTag(product.breed!, Colors.blue.shade50, Colors.blue.shade700),
                              const SizedBox(width: 6),
                            ],
                            if (product.age != null)
                              _buildTag(product.age!, Colors.green.shade50, Colors.green.shade700),
                          ],
                        ),
                        const Spacer(),
                        // Bottom row
                        Row(
                          children: [
                            if (product.isVaccinated)
                              Flexible(
                                child: Consumer<LanguageProvider>(
                                  builder: (context, lang, _) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, size: 12, color: Colors.green.shade700),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            lang.tr('vaccinated'),
                                            style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Flexible(
                              child: Text(
                                product.priceText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    
    return Consumer<FavoritesProvider>(
      builder: (context, favorites, _) {
        final isFav = favorites.isFavorite(product.id);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMedium)),
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: _buildProductImage(product.imageUrl, double.infinity, double.infinity),
                        ),
                      ),
                      // TOP badge
                      if (product.isTop)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'TOP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      // Favorite button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => favorites.toggleFavorite(product),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                              ],
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_outline,
                              size: 18,
                              color: isFav ? AppTheme.favorite : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Info
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.2,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Breed & Age tags
                        if (product.breed != null || product.age != null)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              if (product.breed != null)
                                _buildSmallTag(product.breed!, Colors.blue.shade50),
                              if (product.age != null)
                                _buildSmallTag(product.age!, Colors.green.shade50),
                            ],
                          ),
                        const SizedBox(height: 4),
                        // City
                        if (product.city != null)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  product.city!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                        const Spacer(),
                        // Bottom row with icons and price
                        Row(
                          children: [
                            if (product.isVaccinated)
                              Icon(Icons.verified, size: 14, color: Colors.green.shade600),
                            if (product.isNegotiable)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(Icons.handshake_outlined, size: 14, color: Colors.orange.shade600),
                              ),
                            const Spacer(),
                            // Price - fixed to not overflow
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  product.priceText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallTag(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9, color: Colors.black87),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProductImage(String imageUrl, double width, double height) {
    final isLocalFile = imageUrl.startsWith('/') || imageUrl.contains('cache');

    if (isLocalFile) {
      return Image.file(
        File(imageUrl),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 40, color: Colors.grey),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: Colors.grey.shade100,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 40, color: Colors.grey),
      ),
    );
  }
}
