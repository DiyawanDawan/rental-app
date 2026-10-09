class MitraSubscriptionModel {
  const MitraSubscriptionModel({
    required this.tier,
    required this.status,
    required this.vehicleCount,
    required this.maxVehicles,
    required this.proMonthlyPrice,
    this.expiresAt,
    this.autoRenew = false,
    this.findMyMotor = true,
    this.customerPhoneTracking = true,
    this.iotGps = false,
    this.geofence = false,
    this.gpsPairing = false,
    this.locationHistory = false,
  });

  final String tier;
  final String status;
  final int vehicleCount;
  final int maxVehicles;
  final double proMonthlyPrice;
  final DateTime? expiresAt;
  final bool autoRenew;
  final bool findMyMotor;
  final bool customerPhoneTracking;
  final bool iotGps;
  final bool geofence;
  final bool gpsPairing;
  final bool locationHistory;

  bool get isPro => tier == 'PRO' && status == 'ACTIVE';

  factory MitraSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final features = json['features'];
    return MitraSubscriptionModel(
      tier: json['tier']?.toString() ?? 'FREE',
      status: json['status']?.toString() ?? 'ACTIVE',
      vehicleCount: (json['vehicleCount'] as num?)?.toInt() ?? 0,
      maxVehicles: (json['maxVehicles'] as num?)?.toInt() ?? 3,
      proMonthlyPrice: (json['proMonthlyPrice'] as num?)?.toDouble() ?? 99000,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
      autoRenew: json['autoRenew'] == true,
      findMyMotor: features is Map ? features['findMyMotor'] != false : true,
      customerPhoneTracking: features is Map ? features['customerPhoneTracking'] != false : true,
      iotGps: features is Map ? features['iotGps'] == true : false,
      geofence: features is Map ? features['geofence'] == true : false,
      gpsPairing: features is Map ? features['gpsPairing'] == true : false,
      locationHistory: features is Map ? features['locationHistory'] == true : false,
    );
  }
}

class ActiveTrackingUnitModel {
  const ActiveTrackingUnitModel({
    required this.bookingId,
    required this.vehicleId,
    this.vehicleName,
    this.licensePlate,
    this.customerName,
    this.endDate,
    this.isOverdue = false,
    this.lat,
    this.lng,
    this.lastSeenAt,
    this.batteryPct,
    this.gpsStatus,
    this.trackingSource,
    this.locationStatus,
  });

  final String bookingId;
  final String vehicleId;
  final String? vehicleName;
  final String? licensePlate;
  final String? customerName;
  final DateTime? endDate;
  final bool isOverdue;
  final double? lat;
  final double? lng;
  final DateTime? lastSeenAt;
  final int? batteryPct;
  final String? gpsStatus;
  final String? trackingSource;
  final String? locationStatus;

  bool get hasLocation => lat != null && lng != null;

  bool get isIotSource => trackingSource == 'IOT';
  bool get isWaitingLocation => locationStatus == 'WAITING';
  bool get isOffline => locationStatus == 'OFFLINE';

  factory ActiveTrackingUnitModel.fromJson(Map<String, dynamic> json) {
    final gps = json['gps'];
    return ActiveTrackingUnitModel(
      bookingId: json['bookingId']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      vehicleName: json['vehicleName']?.toString(),
      licensePlate: json['licensePlate']?.toString(),
      customerName: json['customerName']?.toString(),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'].toString()) : null,
      isOverdue: json['isOverdue'] == true,
      lat: gps is Map ? (gps['lat'] as num?)?.toDouble() : null,
      lng: gps is Map ? (gps['lng'] as num?)?.toDouble() : null,
      lastSeenAt: gps is Map && gps['lastSeenAt'] != null
          ? DateTime.tryParse(gps['lastSeenAt'].toString())
          : null,
      batteryPct: gps is Map ? (gps['batteryPct'] as num?)?.toInt() : null,
      gpsStatus: gps is Map ? gps['status']?.toString() : null,
      trackingSource: json['trackingSource']?.toString(),
      locationStatus: json['locationStatus']?.toString(),
    );
  }
}
