class CustomerPaymentModel {
  const CustomerPaymentModel({
    required this.id,
    required this.amount,
    required this.status,
    this.method,
    this.channelCode,
    this.createdAt,
    this.bookingId,
    this.bookingStartDate,
    this.bookingEndDate,
    this.bookingStatus,
    this.vehicleBrand,
    this.vehicleModel,
    this.tourPackageName,
  });

  final String id;
  final double amount;
  final String status;
  final String? method;
  final String? channelCode;
  final DateTime? createdAt;
  final String? bookingId;
  final String? bookingStartDate;
  final String? bookingEndDate;
  final String? bookingStatus;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? tourPackageName;

  factory CustomerPaymentModel.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      method: json['method']?.toString(),
      channelCode: json['channelCode']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      bookingId: json['bookingId']?.toString(),
      bookingStartDate: json['bookingStartDate']?.toString(),
      bookingEndDate: json['bookingEndDate']?.toString(),
      bookingStatus: json['bookingStatus']?.toString(),
      vehicleBrand: json['vehicleBrand']?.toString(),
      vehicleModel: json['vehicleModel']?.toString(),
      tourPackageName: json['tourPackageName']?.toString(),
    );
  }

  String get displayName {
    if (tourPackageName != null && tourPackageName!.isNotEmpty) {
      return tourPackageName!;
    }
    if (vehicleBrand != null && vehicleBrand!.isNotEmpty) {
      final model = vehicleModel ?? '';
      return '$vehicleBrand $model'.trim();
    }
    return channelCode ?? 'Pembayaran';
  }

  bool get isSuccess => status.toUpperCase() == 'SUCCESS' || status.toUpperCase() == 'PAID' || status.toUpperCase() == 'SETTLED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isFailed => status.toUpperCase() == 'FAILED' || status.toUpperCase() == 'EXPIRED';
}
