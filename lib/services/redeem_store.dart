import 'dart:convert';

import 'package:cupon/models/brand.dart';
import 'package:cupon/models/coupon.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RedeemedCouponRecord {
  const RedeemedCouponRecord({
    required this.key,
    required this.brandName,
    required this.couponTitle,
    required this.couponCode,
    required this.redeemedAt,
  });

  final String key;
  final String brandName;
  final String couponTitle;
  final String couponCode;
  final DateTime redeemedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'brandName': brandName,
      'couponTitle': couponTitle,
      'couponCode': couponCode,
      'redeemedAt': redeemedAt.toIso8601String(),
    };
  }

  factory RedeemedCouponRecord.fromJson(Map<String, dynamic> json) {
    return RedeemedCouponRecord(
      key: json['key'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      couponTitle: json['couponTitle'] as String? ?? '',
      couponCode: json['couponCode'] as String? ?? '',
      redeemedAt: DateTime.tryParse(json['redeemedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class RedeemStore extends ChangeNotifier {
  static const String _storageKey = 'kurukshetra_redeemed_v1';

  final Set<String> _redeemedKeys = <String>{};
  final List<RedeemedCouponRecord> _records = <RedeemedCouponRecord>[];

  List<RedeemedCouponRecord> get records =>
      List<RedeemedCouponRecord>.unmodifiable(_records);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final restored = decoded
        .whereType<Map<String, dynamic>>()
        .map(RedeemedCouponRecord.fromJson)
        .toList();

    _records
      ..clear()
      ..addAll(restored);

    _redeemedKeys
      ..clear()
      ..addAll(_records.map((record) => record.key));

    notifyListeners();
  }

  bool isRedeemed(Brand brand, Coupon coupon) {
    return _redeemedKeys.contains(_buildKey(brand.name, coupon.code));
  }

  Future<void> redeem(Brand brand, Coupon coupon) async {
    final key = _buildKey(brand.name, coupon.code);
    if (_redeemedKeys.contains(key)) {
      return;
    }

    _redeemedKeys.add(key);
    _records.insert(
      0,
      RedeemedCouponRecord(
        key: key,
        brandName: brand.name,
        couponTitle: coupon.title,
        couponCode: coupon.code,
        redeemedAt: DateTime.now(),
      ),
    );

    notifyListeners();
    await _persist();
  }

  String _buildKey(String brandName, String couponCode) {
    return '${brandName.toLowerCase().trim()}::$couponCode';
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _records.map((record) => record.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(payload));
  }
}

