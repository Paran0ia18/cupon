import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/models/brand.dart';
import 'package:flutter/material.dart';

class LocalDiscoveryService {
  static const List<String> areas = <String>[
    'Sector 7',
    'Sector 10',
    'Sector 17',
    'Pipli Road',
    'Railway Road',
    'Amin Road',
    'DD Colony',
    'Near University',
  ];

  const LocalDiscoveryService._();

  static double distanceKm(Brand brand, String area) {
    final address = brand.contact.address.toLowerCase();
    final needle = area.toLowerCase();
    if (address.contains(needle)) {
      final matchedSeed = _stableSeed('${brand.name}|$area');
      return 0.8 + (matchedSeed % 17) / 10.0;
    }

    final fallbackSeed = _stableSeed('${brand.name}|${brand.category}|$area');
    return 2.6 + (fallbackSeed % 96) / 10.0;
  }

  static List<Brand> sortByDistance(
    List<Brand> brands,
    String area,
  ) {
    final sorted = List<Brand>.from(brands);
    sorted.sort((a, b) => distanceKm(a, area).compareTo(distanceKm(b, area)));
    return sorted;
  }

  static Color accentForCategory(String category) {
    final token = category.toLowerCase();
    if (token.contains('salon') || token.contains('beauty')) {
      return AppColors.rose;
    }
    if (token.contains('food') ||
        token.contains('restaurant') ||
        token.contains('cafe') ||
        token.contains('bakery')) {
      return AppColors.secondary;
    }
    if (token.contains('health') || token.contains('lab')) {
      return AppColors.info;
    }
    if (token.contains('gym') || token.contains('fitness')) {
      return AppColors.success;
    }
    if (token.contains('fashion') ||
        token.contains('clothing') ||
        token.contains('cosmetic') ||
        token.contains('accessories')) {
      return AppColors.violet;
    }
    if (token.contains('travel') ||
        token.contains('tour') ||
        token.contains('insurance') ||
        token.contains('consult')) {
      return AppColors.warning;
    }
    if (token.contains('digital') ||
        token.contains('it') ||
        token.contains('marketing')) {
      return AppColors.info;
    }
    return AppColors.primary;
  }

  static int _stableSeed(String value) {
    var hash = 2166136261;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash;
  }
}
