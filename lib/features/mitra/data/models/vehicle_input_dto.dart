class VehicleInputDto {
  const VehicleInputDto({
    required this.name,
    required this.brand,
    required this.model,
    required this.type,
    required this.year,
    required this.transmission,
    required this.licensePlate,
    required this.color,
    required this.seatingCapacity,
    required this.pricePerDay,
    this.rentalType = 'RENTAL',
    this.isInstantBooking = false,
    this.priceWithDriver,
    this.priceFullPackage,
    this.depositAmount,
    this.description,
  });

  final String name, brand, model, type;
  final int year;
  final String transmission, licensePlate, color;
  final int seatingCapacity;
  final double pricePerDay;
  final String rentalType;
  final bool isInstantBooking;
  final double? priceWithDriver, priceFullPackage, depositAmount;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        'brand': brand,
        'model': model,
        'type': type,
        'year': year,
        'transmission': transmission,
        'licensePlate': licensePlate,
        'color': color,
        'seatingCapacity': seatingCapacity,
        'pricePerDay': pricePerDay,
        'rentalType': rentalType,
        'isInstantBooking': isInstantBooking,
        if (priceWithDriver != null && priceWithDriver! > 0)
          'priceWithDriver': priceWithDriver,
        if (priceFullPackage != null && priceFullPackage! > 0)
          'priceFullPackage': priceFullPackage,
        if (depositAmount != null && depositAmount! >= 0)
          'depositAmount': depositAmount,
        if (description != null && description!.trim().isNotEmpty)
          'description': description!.trim(),
      };
}
