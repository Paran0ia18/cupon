import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/models/brand.dart';
import 'package:cupon/models/coupon.dart';
import 'package:cupon/services/redeem_store.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.redeemStore,
    required this.phone,
    required this.brands,
    required this.onLogout,
    required this.onOpenAdminPreview,
  });

  final RedeemStore redeemStore;
  final String phone;
  final List<Brand> brands;
  final Future<void> Function() onLogout;
  final VoidCallback onOpenAdminPreview;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: redeemStore,
      builder: (context, child) {
        final redeemed = redeemStore.records;
        final allCoupons = _flattenCoupons(brands);
        final redeemedKeys = redeemed.map((item) => item.key).toSet();
        final activeCoupons = allCoupons
            .where((entry) => !redeemedKeys.contains(_recordKey(entry.brand, entry.coupon)))
            .take(20)
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          children: [
            _ProfileHeader(
              phone: phone,
              onLogout: onLogout,
            ),
            const SizedBox(height: 14),
            _AnalyticsStrip(
              redeemedCount: redeemed.length,
              activeCount: activeCoupons.length,
              totalCount: allCoupons.length,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoftBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.dividerSoft),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.violet.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.violet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Admin panel and analytics preview for pitch demo.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onOpenAdminPreview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violet,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Open'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Active Coupons',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            if (activeCoupons.isEmpty)
              const _EmptyState(
                icon: Icons.bolt_rounded,
                title: 'No active coupons right now',
                subtitle: 'Use search to discover new deals.',
              )
            else
              ...activeCoupons.map(
                (entry) => _CouponItem(
                  title: entry.coupon.title,
                  subtitle:
                      '${entry.brand.name} - ${entry.coupon.code} - Valid till ${entry.coupon.validUntilLabel}',
                  icon: Icons.flash_on_rounded,
                  accent: AppColors.success,
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Redeemed Coupons',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            if (redeemed.isEmpty)
              const _EmptyState(
                icon: Icons.verified_outlined,
                title: 'No redeemed coupons yet',
                subtitle: 'Redeem coupons and track them here.',
              )
            else
              ...redeemed.map(
                (item) => _CouponItem(
                  title: item.couponTitle,
                  subtitle:
                      '${item.brandName} - ${item.couponCode} - ${_formatDate(item.redeemedAt)}',
                  icon: Icons.check_circle_rounded,
                  accent: AppColors.secondary,
                ),
              ),
          ],
        );
      },
    );
  }

  List<_BrandCouponPair> _flattenCoupons(List<Brand> brands) {
    final pairs = <_BrandCouponPair>[];
    for (final brand in brands) {
      for (final coupon in brand.coupons) {
        pairs.add(_BrandCouponPair(brand: brand, coupon: coupon));
      }
    }
    return pairs;
  }

  String _recordKey(Brand brand, Coupon coupon) {
    return '${brand.name.toLowerCase().trim()}::${coupon.code}';
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.phone,
    required this.onLogout,
  });

  final String phone;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoftBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo User',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone.isEmpty ? 'No phone saved' : phone,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              await onLogout();
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out')),
              );
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsStrip extends StatelessWidget {
  const _AnalyticsStrip({
    required this.redeemedCount,
    required this.activeCount,
    required this.totalCount,
  });

  final int redeemedCount;
  final int activeCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Redeemed',
            value: '$redeemedCount',
            accent: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Active',
            value: '$activeCount',
            accent: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Total',
            value: '$totalCount',
            accent: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponItem extends StatelessWidget {
  const _CouponItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoftBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        children: [
          Icon(icon, size: 52, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _BrandCouponPair {
  const _BrandCouponPair({required this.brand, required this.coupon});

  final Brand brand;
  final Coupon coupon;
}

