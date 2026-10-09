import 'vehicle_model.dart';
import 'travel_model.dart';

class BookingModel {
  const BookingModel({
    required this.id,
    this.vehicleId,
    this.status,
    this.startDate,
    this.endDate,
    this.totalPrice,
    this.payment,
    this.waLink,
    this.vehicle,
    this.packageType,
    this.isInsured = false,
    this.documents = const [],
    this.type,
    this.seats = const [],
    this.schedule,
    this.driverId,
    this.deliveryAddressId,
    this.withDelivery = false,
    this.deliveryFee,
    this.depositAmount,
    this.discountAmount,
    this.insuranceAmount,
    this.isSelfDrive = true,
    this.notes,
    this.cancelReason,
  });

  final String id;
  final String? vehicleId;
  final String? status;
  final String? startDate;
  final String? endDate;
  final double? totalPrice;
  final PaymentModel? payment;
  final String? waLink;
  final VehicleModel? vehicle;
  final String? packageType;
  final bool isInsured;
  final List<dynamic>? documents;
  final String? type;
  final List<String> seats;
  final TravelScheduleModel? schedule;
  final String? driverId;
  final String? deliveryAddressId;
  final bool withDelivery;
  final double? deliveryFee;
  final double? depositAmount;
  final double? discountAmount;
  final double? insuranceAmount;
  final bool isSelfDrive;
  final String? notes;
  final String? cancelReason;

  bool get isShuttle => type?.toUpperCase() == 'SHUTTLE';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final rawPayment = json['payment'];
    final rawVehicle = json['vehicle'];
    return BookingModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString(),
      status: json['status']?.toString(),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      totalPrice: _asDouble(json['totalPrice']),
      payment: rawPayment is Map<String, dynamic> ? PaymentModel.fromJson(rawPayment) : null,
      waLink: json['waLink']?.toString() ?? json['whatsapp_link']?.toString(),
      vehicle: rawVehicle is Map<String, dynamic> ? VehicleModel.fromJson(rawVehicle) : null,
      packageType: json['packageType']?.toString(),
      isInsured: json['isInsured'] == true,
      documents: json['documents'] is List ? json['documents'] as List : const [],
      type: json['type']?.toString(),
      seats: _parseSeats(json['seats']),
      schedule: json['schedule'] is Map<String, dynamic>
          ? TravelScheduleModel.fromJson(json['schedule'] as Map<String, dynamic>)
          : null,
      driverId: json['driverId']?.toString(),
      deliveryAddressId: json['deliveryAddressId']?.toString(),
      withDelivery: json['withDelivery'] == true,
      deliveryFee: _asDouble(json['deliveryFee']),
      depositAmount: _asDouble(json['depositAmount']),
      discountAmount: _asDouble(json['discountAmount']),
      insuranceAmount: _asDouble(json['insuranceAmount']),
      isSelfDrive: json['isSelfDrive'] != false,
      notes: json['notes']?.toString() ?? json['mitraNotes']?.toString() ?? json['handoverNotes']?.toString(),
      cancelReason: json['cancelReason']?.toString(),
    );
  }

  static List<String> _parseSeats(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

class PaymentModel {
  const PaymentModel({
    required this.id,
    this.status,
    this.channelCode,
    this.paymentUrl,
    this.amount,
  });

  final String id;
  final String? status;
  final String? channelCode;
  final String? paymentUrl;
  final double? amount;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString(),
      channelCode: json['channelCode']?.toString(),
      paymentUrl: json['paymentUrl']?.toString(),
      amount: BookingModel._asDouble(json['amount']),
    );
  }
}

class BookingCostEstimateModel {
  const BookingCostEstimateModel({
    this.totalPrice,
    this.rentalPrice,
    this.days,
    this.dailyPrice,
    this.deliveryFee,
    this.insuranceAmount,
    this.discountAmount,
    this.depositAmount,
  });

  final double? totalPrice;
  final double? rentalPrice;
  final int? days;
  final double? dailyPrice;
  final double? deliveryFee;
  final double? insuranceAmount;
  final double? discountAmount;
  final double? depositAmount;

  factory BookingCostEstimateModel.fromJson(Map<String, dynamic> json) {
    return BookingCostEstimateModel(
      totalPrice: BookingModel._asDouble(json['totalPrice']),
      rentalPrice: BookingModel._asDouble(json['rentalPrice']),
      days: _asInt(json['days']),
      dailyPrice: BookingModel._asDouble(json['dailyPrice']),
      deliveryFee: BookingModel._asDouble(json['deliveryFee']),
      insuranceAmount: BookingModel._asDouble(json['insuranceAmount']),
      discountAmount: BookingModel._asDouble(json['discountAmount']),
      depositAmount: BookingModel._asDouble(json['depositAmount']),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
