class VehiclePhotoModel {
  const VehiclePhotoModel({
    required this.photoUrl,
    this.id,
    this.isPrimary = false,
    this.caption,
  });

  final String? id;
  final String photoUrl;
  final bool isPrimary;
  final String? caption;

  factory VehiclePhotoModel.fromJson(Map<String, dynamic> json) {
    return VehiclePhotoModel(
      id: json['id']?.toString(),
      photoUrl: json['photoUrl']?.toString() ?? '',
      isPrimary: json['isPrimary'] == true,
      caption: json['caption']?.toString(),
    );
  }
}

class MitraSummaryModel {
  const MitraSummaryModel({
    required this.id,
    this.userId,
    this.storeName,
    this.isVerified = false,
    this.latitude,
    this.longitude,
    this.address,
  });

  final String id;
  final String? userId;
  final String? storeName;
  final bool isVerified;
  final double? latitude;
  final double? longitude;
  final String? address;

  String get displayName {
    final store = storeName?.trim();
    if (store != null && store.isNotEmpty) return store;
    return 'Mitra Travelindo';
  }

  factory MitraSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawAddress = json['address'];
    var lat = _asDouble(json['latitude']);
    var lng = _asDouble(json['longitude']);
    String? addressStr;
    if (rawAddress is Map<String, dynamic>) {
      lat ??= _asDouble(rawAddress['latitude']);
      lng ??= _asDouble(rawAddress['longitude']);
      addressStr = rawAddress['fullAddress']?.toString();
    } else if (rawAddress is String) {
      addressStr = rawAddress;
    }
    return MitraSummaryModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      storeName: json['storeName']?.toString(),
      isVerified: json['isVerified'] == true,
      latitude: lat,
      longitude: lng,
      address: addressStr,
    );
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.name,
    this.brand,
    this.model,
    this.year,
    this.licensePlate,
    this.color,
    this.type,
    this.transmission,
    this.seatingCapacity,
    this.description,
    this.pricePerDay,
    this.priceWithDriver,
    this.priceFullPackage,
    this.depositAmount,
    this.rentalType,
    this.status,
    this.fuelType,
    this.ratingAvg,
    this.reviewCount,
    this.isInstantBooking = false,
    this.isFavorited = false,
    this.mitra,
    this.mitraId,
    this.photos = const [],
    this.amenities = const [],
    this.distanceKm,
  });

  final String id;
  final String name;
  final String? brand, model, licensePlate, color, type, transmission;
  final String? description, rentalType, status, fuelType;
  final int? year, seatingCapacity, reviewCount;
  final double? pricePerDay, priceWithDriver, priceFullPackage, depositAmount;
  final double? ratingAvg, distanceKm;
  final bool isInstantBooking, isFavorited;
  final MitraSummaryModel? mitra;
  final String? mitraId;
  final List<VehiclePhotoModel> photos;
  final List<Map<String, dynamic>> amenities;

  String? get primaryPhotoUrl {
    if (photos.isEmpty) return null;
    return photos.firstWhere((p) => p.isPrimary, orElse: () => photos.first).photoUrl;
  }
  List<String> get allPhotoUrls => photos.map((p) => p.photoUrl).toList();
  bool get isAvailable => status == 'AVAILABLE';
  bool get hasDriverOption => priceWithDriver != null && priceWithDriver! > 0;
  bool get hasFullPackage => priceFullPackage != null && priceFullPackage! > 0;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photos'];
    final rawMitra = json['mitra'];
    final rawAmenities = json['amenities'];

    return VehicleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      year: _asInt(json['year']),
      licensePlate: json['licensePlate']?.toString(),
      color: json['color']?.toString(),
      type: json['type']?.toString(),
      transmission: json['transmission']?.toString(),
      seatingCapacity: _asInt(json['seatingCapacity']),
      description: json['description']?.toString(),
      pricePerDay: _asDouble(json['pricePerDay']),
      priceWithDriver: _asDouble(json['priceWithDriver']),
      priceFullPackage: _asDouble(json['priceFullPackage']),
      depositAmount: _asDouble(json['depositAmount']),
      rentalType: json['rentalType']?.toString() ?? 'RENTAL',
      status: json['status']?.toString() ?? 'AVAILABLE',
      fuelType: json['fuelType']?.toString(),
      ratingAvg: _asDouble(json['ratingAvg']),
      reviewCount: _asInt(json['reviewCount']),
      isInstantBooking: json['isInstantBooking'] == true,
      isFavorited: json['isFavorited'] == true,
      mitra: rawMitra is Map<String, dynamic>
          ? MitraSummaryModel.fromJson(rawMitra)
          : null,
      mitraId: json['mitraId']?.toString(),
      photos: rawPhotos is List
          ? rawPhotos
                .whereType<Map<String, dynamic>>()
                .map(VehiclePhotoModel.fromJson)
                .toList()
          : const [],
      amenities: rawAmenities is List
          ? rawAmenities.whereType<Map<String, dynamic>>().toList()
          : const [],
      distanceKm: _asDouble(json['distanceKm']),
    );
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
