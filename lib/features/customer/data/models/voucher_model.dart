class VoucherModel {
  const VoucherModel({
    required this.id,
    required this.code,
    this.name,
    this.description,
    required this.discountAmount,
    required this.discountType,
    this.minPurchase,
    this.maxDiscount,
    this.expiryDate,
  });

  final String id;
  final String code;
  final String? name;
  final String? description;
  final double discountAmount;
  final String discountType; // PERCENTAGE or FIXED
  final double? minPurchase;
  final double? maxDiscount;
  final String? expiryDate;

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id']?.toString() ?? json['voucherId']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ??
          (json['discountValue'] as num?)?.toDouble() ??
          0.0,
      discountType: json['discountType']?.toString() ?? 'FIXED',
      minPurchase: (json['minPurchase'] as num?)?.toDouble(),
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      expiryDate: json['expiryDate']?.toString() ??
          json['endDate']?.toString() ??
          json['validUntil']?.toString(),
    );
  }

  /// `PERCENT`, `PERCENTAGE`, atau varian backend lainnya.
  bool get isPercentage {
    final type = discountType.toUpperCase();
    return type.contains('PERCENT');
  }

  bool get isExpired {
    final raw = expiryDate;
    if (raw == null || raw.isEmpty) return false;
    try {
      return DateTime.parse(raw).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String get displayTitle => (name?.trim().isNotEmpty == true) ? name!.trim() : code;
}
