import 'dart:convert';

import 'package:cupon/models/brand.dart';
import 'package:cupon/models/coupon.dart';
import 'package:flutter/services.dart';

class BrandService {
  const BrandService();

  Future<List<Brand>> loadBrands() async {
    try {
      final empresasRaw = await rootBundle.loadString('lib/constants/empresas.json');
      final empresasDecoded = jsonDecode(empresasRaw) as Map<String, dynamic>;
      final negocios = (empresasDecoded['negocios'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      if (negocios.isNotEmpty) {
        return negocios.map(_brandFromEmpresa).toList(growable: false);
      }
    } catch (_) {}

    final rawJson = await rootBundle.loadString('assets/data/brands.json');
    final decoded = jsonDecode(rawJson) as List<dynamic>;

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Brand.fromJson)
        .toList(growable: false);
  }

  Brand _brandFromEmpresa(Map<String, dynamic> json) {
    final name = json['nombre'] as String? ?? 'Local Brand';
    final category = json['categoria'] as String? ?? 'Miscellaneous';
    final address = json['direccion'] as String? ?? 'Kurukshetra';
    final phone = json['telefono'] as String? ?? 'N/A';
    final url = json['url'] as String? ?? '';

    return Brand(
      name: name,
      logo: _buildLogoTag(name),
      description: _buildDescription(category),
      category: category,
      contact: BrandContact(address: address, phone: phone),
      coupons: _buildCoupons(name, category),
      website: url,
    );
  }

  List<Coupon> _buildCoupons(String brandName, String category) {
    final codeSeed = _buildLogoTag(brandName).toUpperCase();
    final templates = <Map<String, String>>[
      <String, String>{
        'title': 'Welcome Deal 20% OFF',
        'description': 'Special entry offer for new walk-ins in $category.',
        'terms': 'Valid one time per user.',
        'validUntil': '2026-07-30',
        'code': '$codeSeed-NEW20',
      },
      <String, String>{
        'title': 'Flat INR 250 OFF',
        'description': 'Direct discount on eligible bill amount.',
        'terms': 'Minimum purchase INR 1500.',
        'validUntil': '2026-08-25',
        'code': '$codeSeed-FLAT250',
      },
      <String, String>{
        'title': 'Weekday Saver 30%',
        'description': 'Applicable Monday to Thursday only.',
        'terms': 'Not valid on public holidays.',
        'validUntil': '2026-09-20',
        'code': '$codeSeed-WDAY30',
      },
      <String, String>{
        'title': 'Buy 1 Get 1',
        'description': 'Selected items only. Ask store for eligible menu.',
        'terms': 'Limited stock. Store discretion applies.',
        'validUntil': '2026-10-10',
        'code': '$codeSeed-B1G1',
      },
      <String, String>{
        'title': 'Premium Member Benefit',
        'description': 'Extra value coupon for app users.',
        'terms': 'Show coupon code before billing.',
        'validUntil': '2026-11-30',
        'code': '$codeSeed-PRO',
      },
    ];

    return templates
        .map(
          (template) => Coupon(
            title: template['title']!,
            description: template['description']!,
            terms: template['terms']!,
            validUntil: DateTime.parse(template['validUntil']!),
            code: template['code']!,
          ),
        )
        .toList(growable: false);
  }

  String _buildDescription(String category) {
    return 'Local $category partner with exclusive in-app coupon deals.';
  }

  String _buildLogoTag(String value) {
    final words = value
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0])
        .join();
    return words.isEmpty ? 'LD' : words;
  }
}
