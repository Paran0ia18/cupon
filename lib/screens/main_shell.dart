import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/models/brand.dart';
import 'package:cupon/screens/brand_detail_screen.dart';
import 'package:cupon/screens/admin_preview_screen.dart';
import 'package:cupon/screens/categories_screen.dart';
import 'package:cupon/screens/home_screen.dart';
import 'package:cupon/screens/profile_screen.dart';
import 'package:cupon/screens/search_screen.dart';
import 'package:cupon/services/auth_store.dart';
import 'package:cupon/services/redeem_store.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.brands,
    required this.redeemStore,
    required this.authStore,
  });

  final List<Brand> brands;
  final RedeemStore redeemStore;
  final AuthStore authStore;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 900;
    final isMedium = screenWidth >= 620;
    final isCompact = screenWidth < 420;

    final pages = [
      HomeScreen(brands: widget.brands, onBrandTap: _openBrandDetail),
      CategoriesScreen(brands: widget.brands, onBrandTap: _openBrandDetail),
      SearchScreen(brands: widget.brands, onBrandTap: _openBrandDetail),
      ProfileScreen(
        redeemStore: widget.redeemStore,
        phone: widget.authStore.phone,
        brands: widget.brands,
        onLogout: widget.authStore.logout,
        onOpenAdminPreview: _openAdminPreview,
      ),
    ];

    final tabMeta = <_TabMeta>[
      const _TabMeta(
        title: 'Kurukshetra Local Dealz',
        subtitle: 'Explore featured and nearby businesses',
        icon: Icons.home_rounded,
        accent: AppColors.primary,
      ),
      const _TabMeta(
        title: 'Categories',
        subtitle: 'Browse businesses by category and area',
        icon: Icons.grid_view_rounded,
        accent: AppColors.violet,
      ),
      const _TabMeta(
        title: 'Search Deals',
        subtitle: 'Find brands, offers and nearby results',
        icon: Icons.search_rounded,
        accent: AppColors.info,
      ),
      const _TabMeta(
        title: 'My Profile',
        subtitle: 'Track redeemed coupons and account info',
        icon: Icons.person_rounded,
        accent: AppColors.success,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceSoftNeutral,
      body: Column(
        children: [
          if (_selectedIndex == 0) ...[
            _buildHomeHeader(
              isWide: isWide,
              isMedium: isMedium,
              isCompact: isCompact,
            ),
          ] else ...[
            _buildContextHeader(tabMeta[_selectedIndex]),
          ],
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: pages),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.dividerSoft),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 72,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            indicatorColor: tabMeta[_selectedIndex].accent.withValues(alpha: 0.18),
            onDestinationSelected: (value) => setState(() => _selectedIndex = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBrandDetail(Brand brand) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrandDetailScreen(
          brand: brand,
          redeemStore: widget.redeemStore,
        ),
      ),
    );
  }

  void _openAdminPreview() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminPreviewScreen(),
      ),
    );
  }

  Widget _buildHomeHeader({
    required bool isWide,
    required bool isMedium,
    required bool isCompact,
  }) {
    return Column(
      children: [
        Container(
          height: isCompact ? 54 : 44,
          width: double.infinity,
          color: AppColors.warning,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Buy Your Book Now & Get 65% Off! Delivery Available At Your Doorstep Now!',
            textAlign: TextAlign.center,
            maxLines: isCompact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isCompact ? 13 : 15,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: AppColors.surfaceSoftBlue,
          foregroundDecoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.dividerSoft),
            ),
          ),
          padding: EdgeInsets.fromLTRB(12, isCompact ? 10 : 12, 12, 10),
          child: isWide
              ? Row(
                  children: [
                    _buildLogoPill(fontSize: 12),
                    const SizedBox(width: 20),
                    _NavItem(
                      label: 'Our Happy Clients',
                      onTap: () => setState(() => _selectedIndex = 0),
                    ),
                    _NavItem(
                      label: 'Businesses Inside The Book',
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                    _NavItem(
                      label: 'Brand Stories',
                      onTap: () => setState(() => _selectedIndex = 0),
                    ),
                    _NavItem(
                      label: 'Contact',
                      onTap: () => setState(() => _selectedIndex = 3),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, color: AppColors.primary),
                      onPressed: () => setState(() => _selectedIndex = 2),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _selectedIndex = 1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Text(
                          'Buy Your Book Now',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                )
              : isMedium
                  ? Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildLogoPill(fontSize: 11),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: AppColors.primary),
                          onPressed: () => setState(() => _selectedIndex = 2),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _selectedIndex = 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Buy Now',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildLogoPill(fontSize: 10),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              onPressed: () => setState(() => _selectedIndex = 2),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.grid_view_rounded,
                                color: AppColors.primary,
                              ),
                              onPressed: () => setState(() => _selectedIndex = 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _selectedIndex = 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Buy Your Book Now',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildContextHeader(_TabMeta meta) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dividerSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: meta.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, color: meta.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta.subtitle,
                  style: const TextStyle(
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

  Widget _buildLogoPill({required double fontSize}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.45)),
      ),
      child: Text(
        'KURUKSHETRA LOCAL DEALZ',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _TabMeta {
  const _TabMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

