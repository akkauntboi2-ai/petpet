import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/sample_data.dart';
import '../providers/favorites_provider.dart';
import '../providers/language_provider.dart';
import '../providers/ads_provider.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = true;
  String _sortBy = 'newest';
  String? _selectedCity;
  RangeValues _priceRange = const RangeValues(0, 10000000);
  bool _isRefreshing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Provider.of<AdsProvider>(context, listen: false).refresh();
    setState(() => _isRefreshing = false);
  }

  String _getCategoryName(LanguageProvider langProvider) {
    switch (widget.category.id) {
      case 'cats': return langProvider.tr('cats');
      case 'dogs': return langProvider.tr('dogs');
      case 'birds': return langProvider.tr('birds');
      case 'horses': return langProvider.tr('horses');
      case 'fish': return langProvider.tr('fish');
      case 'rodents': return langProvider.tr('rodents');
      case 'reptiles': return langProvider.tr('reptiles');
      case 'insects': return langProvider.tr('insects');
      case 'wild': return langProvider.tr('wild');
      default: return widget.category.name;
    }
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
               (p.breed?.toLowerCase().contains(query) ?? false) ||
               (p.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // City filter
    if (_selectedCity != null) {
      filtered = filtered.where((p) => p.city == _selectedCity).toList();
    }

    // Price filter
    filtered = filtered.where((p) {
      return p.price >= _priceRange.start && p.price <= _priceRange.end;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
      default:
        // Keep original order (newest first)
        break;
    }

    return filtered;
  }

  void _showFilterSheet(BuildContext context, LanguageProvider lang) {
    
    final cities = ['Ташкент', 'Самарканд', 'Бухара', 'Наманган', 'Андижан', 'Фергана'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                lang.tr('filter'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Sort
              Text(lang.tr('sort_by'), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(lang.tr('newest'), _sortBy == 'newest', () {
                    setModalState(() => _sortBy = 'newest');
                  }),
                  _buildFilterChip(lang.tr('price_low_high'), _sortBy == 'price_low', () {
                    setModalState(() => _sortBy = 'price_low');
                  }),
                  _buildFilterChip(lang.tr('price_high_low'), _sortBy == 'price_high', () {
                    setModalState(() => _sortBy = 'price_high');
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // City
              Text(lang.tr('city'), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(lang.tr('all'), _selectedCity == null, () {
                    setModalState(() => _selectedCity = null);
                  }),
                  ...cities.map((city) => _buildFilterChip(city, _selectedCity == city, () {
                    setModalState(() => _selectedCity = city);
                  })),
                ],
              ),
              const SizedBox(height: 20),

              // Price range
              Text(lang.tr('price'), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
              const SizedBox(height: 10),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 10000000,
                divisions: 100,
                activeColor: AppTheme.primary,
                labels: RangeLabels(
                  '${(_priceRange.start / 1000).toStringAsFixed(0)}K',
                  '${(_priceRange.end / 1000).toStringAsFixed(0)}K',
                ),
                onChanged: (values) {
                  setModalState(() => _priceRange = values);
                },
              ),
              Text(
                '${(_priceRange.start / 1000).toStringAsFixed(0)}K - ${(_priceRange.end / 1000).toStringAsFixed(0)}K сум',
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const Spacer(),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _sortBy = 'newest';
                          _selectedCity = null;
                          _priceRange = const RangeValues(0, 10000000);
                        });
                      },
                      child: Text(lang.tr('reset')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: Text(lang.tr('apply')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : (Colors.grey.shade100),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: selected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : (Colors.black87),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final adsProvider = Provider.of<AdsProvider>(context);

    // Combine server ads and sample data, filter by category
    final serverAds = adsProvider.allAds.where((ad) => ad.categoryId == widget.category.id).toList();
    final sampleProducts = SampleData.byCategory(widget.category.id);
    final allProducts = [...serverAds, ...sampleProducts];
    final products = _filterProducts(allProducts);

    final hasActiveFilters = _selectedCity != null ||
        _sortBy != 'newest' ||
        _priceRange.start > 0 ||
        _priceRange.end < 10000000;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getCategoryName(langProvider),
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          // Grid/List toggle
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.grey.shade600,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? langProvider.tr('view_list') : langProvider.tr('view_grid'),
          ),
          // Filter button
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.tune,
                  color: Colors.grey.shade600,
                ),
                onPressed: () => _showFilterSheet(context, langProvider),
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '${langProvider.tr('search')}...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Products
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.category.icon, style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || hasActiveFilters
                              ? langProvider.tr('nothing_found')
                              : langProvider.tr('no_ads'),
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: AppTheme.primary,
                    child: _isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: products.length,
                            itemBuilder: (_, i) => _buildProductCard(context, products[i]),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: products.length,
                            itemBuilder: (_, i) => _buildListProductCard(context, products[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListProductCard(BuildContext context, Product product) {
    
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
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppTheme.radiusMedium)),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (product.isTop)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('TOP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            Expanded(
                              child: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (product.city != null)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 2),
                              Text(product.city!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.priceText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => favorites.toggleFavorite(product),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_outline,
                                size: 22,
                                color: isFav ? AppTheme.favorite : (Colors.grey.shade400),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMedium)),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        ),
                      ),
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
                              borderRadius: BorderRadius.circular(4),
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
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => favorites.toggleFavorite(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
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
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.2,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          product.priceText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.primary,
                          ),
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
}
