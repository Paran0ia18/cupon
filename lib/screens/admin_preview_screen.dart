import 'package:cupon/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AdminPreviewScreen extends StatelessWidget {
  const AdminPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Preview (Demo)')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoftBlue,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dividerSoft),
            ),
            child: const Text(
              'Visual mock of admin panel. No backend actions are performed.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _AdminStatsRow(),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Brands Management',
            icon: Icons.storefront_rounded,
            accent: AppColors.violet,
            items: const [
              'Add / edit / disable businesses',
              'Set featured brands for homepage',
              'Update contact and location details',
            ],
          ),
          _SectionCard(
            title: 'Coupons Management',
            icon: Icons.local_offer_rounded,
            accent: AppColors.secondary,
            items: const [
              'Create and update coupon offers',
              'Set expiry and one-time redemption rules',
              'Enable / disable individual coupons',
            ],
          ),
          _SectionCard(
            title: 'Push & Analytics',
            icon: Icons.campaign_rounded,
            accent: AppColors.info,
            items: const [
              'Trigger new deal notifications',
              'Track daily redemptions and top brands',
              'Export campaign summary report',
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminStatsRow extends StatelessWidget {
  const _AdminStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _AdminStat(
            label: 'Total Brands',
            value: '60',
            accent: AppColors.primary,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _AdminStat(
            label: 'Active Coupons',
            value: '300',
            accent: AppColors.success,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _AdminStat(
            label: 'Today Redeems',
            value: '48',
            accent: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _AdminStat extends StatelessWidget {
  const _AdminStat({
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
              fontSize: 20,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle, size: 8, color: accent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
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
