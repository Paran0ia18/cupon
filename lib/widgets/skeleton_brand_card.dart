import 'package:cupon/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SkeletonBrandCard extends StatefulWidget {
  const SkeletonBrandCard({super.key});

  @override
  State<SkeletonBrandCard> createState() => _SkeletonBrandCardState();
}

class _SkeletonBrandCardState extends State<SkeletonBrandCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.42 + (_controller.value * 0.38);
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerSoft),
        ),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              _Block(width: 52, height: 52, radius: 14),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Block(width: 170, height: 14, radius: 8),
                    SizedBox(height: 8),
                    _Block(width: double.infinity, height: 10, radius: 6),
                    SizedBox(height: 6),
                    _Block(width: 120, height: 10, radius: 6),
                    SizedBox(height: 10),
                    _Block(width: 86, height: 24, radius: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoftBlue,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
