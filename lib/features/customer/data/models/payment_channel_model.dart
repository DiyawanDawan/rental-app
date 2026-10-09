class PaymentChannelModel {
  const PaymentChannelModel({
    required this.id,
    required this.name,
    required this.code,
    required this.method,
    this.logoUrl,
    this.minAmount,
    this.maxAmount,
    this.feeAmount,
    this.feePercent,
  });

  final String id;
  final String name;
  final String code;
  final String method;
  final String? logoUrl;
  final double? minAmount;
  final double? maxAmount;
  final double? feeAmount;
  final double? feePercent;

  factory PaymentChannelModel.fromJson(Map<String, dynamic> json) {
    return PaymentChannelModel(
      id: (json['id'] ?? json['code'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      minAmount: _asDouble(json['minAmount']),
      maxAmount: _asDouble(json['maxAmount']),
      feeAmount: _asDouble(json['feeAmount']),
      feePercent: _asDouble(json['feePercent']),
    );
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
