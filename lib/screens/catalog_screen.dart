import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/sample_data.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'category_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fallback images from Unsplash for accessories
  static const Map<String, String> categoryImages = {
    'food': 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=300',
    'toys': 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=300',
    'cages': 'https://images.unsplash.com/photo-1555685812-4b943f1cb0eb?w=300',
  };

  List<String> _getSearchSuggestions(LanguageProvider lang) {
    final suggestions = <String>[];
    for (final cat in AppCategories.animals) {
      suggestions.add(_getCategoryName(cat, lang));
    }
    for (final cat in AppCategories.accessories) {
      suggestions.add(_getCategoryName(cat, lang));
    }
    return suggestions
        .where((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    

    return Scaffold(
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
                    Text(
                      lang.tr('all_products'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search bar with autocomplete
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: lang.tr('search_products'),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                            ),
                          ),
                          // Autocomplete suggestions
                          if (_searchQuery.isNotEmpty)
                            ..._getSearchSuggestions(lang).map((suggestion) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.search, size: 20),
                              title: Text(suggestion),
                              onTap: () {
                                _searchController.text = suggestion;
                                setState(() => _searchQuery = suggestion);
                              },
                            )),
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
                        Text(
                          lang.tr('animals'),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          lang.tr('choose_pet'),
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text(lang.tr('more'), style: TextStyle(color: Colors.grey.shade700)),
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
                  (_, i) => _buildCategoryCard(context, AppCategories.animals[i], lang),
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
                        Text(
                          lang.tr('products'),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          lang.tr('for_pets'),
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text(lang.tr('more'), style: TextStyle(color: Colors.grey.shade700)),
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
                  (_, i) => _buildCategoryCard(context, AppCategories.accessories[i], lang),
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

  String _getCategoryName(Category c, LanguageProvider lang) {
    switch (c.id) {
      case 'cats': return lang.tr('cats');
      case 'dogs': return lang.tr('dogs');
      case 'birds': return lang.tr('birds');
      case 'horses': return lang.tr('horses');
      case 'fish': return lang.tr('fish');
      case 'rodents': return lang.tr('rodents');
      case 'reptiles': return lang.tr('reptiles');
      case 'food': return lang.tr('food');
      case 'toys': return lang.tr('toys');
      case 'cages': return lang.tr('cages');
      default: return c.name;
    }
  }

  Widget _buildCategoryCard(BuildContext context, Category c, LanguageProvider lang) {
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
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            // Title at top
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
              child: Text(
                _getCategoryName(c, lang),
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: c.imagePath != null
                        ? (c.id == 'horses'
                            ? FittedBox(
                                fit: BoxFit.contain,
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  c.imagePath!,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(c.icon, style: const TextStyle(fontSize: 36)),
                                  ),
                                ),
                              )
                            : Image.asset(
                                c.imagePath!,
                                fit: c.id == 'fish' ? BoxFit.contain : BoxFit.cover,
                                alignment: Alignment.center,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(c.icon, style: const TextStyle(fontSize: 36)),
                                ),
                              ))
                        : networkImageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: networkImageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (_, __) => Center(
                                  child: Text(c.icon, style: const TextStyle(fontSize: 36)),
                                ),
                                errorWidget: (_, __, ___) => Center(
                                  child: Text(c.icon, style: const TextStyle(fontSize: 36)),
                                ),
                              )
                            : Center(
                                child: Text(c.icon, style: const TextStyle(fontSize: 36)),
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
