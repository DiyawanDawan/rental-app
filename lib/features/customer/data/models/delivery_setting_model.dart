class DeliverySettingModel {
  const DeliverySettingModel({
    required this.id,
    required this.type,
    this.basePrice,
    this.pricePerKm,
    this.minKm,
    this.isActive = true,
  });

  final String id;
  final String type;
  final double? basePrice;
  final double? pricePerKm;
  final double? minKm;
  final bool isActive;

  factory DeliverySettingModel.fromJson(Map<String, dynamic> json) {
    return DeliverySettingModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'FIXED',
      basePrice: _asDouble(json['basePrice']),
      pricePerKm: _asDouble(json['pricePerKm']),
      minKm: _asDouble(json['minKm']),
      isActive: json['isActive'] != false,
    );
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
