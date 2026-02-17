import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/models/brand.dart';
import 'package:cupon/models/coupon.dart';
import 'package:cupon/services/local_discovery_service.dart';
import 'package:cupon/services/redeem_store.dart';
import 'package:cupon/widgets/coupon_card.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BrandDetailScreen extends StatelessWidget {
  const BrandDetailScreen({
    super.key,
    required this.brand,
    required this.redeemStore,
  });

  final Brand brand;
  final RedeemStore redeemStore;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromName(brand.name);
    final area = LocalDiscoveryService.areas[1];
    final distance = LocalDiscoveryService.distanceKm(brand, area);
    final accent = LocalDiscoveryService.accentForCategory(brand.category);

    return Scaffold(
      appBar: AppBar(title: Text(brand.name)),
      body: AnimatedBuilder(
        animation: redeemStore,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'FEATURED LOCAL BRAND',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            brand.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 19,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            brand.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Approx. ${distance.toStringAsFixed(1)} km from $area',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                brand.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoftBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contacto',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _launchAddress(context, brand.contact.address),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              brand.contact.address,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _launchPhone(context, brand.contact.phone),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            brand.contact.phone,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (brand.website.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchWebsite(context, brand.website),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.language_rounded,
                              color: AppColors.violet,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                brand.website,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.violet,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Available Coupons',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...brand.coupons.map(
                (coupon) => CouponCard(
                  coupon: coupon,
                  isRedeemed: redeemStore.isRedeemed(brand, coupon),
                  onRedeem: () => _confirmRedeem(context, coupon),
                  onShare: () => _shareCoupon(coupon),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmRedeem(BuildContext context, Coupon coupon) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm redemption'),
          content: Text(
            'Quieres redimir "${coupon.title}" con codigo ${coupon.code}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Redeem'),
            ),
          ],
        );
      },
    );

    if (accepted != true) {
      return;
    }

    await redeemStore.redeem(brand, coupon);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cupon redimido: ${coupon.code}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _launchAddress(BuildContext context, String address) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      if (!context.mounted) {
        return;
      }
      _showLaunchError(context);
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final launched = await launchUrl(uri);
    if (!launched) {
      if (!context.mounted) {
        return;
      }
      _showLaunchError(context);
    }
  }

  Future<void> _launchWebsite(BuildContext context, String website) async {
    final uri = Uri.tryParse(website);
    if (uri == null) {
      _showLaunchError(context);
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      if (!context.mounted) {
        return;
      }
      _showLaunchError(context);
    }
  }

  Future<void> _shareCoupon(Coupon coupon) async {
    final message =
        'Check this deal on Kurukshetra Local Dealz:\n${brand.name}\n${coupon.title}\nCode: ${coupon.code}\nValid till: ${coupon.validUntilLabel}';
    await Share.share(message);
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo abrir el enlace en este dispositivo.'),
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name.split(' ').where((part) => part.isNotEmpty).take(2);
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}
