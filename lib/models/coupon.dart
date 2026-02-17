class Coupon {
  const Coupon({
    required this.title,
    required this.description,
    required this.terms,
    required this.validUntil,
    required this.code,
  });

  final String title;
  final String description;
  final String terms;
  final DateTime validUntil;
  final String code;

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      terms: json['terms'] as String? ?? '',
      validUntil: DateTime.tryParse(json['valid_until'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      code: json['code'] as String? ?? '',
    );
  }

  String get validUntilLabel {
    final month = validUntil.month.toString().padLeft(2, '0');
    final day = validUntil.day.toString().padLeft(2, '0');
    return '${validUntil.year}-$month-$day';
  }
}

