import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/models/brand.dart';
import 'package:cupon/services/local_discovery_service.dart';
import 'package:cupon/widgets/brand_card.dart';
import 'package:cupon/widgets/category_chip.dart';
import 'package:cupon/widgets/skeleton_brand_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.brands,
    required this.onBrandTap,
  });

  final List<Brand> brands;
  final ValueChanged<Brand> onBrandTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _allCategory = 'All';
  static const int _initialChunk = 12;
  static const int _nextChunk = 8;

  final ScrollController _scrollController = ScrollController();
  late String _selectedCategory;
  late String _selectedArea;
  bool _prioritizeNearby = true;
  int _visibleCount = _initialChunk;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _allCategory;
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

  List<Brand> get _baseFilteredBrands => _selectedCategory == _allCategory
      ? widget.brands
      : widget.brands
          .where((brand) => brand.category == _selectedCategory)
          .toList(growable: false);

  List<Brand> get _orderedBrands {
    final base = _baseFilteredBrands;
    if (!_prioritizeNearby) {
      return base;
    }
    return LocalDiscoveryService.sortByDistance(base, _selectedArea);
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
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 260;
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
    final categories = <String>{
      _allCategory,
      ...widget.brands.map((brand) => brand.category),
    }.toList();

    final featuredBrands = widget.brands.take(6).toList(growable: false);
    final heroBrand = featuredBrands.isNotEmpty ? featuredBrands.first : null;
    final nearbyPicks =
        LocalDiscoveryService.sortByDistance(widget.brands, _selectedArea).take(8).toList();
    final orderedBrands = _orderedBrands;
    final visibleBrands = orderedBrands.take(_visibleCount).toList(growable: false);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heroBrand != null)
            _HeroSection(
              brand: heroBrand,
              onTap: () => widget.onBrandTap(heroBrand),
            ),
          Container(
            color: AppColors.surfaceSoftNeutral,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LocationPanel(
                        selectedArea: _selectedArea,
                        prioritizeNearby: _prioritizeNearby,
                        onAreaChanged: (value) {
                          setState(() {
                            _selectedArea = value;
                            _resetVisibleCount();
                          });
                        },
                        onPrioritizeChanged: (value) {
                          setState(() {
                            _prioritizeNearby = value;
                            _resetVisibleCount();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      const _PushPreviewCard(),
                      const SizedBox(height: 18),
                      _NearbyMapMock(
                        area: _selectedArea,
                        nearbyPicks: nearbyPicks,
                        onBrandTap: widget.onBrandTap,
                      ),
                      const SizedBox(height: 14),
                      _SectionBlock(
                        background: AppColors.surfaceSoftBlue,
                        title: 'Nearby Picks',
                        child: SizedBox(
                          height: 206,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: nearbyPicks.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final brand = nearbyPicks[index];
                              final km = LocalDiscoveryService.distanceKm(brand, _selectedArea);
                              return BrandCard(
                                brand: brand,
                                compact: true,
                                metaText: '${km.toStringAsFixed(1)} km',
                                accentColor:
                                    LocalDiscoveryService.accentForCategory(brand.category),
                                onTap: () => widget.onBrandTap(brand),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionBlock(
                        background: AppColors.surfaceSoftOrange,
                        title: 'Featured Brands',
                        child: SizedBox(
                          height: 188,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: featuredBrands.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final brand = featuredBrands[index];
                              return BrandCard(
                                brand: brand,
                                compact: true,
                                accentColor:
                                    LocalDiscoveryService.accentForCategory(brand.category),
                                onTap: () => widget.onBrandTap(brand),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _HowItWorksStrip(),
                      const SizedBox(height: 14),
                      const _SectionTitle(title: 'Categories'),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories
                              .map(
                                (category) => CategoryChip(
                                  label: category,
                                  isSelected: _selectedCategory == category,
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                      _resetVisibleCount();
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionBlock(
                        background: Colors.white,
                        title: 'All Brands (${orderedBrands.length})',
                        child: Column(
                          children: [
                            ...visibleBrands.map(
                              (brand) {
                                final km = LocalDiscoveryService.distanceKm(brand, _selectedArea);
                                return BrandCard(
                                  brand: brand,
                                  metaText: '${km.toStringAsFixed(1)} km away',
                                  accentColor:
                                      LocalDiscoveryService.accentForCategory(brand.category),
                                  onTap: () => widget.onBrandTap(brand),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_visibleCount < orderedBrands.length)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                          child: Column(
                            children: [
                              SkeletonBrandCard(),
                              SkeletonBrandCard(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPanel extends StatelessWidget {
  const _LocationPanel({
    required this.selectedArea,
    required this.prioritizeNearby,
    required this.onAreaChanged,
    required this.onPrioritizeChanged,
  });

  final String selectedArea;
  final bool prioritizeNearby;
  final ValueChanged<String> onAreaChanged;
  final ValueChanged<bool> onPrioritizeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoftBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.near_me_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Location Smart Sorting',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedArea,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: LocalDiscoveryService.areas
                      .map(
                        (area) => DropdownMenuItem<String>(
                          value: area,
                          child: Text(area),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    onAreaChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              FilterChip(
                selected: prioritizeNearby,
                label: const Text('Near me'),
                onSelected: onPrioritizeChanged,
                selectedColor: AppColors.success.withValues(alpha: 0.18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.brand,
    required this.onTap,
  });

  final Brand brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 760;
    final heroHeight = isMobile ? 360.0 : 470.0;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1579165466991-467135ad3110?auto=format&fit=crop&w=1800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFFE8EEF7));
            },
          ),
          Container(color: Colors.black.withValues(alpha: 0.4)),
          Positioned(
            top: 22,
            left: 22,
            child: Row(
              children: List.generate(
                9,
                (index) => Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: isMobile ? 22 : null,
            bottom: 24,
            child: Container(
              width: isMobile ? null : 650,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    brand.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 28 : 54,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    brand.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    brand.category,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${brand.contact.phone}  |  ${brand.contact.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 13 : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 20),
                      label: const Text(
                        'View Coupons',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _PushPreviewCard extends StatelessWidget {
  const _PushPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoftOrange,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: AppColors.warning),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Preview',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'New deal alert: Flat INR 250 off is live near you!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyMapMock extends StatefulWidget {
  const _NearbyMapMock({
    required this.area,
    required this.nearbyPicks,
    required this.onBrandTap,
  });

  final String area;
  final List<Brand> nearbyPicks;
  final ValueChanged<Brand> onBrandTap;

  @override
  State<_NearbyMapMock> createState() => _NearbyMapMockState();
}

class _NearbyMapMockState extends State<_NearbyMapMock> {
  bool _showMap = true;

  Future<void> _openInMaps(Brand brand) async {
    final rawAddress = brand.contact.address.trim();
    final query = rawAddress.isEmpty ? '${brand.name}, ${widget.area}' : rawAddress;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final topBrands = widget.nearbyPicks.take(3).toList(growable: false);
    final isCompact = MediaQuery.sizeOf(context).width < 560;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map_rounded, color: AppColors.info),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nearby Discovery - ${widget.area}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _MapModeToggle(
                showMap: _showMap,
                onChanged: (value) => setState(() => _showMap = value),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _showMap
                ? _NearbyMapCanvas(
                    key: const ValueKey<String>('map'),
                    area: widget.area,
                    brands: topBrands,
                    compact: isCompact,
                    onBrandTap: widget.onBrandTap,
                    onOpenMaps: _openInMaps,
                  )
                : _NearbyListPanel(
                    key: const ValueKey<String>('list'),
                    area: widget.area,
                    brands: topBrands,
                    onBrandTap: widget.onBrandTap,
                    onOpenMaps: _openInMaps,
                  ),
          ),
        ],
      ),
    );
  }
}

class _MapModeToggle extends StatelessWidget {
  const _MapModeToggle({
    required this.showMap,
    required this.onChanged,
  });

  final bool showMap;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoftNeutral,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Row(
        children: [
          _ToggleButton(
            label: 'Map',
            icon: Icons.map_rounded,
            active: showMap,
            onTap: () => onChanged(true),
          ),
          _ToggleButton(
            label: 'List',
            icon: Icons.view_list_rounded,
            active: !showMap,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyMapCanvas extends StatelessWidget {
  const _NearbyMapCanvas({
    super.key,
    required this.area,
    required this.brands,
    required this.compact,
    required this.onBrandTap,
    required this.onOpenMaps,
  });

  final String area;
  final List<Brand> brands;
  final bool compact;
  final ValueChanged<Brand> onBrandTap;
  final ValueChanged<Brand> onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final positions = compact
        ? const <Offset>[Offset(0.14, 0.24), Offset(0.55, 0.40), Offset(0.30, 0.68)]
        : const <Offset>[Offset(0.18, 0.22), Offset(0.62, 0.36), Offset(0.36, 0.68)];

    return SizedBox(
      key: key,
      height: compact ? 210 : 238,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=1400&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColors.surfaceSoftBlue);
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.58),
                  ],
                ),
              ),
            ),
            ...List.generate(
              brands.length,
              (index) {
                final brand = brands[index];
                final distance = LocalDiscoveryService.distanceKm(brand, area);
                final offset = positions[index % positions.length];
                return Positioned(
                  left: offset.dx * (compact ? 300 : 430),
                  top: offset.dy * (compact ? 170 : 190),
                  child: InkWell(
                    onTap: () => onBrandTap(brand),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.info.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Top nearby picks ready to redeem now.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: brands.isEmpty ? null : () => onOpenMaps(brands.first),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Open in Maps'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyListPanel extends StatelessWidget {
  const _NearbyListPanel({
    super.key,
    required this.area,
    required this.brands,
    required this.onBrandTap,
    required this.onOpenMaps,
  });

  final String area;
  final List<Brand> brands;
  final ValueChanged<Brand> onBrandTap;
  final ValueChanged<Brand> onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: brands
          .map(
            (brand) {
              final km = LocalDiscoveryService.distanceKm(brand, area);
              final accent = LocalDiscoveryService.accentForCategory(brand.category);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.dividerSoft),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.storefront_rounded, color: accent, size: 18),
                  ),
                  title: Text(
                    brand.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${km.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Open in Maps',
                        onPressed: () => onOpenMaps(brand),
                        icon: const Icon(Icons.map_outlined, color: AppColors.info),
                      ),
                      const SizedBox(width: 2),
                      ElevatedButton(
                        onPressed: () => onBrandTap(brand),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(74, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
          .toList(growable: false),
    );
  }
}

class _HowItWorksStrip extends StatelessWidget {
  const _HowItWorksStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _StepTile(
              icon: Icons.search_rounded,
              title: 'Discover',
              subtitle: 'Find nearby brands',
              accent: AppColors.info,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _StepTile(
              icon: Icons.local_offer_rounded,
              title: 'Redeem',
              subtitle: 'Use one-time coupon',
              accent: AppColors.secondary,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _StepTile(
              icon: Icons.verified_rounded,
              title: 'Track',
              subtitle: 'See history in profile',
              accent: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.background,
    required this.title,
    required this.child,
  });

  final Color background;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
