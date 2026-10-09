enum VehicleStatusEnum {
  available('AVAILABLE', 'Aktif & Tersedia'),
  unavailable('UNAVAILABLE', 'Nonaktif'),
  maintenance('MAINTENANCE', 'Dalam Perawatan'),
  pendingApproval('PENDING_APPROVAL', 'Menunggu Verifikasi');

  const VehicleStatusEnum(this.value, this.label);
  final String value;
  final String label;

  bool get isOperational => this == VehicleStatusEnum.available;

  static VehicleStatusEnum fromString(String? val) =>
      VehicleStatusEnum.values.firstWhere(
        (e) => e.value == val,
        orElse: () => VehicleStatusEnum.unavailable,
      );
}

enum VehicleTypeEnum {
  car('CAR', 'Mobil'),
  motorbike('MOTORBIKE', 'Motor'),
  van('VAN', 'Minivan'),
  bus('BUS', 'Bus'),
  truck('TRUCK', 'Truk');

  const VehicleTypeEnum(this.value, this.label);
  final String value;
  final String label;

  static VehicleTypeEnum fromString(String? val) =>
      VehicleTypeEnum.values.firstWhere(
        (e) => e.value == val,
        orElse: () => VehicleTypeEnum.car,
      );
}

enum TransmissionTypeEnum {
  matic('MATIC', 'Otomatis / Matic'),
  manual('MANUAL', 'Manual');

  const TransmissionTypeEnum(this.value, this.label);
  final String value;
  final String label;

  static TransmissionTypeEnum fromString(String? val) =>
      TransmissionTypeEnum.values.firstWhere(
        (e) => e.value == val,
        orElse: () => TransmissionTypeEnum.matic,
      );
}

enum RentalTypeEnum {
  rental('RENTAL', 'Sewa Lepas Kunci / Harian'),
  shuttle('SHUTTLE', 'Travel / Shuttle Antar Kota'),
  both('BOTH', 'Rental & Shuttle');

  const RentalTypeEnum(this.value, this.label);
  final String value;
  final String label;

  static RentalTypeEnum fromString(String? val) =>
      RentalTypeEnum.values.firstWhere(
        (e) => e.value == val,
        orElse: () => RentalTypeEnum.rental,
      );
}
