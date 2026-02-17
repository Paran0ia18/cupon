import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/models/brand.dart';
import 'package:cupon/services/local_discovery_service.dart';
import 'package:cupon/widgets/brand_card.dart';
import 'package:cupon/widgets/skeleton_brand_card.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.brands,
    required this.onBrandTap,
  });

  final List<Brand> brands;
  final ValueChanged<Brand> onBrandTap;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const int _initialChunk = 12;
  static const int _nextChunk = 8;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _query = '';
  String _selectedArea = LocalDiscoveryService.areas.first;
  bool _prioritizeNearby = true;
  int _visibleCount = _initialChunk;

  List<Brand> get _filteredBrands {
    final textFiltered = _query.isEmpty
        ? widget.brands
        : widget.brands
            .where(
              (brand) => brand.name.toLowerCase().contains(_query) ||
                  brand.category.toLowerCase().contains(_query),
            )
            .toList(growable: false);

    if (!_prioritizeNearby) {
      return textFiltered;
    }
    return LocalDiscoveryService.sortByDistance(textFiltered, _selectedArea);
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _resetVisibleCount();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text.trim().toLowerCase();
      _resetVisibleCount();
    });
  }

  void _resetVisibleCount() {
    final total = _filteredBrands.length;
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
    final total = _filteredBrands.length;
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
    final filtered = _filteredBrands;
    final visible = filtered.take(_visibleCount).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by business name or category...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoftBlue,
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
                        horizontal: 12,
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
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.travel_explore_rounded,
                          size: 44,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No results for "${_searchController.text}"',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: visible.length + (_visibleCount < filtered.length ? 1 : 0),
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
