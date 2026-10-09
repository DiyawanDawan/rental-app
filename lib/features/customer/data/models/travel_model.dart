class TravelRouteModel {
  const TravelRouteModel({
    required this.id,
    required this.origin,
    required this.destination,
    this.originRegencyId,
    this.destinationRegencyId,
    this.distance,
    this.durationMinutes,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
  });

  final String id;
  final String origin;
  final String destination;
  final String? originRegencyId;
  final String? destinationRegencyId;
  final double? distance;
  final int? durationMinutes;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;

  bool get hasMapCoords =>
      originLat != null && originLng != null && destinationLat != null && destinationLng != null;

  String get distanceText {
    if (distance == null || distance! <= 0) return '-';
    if (distance! >= 1) return '${distance!.toStringAsFixed(0)} km';
    return '${(distance! * 1000).toStringAsFixed(0)} m';
  }

  String get durationText {
    if (durationMinutes == null || durationMinutes! <= 0) return '-';
    final hours = durationMinutes! ~/ 60;
    final mins = durationMinutes! % 60;
    if (hours > 0 && mins > 0) return '$hours jam $mins menit';
    if (hours > 0) return '$hours jam';
    return '$mins menit';
  }

  factory TravelRouteModel.fromJson(Map<String, dynamic> json) {
    final originObj = json['origin'];
    final destObj = json['destination'];

    return TravelRouteModel(
      id: json['id']?.toString() ?? '',
      origin: addressLabel(originObj),
      destination: addressLabel(destObj),
      originRegencyId: regencyId(originObj),
      destinationRegencyId: regencyId(destObj),
      distance: (json['distance'] ?? json['distanceKm'] as num?)?.toDouble(),
      durationMinutes: _parseDuration(json['duration'] ?? json['estimatedDurationMin']),
      originLat: _parseCoord(originObj is Map ? originObj['latitude'] : null),
      originLng: _parseCoord(originObj is Map ? originObj['longitude'] : null),
      destinationLat: _parseCoord(destObj is Map ? destObj['latitude'] : null),
      destinationLng: _parseCoord(destObj is Map ? destObj['longitude'] : null),
    );
  }

  static String addressLabel(dynamic obj) {
    if (obj is! Map) return obj?.toString() ?? '';
    return (obj['regency']?['name'] ?? obj['name'] ?? obj['fullAddress'] ?? '').toString();
  }

  static String? regencyId(dynamic obj) {
    if (obj is! Map) return null;
    final regency = obj['regency'];
    return (obj['regencyId'] ?? (regency is Map ? regency['id'] : null))?.toString();
  }

  static double? _parseCoord(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseDuration(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }
}

class TravelScheduleModel {
  const TravelScheduleModel({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    this.route,
    this.vehicleName,
    this.availableSeats,
    this.seatingCapacity,
    this.status,
    this.departureAt,
    this.arrivalAt,
    this.mitraStoreName,
    this.mitraAlternateName,
    this.mitraIsVerified = false,
  });

  final String id;
  final String departureTime;
  final String arrivalTime;
  final double price;
  final TravelRouteModel? route;
  final String? vehicleName;
  final int? availableSeats;
  final int? seatingCapacity;
  final String? status;
  final DateTime? departureAt;
  final DateTime? arrivalAt;
  final String? mitraStoreName;
  final String? mitraAlternateName;
  final bool mitraIsVerified;

  factory TravelScheduleModel.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['pricePerSeat'] ?? json['price'];
    final departureRaw = json['departureTime']?.toString() ?? '';
    final arrivalRaw = json['arrivalTime']?.toString() ?? '';
    final mitra = json['mitra'];
    final mitraMap = mitra is Map<String, dynamic> ? mitra : null;
    final mitraUser = mitraMap?['user'];
    final userMap = mitraUser is Map<String, dynamic> ? mitraUser : null;

    return TravelScheduleModel(
      id: json['id']?.toString() ?? '',
      departureTime: _formatTime(departureRaw),
      arrivalTime: _formatTime(arrivalRaw),
      price: _parsePrice(priceRaw),
      route: json['route'] != null ? TravelRouteModel.fromJson(json['route'] as Map<String, dynamic>) : null,
      vehicleName: json['vehicle']?['name']?.toString(),
      availableSeats: json['availableSeats'] as int?,
      seatingCapacity: json['vehicle']?['seatingCapacity'] as int? ?? json['seatingCapacity'] as int?,
      status: json['status']?.toString(),
      departureAt: _parseDateTime(departureRaw),
      arrivalAt: _parseDateTime(arrivalRaw),
      mitraStoreName: mitraMap?['storeName']?.toString(),
      mitraAlternateName: userMap?['fullName']?.toString(),
      mitraIsVerified: mitraMap?['isVerified'] == true,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _formatTime(String isoOrTime) {
    if (isoOrTime.isEmpty) return '';
    if (isoOrTime.contains('T')) {
      try {
        final dt = DateTime.parse(isoOrTime).toLocal();
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        return isoOrTime;
      }
    }
    return isoOrTime.length >= 5 ? isoOrTime.substring(0, 5) : isoOrTime;
  }

  static DateTime? _parseDateTime(String isoOrTime) {
    if (isoOrTime.isEmpty) return null;
    try {
      return DateTime.parse(isoOrTime).toLocal();
    } catch (_) {
      return null;
    }
  }
}

enum SeatTier { regular, vip, window }

extension SeatTierX on SeatTier {
  String get code {
    switch (this) {
      case SeatTier.vip:
        return 'VIP';
      case SeatTier.window:
        return 'WINDOW';
      case SeatTier.regular:
        return 'REGULAR';
    }
  }

  String get label {
    switch (this) {
      case SeatTier.vip:
        return 'VIP';
      case SeatTier.window:
        return 'Jendela';
      case SeatTier.regular:
        return 'Reguler';
    }
  }

  static SeatTier fromCode(String? value) {
    switch (value?.toUpperCase()) {
      case 'VIP':
        return SeatTier.vip;
      case 'WINDOW':
        return SeatTier.window;
      default:
        return SeatTier.regular;
    }
  }
}

class BusSeatMapRowModel {
  const BusSeatMapRowModel({
    required this.label,
    required this.seats,
  });

  final String label;
  final List<SeatModel> seats;

  factory BusSeatMapRowModel.fromJson(Map<String, dynamic> json, {required Set<String> occupied, double defaultPrice = 0}) {
    final rawSeats = json['seats'];
    final seats = <SeatModel>[];

    if (rawSeats is List) {
      for (final item in rawSeats) {
        if (item is String) {
          seats.add(SeatModel.fromCode(item, occupied: occupied, defaultPrice: defaultPrice));
        } else if (item is Map) {
          seats.add(SeatModel.fromJson(Map<String, dynamic>.from(item), occupied: occupied, defaultPrice: defaultPrice));
        }
      }
    }

    return BusSeatMapRowModel(
      label: json['label']?.toString() ?? '',
      seats: seats,
    );
  }
}

class BusSeatMapModel {
  const BusSeatMapModel({required this.rows});

  final List<BusSeatMapRowModel> rows;

  factory BusSeatMapModel.fromJson(
    dynamic json, {
    required Set<String> occupied,
    double defaultPrice = 0,
  }) {
    if (json is! Map) return const BusSeatMapModel(rows: []);
    final rowsJson = json['rows'];
    if (rowsJson is! List) return const BusSeatMapModel(rows: []);

    final rows = rowsJson
        .whereType<Map>()
        .map((r) => BusSeatMapRowModel.fromJson(
              Map<String, dynamic>.from(r),
              occupied: occupied,
              defaultPrice: defaultPrice,
            ))
        .toList();

    return BusSeatMapModel(rows: rows);
  }

  List<SeatModel> get allSeats => rows.expand((r) => r.seats).toList();
}

class SeatModel {
  const SeatModel({
    required this.code,
    required this.isAvailable,
    this.tier = SeatTier.regular,
    this.price,
  });

  final String code;
  final bool isAvailable;
  final SeatTier tier;
  final double? price;

  String get seatNumber => code;
  String get id => code;

  double effectivePrice(double fallback) => price ?? fallback;

  factory SeatModel.fromCode(String code, {required Set<String> occupied, double defaultPrice = 0, SeatTier tier = SeatTier.regular, double? price}) {
    return SeatModel(
      code: code,
      isAvailable: !occupied.contains(code),
      tier: tier,
      price: price ?? defaultPrice,
    );
  }

  factory SeatModel.fromJson(
    Map<String, dynamic> json, {
    required Set<String> occupied,
    double defaultPrice = 0,
  }) {
    final code = (json['code'] ?? json['seatNumber'] ?? json['id'] ?? '').toString();
    final tier = SeatTierX.fromCode(json['tier']?.toString());
    final priceRaw = json['price'];

    return SeatModel(
      code: code,
      isAvailable: json.containsKey('isAvailable')
          ? json['isAvailable'] == true
          : !occupied.contains(code),
      tier: tier,
      price: priceRaw != null ? TravelScheduleModel._parsePrice(priceRaw) : defaultPrice,
    );
  }
}

class TravelSeatAvailabilityModel {
  const TravelSeatAvailabilityModel({
    required this.scheduleId,
    required this.seatingCapacity,
    required this.occupiedSeats,
    required this.pricePerSeat,
    this.seatMap,
    this.seats = const [],
  });

  final String scheduleId;
  final int seatingCapacity;
  final List<String> occupiedSeats;
  final double pricePerSeat;
  final BusSeatMapModel? seatMap;
  final List<SeatModel> seats;

  factory TravelSeatAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final occupied = (json['occupiedSeats'] as List? ?? [])
        .map((e) => e.toString())
        .toSet();
    final pricePerSeat = TravelScheduleModel._parsePrice(json['pricePerSeat']);
    final capacity = (json['seatingCapacity'] as num?)?.toInt() ?? 0;

    final apiSeats = (json['seats'] as List? ?? [])
        .whereType<Map>()
        .map((s) => SeatModel.fromJson(Map<String, dynamic>.from(s), occupied: occupied, defaultPrice: pricePerSeat))
        .toList();

    BusSeatMapModel? seatMapModel;
    if (json['seatMap'] != null) {
      seatMapModel = BusSeatMapModel.fromJson(json['seatMap'], occupied: occupied, defaultPrice: pricePerSeat);
    }

    return TravelSeatAvailabilityModel(
      scheduleId: json['scheduleId']?.toString() ?? '',
      seatingCapacity: capacity,
      occupiedSeats: occupied.toList(),
      pricePerSeat: pricePerSeat,
      seatMap: seatMapModel,
      seats: apiSeats,
    );
  }
}
