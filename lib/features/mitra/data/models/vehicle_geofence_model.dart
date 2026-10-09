class VehicleGeofenceModel {
  const VehicleGeofenceModel({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.centerLat,
    required this.centerLng,
    required this.radiusM,
    this.isActive = true,
  });

  final String id;
  final String vehicleId;
  final String name;
  final double centerLat;
  final double centerLng;
  final int radiusM;
  final bool isActive;

  factory VehicleGeofenceModel.fromJson(Map<String, dynamic> json) {
    return VehicleGeofenceModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      centerLat: (json['centerLat'] as num?)?.toDouble() ?? 0,
      centerLng: (json['centerLng'] as num?)?.toDouble() ?? 0,
      radiusM: (json['radiusM'] as num?)?.toInt() ?? 5000,
      isActive: json['isActive'] != false,
    );
  }
}
