class VehicleBlockedDateModel {
  const VehicleBlockedDateModel({required this.blockedDate, this.reason});

  final DateTime blockedDate;
  final String? reason;

  /// Format YYYY-MM-DD untuk pencocokan di _CalendarGrid
  String get dateString => blockedDate.toIso8601String().split('T')[0];

  factory VehicleBlockedDateModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['blockedDate']?.toString() ?? '';
    return VehicleBlockedDateModel(
      blockedDate: DateTime.tryParse(rawDate) ?? DateTime.now(),
      reason: json['reason']?.toString(),
    );
  }
}
