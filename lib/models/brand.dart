import 'package:cupon/models/coupon.dart';

class BrandContact {
  const BrandContact({
    required this.address,
    required this.phone,
  });

  final String address;
  final String phone;

  factory BrandContact.fromJson(Map<String, dynamic> json) {
    return BrandContact(
      address: json['address'] as String? ?? 'Address unavailable',
      phone: json['phone'] as String? ?? 'N/A',
    );
  }
}

class Brand {
  const Brand({
    required this.name,
    required this.logo,
    required this.description,
    required this.category,
    required this.contact,
    required this.coupons,
    this.website = '',
  });

  final String name;
  final String logo;
  final String description;
  final String category;
  final BrandContact contact;
  final List<Coupon> coupons;
  final String website;

  factory Brand.fromJson(Map<String, dynamic> json) {
    final couponsJson = (json['coupons'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();

    return Brand(
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      contact: BrandContact.fromJson(
        json['contact'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      coupons: couponsJson.map(Coupon.fromJson).toList(),
      website: json['website'] as String? ?? json['url'] as String? ?? '',
    );
  }

  String get shortDescription {
    if (description.length <= 95) {
      return description;
    }
    return '${description.substring(0, 92)}...';
  }
}

