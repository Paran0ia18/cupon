import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/models/coupon.dart';
import 'package:flutter/material.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
    required this.coupon,
    required this.isRedeemed,
    required this.onRedeem,
    this.onShare,
  });

  final Coupon coupon;
  final bool isRedeemed;
  final VoidCallback onRedeem;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFromCoupon(coupon);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: accent,
        collapsedIconColor: accent,
        leading: Icon(Icons.local_offer_rounded, color: accent),
        title: Text(
          coupon.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          coupon.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        children: [
          _InfoRow(label: 'Terminos', value: coupon.terms),
          const SizedBox(height: 6),
          _InfoRow(label: 'Valido hasta', value: coupon.validUntilLabel),
          const SizedBox(height: 6),
          _InfoRow(label: 'Codigo', value: coupon.code),
          const SizedBox(height: 12),
          if (onShare != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Share'),
              ),
            ),
          const SizedBox(height: 14),
          AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            scale: isRedeemed ? 0.98 : 1,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isRedeemed ? null : onRedeem,
                icon: Icon(
                  isRedeemed ? Icons.check_circle : Icons.flash_on_rounded,
                  color: Colors.white,
                ),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    isRedeemed ? 'Redeemed' : 'Redeem Now',
                    key: ValueKey<bool>(isRedeemed),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: isRedeemed ? AppColors.redeemed : AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _accentFromCoupon(Coupon coupon) {
    final options = <Color>[
      AppColors.primary,
      AppColors.secondary,
      AppColors.info,
      AppColors.success,
      AppColors.violet,
      AppColors.rose,
    ];
    final seed = coupon.code.runes.fold<int>(0, (sum, rune) => sum + rune);
    return options[seed % options.length];
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '$label: ',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

