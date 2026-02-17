import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/models/brand.dart';
import 'package:cupon/services/local_discovery_service.dart';
import 'package:cupon/widgets/brand_card.dart';
import 'package:cupon/widgets/skeleton_brand_card.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    required this.brands,
    required this.onBrandTap,
  });

  final List<Brand> brands;
  final ValueChanged<Brand> onBrandTap;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const int _initialChunk = 12;
  static const int _nextChunk = 8;

  final ScrollController _scrollController = ScrollController();
  late String _selectedCategory;
  late String _selectedArea;
  bool _prioritizeNearby = true;
  int _visibleCount = _initialChunk;

  List<String> get _categories =>
      widget.brands.map((brand) => brand.category).toSet().toList()..sort();

  List<Brand> get _baseFilteredBrands => widget.brands
      .where((brand) => brand.category == _selectedCategory)
      .toList(growable: false);

  List<Brand> get _orderedBrands => _prioritizeNearby
      ? LocalDiscoveryService.sortByDistance(_baseFilteredBrands, _selectedArea)
      : _baseFilteredBrands;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.isEmpty ? 'General' : _categories.first;
    _selectedArea = LocalDiscoveryService.areas.first;
    _resetVisibleCount();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _resetVisibleCount() {
    final total = _orderedBrands.length;
    _visibleCount = total < _initialChunk ? total : _initialChunk;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final nearBottom =
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 220;
    if (!nearBottom) {
      return;
    }
    final total = _orderedBrands.length;
    if (_visibleCount >= total) {
      return;
    }
    setState(() {
      final next = _visibleCount + _nextChunk;
      _visibleCount = next > total ? total : next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories;
    final currentCategory =
        categories.contains(_selectedCategory) ? _selectedCategory : null;
    final ordered = _orderedBrands;
    final visible = ordered.take(_visibleCount).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore by Category',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey<String?>(currentCategory),
            initialValue: currentCategory,
            isExpanded: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            items: categories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: categories.isEmpty
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedCategory = value;
                      _resetVisibleCount();
                    });
                  },
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoftOrange,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dividerSoft),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey<String>(_selectedArea),
                    initialValue: _selectedArea,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items: LocalDiscoveryService.areas
                        .map(
                          (area) => DropdownMenuItem<String>(
                            value: area,
                            child: Text(area),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedArea = value;
                        _resetVisibleCount();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  selected: _prioritizeNearby,
                  label: const Text('Near me'),
                  selectedColor: AppColors.success.withValues(alpha: 0.18),
                  onSelected: (value) {
                    setState(() {
                      _prioritizeNearby = value;
                      _resetVisibleCount();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Brands in $_selectedCategory (${ordered.length})',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: visible.length + (_visibleCount < ordered.length ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= visible.length) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 6, bottom: 14),
                    child: SkeletonBrandCard(),
                  );
                }
                final brand = visible[index];
                final km = LocalDiscoveryService.distanceKm(brand, _selectedArea);
                return BrandCard(
                  brand: brand,
                  metaText: '${km.toStringAsFixed(1)} km',
                  accentColor: LocalDiscoveryService.accentForCategory(brand.category),
                  onTap: () => widget.onBrandTap(brand),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
