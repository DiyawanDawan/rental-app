class TourPackageModel {
  const TourPackageModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.durationDays,
    this.durationText,
    this.imageUrl,
    this.location,
    this.highlights = const [],
    this.destinationLat,
    this.destinationLng,
    this.distanceKm,
    this.minPassengers = 1,
    this.maxPassengers,
    this.mediaUrls = const [],
    this.destinations = const [],
    this.addons = const [],
    this.mitra,
  });

  final String id;
  final String title;
  final String? description;
  final double price;
  final int? durationDays;
  final String? durationText;
  final String? imageUrl;
  final String? location;
  final List<String> highlights;
  final double? destinationLat;
  final double? destinationLng;
  final double? distanceKm;
  final int minPassengers;
  final int? maxPassengers;
  final List<String> mediaUrls;
  final List<TourDestinationModel> destinations;
  final List<TourAddonModel> addons;
  final TourMitraModel? mitra;

  String get durationLabel {
    if (durationText != null && durationText!.trim().isNotEmpty)
      return durationText!.trim();
    if (durationDays != null) return '$durationDays Hari';
    return '-';
  }

  String get passengersLabel {
    final max = maxPassengers;
    if (max == null) return 'Min. $minPassengers orang';
    if (minPassengers == max) return '$max orang';
    return '$minPassengers–$max orang';
  }

  List<String> get galleryUrls {
    final seen = <String>{};
    final urls = <String>[];

    void add(String? url) {
      if (url == null || url.isEmpty || !seen.add(url)) return;
      urls.add(url);
    }

    for (final url in mediaUrls) {
      add(url);
    }
    add(imageUrl);

    final sortedDestinations = [...destinations]
      ..sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));
    for (final destination in sortedDestinations) {
      add(destination.imageUrl);
    }

    return urls;
  }

  TourPackageModel copyWith({double? distanceKm}) {
    return TourPackageModel(
      id: id,
      title: title,
      description: description,
      price: price,
      durationDays: durationDays,
      durationText: durationText,
      imageUrl: imageUrl,
      location: location,
      highlights: highlights,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      distanceKm: distanceKm ?? this.distanceKm,
      minPassengers: minPassengers,
      maxPassengers: maxPassengers,
      mediaUrls: mediaUrls,
      destinations: destinations,
      addons: addons,
      mitra: mitra,
    );
  }

  factory TourPackageModel.fromJson(Map<String, dynamic> json) {
    final parsedDestinations = _parseDestinations(json);
    final firstDest = parsedDestinations.isNotEmpty
        ? parsedDestinations.first
        : null;
    final parsedAddons = _parseAddons(json);
    final mediaUrls = _parseMediaUrls(json);

    return TourPackageModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: _asDouble(json['price'] ?? json['basePrice']) ?? 0.0,
      durationDays: _parseDurationDays(json),
      durationText: json['durationText']?.toString(),
      imageUrl: mediaUrls.isNotEmpty
          ? mediaUrls.first
          : _parseLegacyImageUrl(json),
      location: firstDest?.name ?? json['destination']?['name']?.toString(),
      highlights: _parseHighlights(json, parsedDestinations, parsedAddons),
      destinationLat: firstDest?.latitude ?? _firstDestinationLegacy(json).lat,
      destinationLng: firstDest?.longitude ?? _firstDestinationLegacy(json).lng,
      minPassengers: _asInt(json['minPassengers']) ?? 1,
      maxPassengers: _asInt(json['maxPassengers']),
      mediaUrls: mediaUrls,
      destinations: parsedDestinations,
      addons: parsedAddons,
      mitra: _parseMitra(json),
    );
  }

  static List<TourDestinationModel> _parseDestinations(
    Map<String, dynamic> json,
  ) {
    final raw = json['destinations'];
    if (raw is! List) return const [];

    final items = <TourDestinationModel>[];
    for (final entry in raw) {
      if (entry is! Map<String, dynamic>) continue;
      final dest = entry['destination'];
      if (dest is! Map<String, dynamic>) {
        items.add(
          TourDestinationModel(
            id:
                entry['id']?.toString() ??
                entry['destinationId']?.toString() ??
                '',
            name: entry['name']?.toString() ?? '-',
            description: entry['description']?.toString(),
            address: entry['address']?.toString() ?? entry['city']?.toString(),
            latitude: _asDouble(entry['latitude']),
            longitude: _asDouble(entry['longitude']),
            imageUrl: entry['thumbnailUrl']?.toString(),
            sequenceOrder: _asInt(entry['sequenceOrder']) ?? items.length,
          ),
        );
        continue;
      }
      items.add(
        TourDestinationModel(
          id: dest['id']?.toString() ?? '',
          name: dest['name']?.toString() ?? '-',
          description: dest['description']?.toString(),
          address: dest['address']?.toString(),
          latitude: _asDouble(dest['latitude']),
          longitude: _asDouble(dest['longitude']),
          imageUrl: _firstMediaUrl(dest['media']),
          sequenceOrder: _asInt(entry['sequenceOrder']) ?? items.length,
        ),
      );
    }
    items.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));
    return items;
  }

  static List<TourAddonModel> _parseAddons(Map<String, dynamic> json) {
    final raw = json['addons'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (a) => TourAddonModel(
            id: a['id']?.toString() ?? '',
            name: a['name']?.toString() ?? '-',
            description: a['description']?.toString(),
            additionalPrice: _asDouble(a['additionalPrice']) ?? 0,
            type: a['type']?.toString() ?? 'DESTINATION',
          ),
        )
        .toList();
  }

  static List<String> _parseMediaUrls(Map<String, dynamic> json) {
    final photoUrls = json['photoUrls'];
    if (photoUrls is List) {
      return photoUrls
          .map((url) => url.toString())
          .where((url) => url.isNotEmpty)
          .toList();
    }
    final media = json['media'];
    if (media is List) {
      return media
          .whereType<Map<String, dynamic>>()
          .map((m) => m['url']?.toString() ?? m['mediaUrl']?.toString())
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList();
    }
    final thumbnailUrl = json['thumbnailUrl']?.toString();
    return thumbnailUrl == null || thumbnailUrl.isEmpty
        ? const []
        : [thumbnailUrl];
  }

  static String? _parseLegacyImageUrl(Map<String, dynamic> json) {
    if (json['imageUrl'] != null) return json['imageUrl']?.toString();
    return null;
  }

  static String? _firstMediaUrl(Object? media) {
    if (media is! List || media.isEmpty) return null;
    final first = media.first;
    if (first is! Map<String, dynamic>) return null;
    return first['url']?.toString() ?? first['mediaUrl']?.toString();
  }

  static TourMitraModel? _parseMitra(Map<String, dynamic> json) {
    final mitra = json['mitra'];
    if (mitra is! Map<String, dynamic>) {
      final mitraId = json['mitraId']?.toString();
      if (mitraId == null || mitraId.isEmpty) return null;
      return TourMitraModel(
        id: mitraId,
        name: json['mitraOwnerName']?.toString(),
        storeName: json['mitraStoreName']?.toString(),
        avatarUrl: json['mitraAvatarUrl']?.toString(),
        phoneNumber: json['mitraPhoneNumber']?.toString(),
      );
    }
    final user = mitra['user'];
    final userMap = user is Map<String, dynamic> ? user : null;
    return TourMitraModel(
      id: mitra['id']?.toString() ?? '',
      name: userMap?['fullName']?.toString(),
      storeName: mitra['storeName']?.toString(),
      avatarUrl: userMap?['avatarUrl']?.toString(),
      phoneNumber: userMap?['phoneNumber']?.toString(),
      isVerified: mitra['isVerified'] == true,
    );
  }

  static List<String> _parseHighlights(
    Map<String, dynamic> json,
    List<TourDestinationModel> destinations,
    List<TourAddonModel> addons,
  ) {
    if (json['highlights'] is List) {
      return (json['highlights'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    final derived = <String>[
      ...destinations.map((d) => d.name).where((n) => n.isNotEmpty && n != '-'),
      ...addons.map((a) => a.name).where((n) => n.isNotEmpty && n != '-'),
    ];
    return derived.toSet().toList();
  }

  static _DestCoords _firstDestinationLegacy(Map<String, dynamic> json) {
    final destinations = json['destinations'];
    if (destinations is! List || destinations.isEmpty) {
      return const _DestCoords();
    }
    final first = destinations.first;
    if (first is! Map<String, dynamic>) return const _DestCoords();
    final raw = first['destination'];
    if (raw is! Map<String, dynamic>) return const _DestCoords();
    return _DestCoords(
      name: raw['name']?.toString(),
      lat: _asDouble(raw['latitude']),
      lng: _asDouble(raw['longitude']),
    );
  }

  static int? _parseDurationDays(Map<String, dynamic> json) {
    if (json['durationDays'] is int) return json['durationDays'] as int;
    final text = json['durationText']?.toString();
    if (text == null) return null;
    final match = RegExp(r'(\d+)').firstMatch(text);
    return match != null ? int.tryParse(match.group(1)!) : null;
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

class TourDestinationModel {
  const TourDestinationModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.sequenceOrder = 0,
  });

  final String id;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final int sequenceOrder;
}

class TourAddonModel {
  const TourAddonModel({
    required this.id,
    required this.name,
    this.description,
    required this.additionalPrice,
    required this.type,
  });

  final String id;
  final String name;
  final String? description;
  final double additionalPrice;
  final String type;

  String get typeLabel {
    switch (type.toUpperCase()) {
      case 'ACTIVITY':
        return 'Aktivitas';
      case 'SERVICE':
        return 'Layanan';
      default:
        return 'Destinasi';
    }
  }
}

class TourMitraModel {
  const TourMitraModel({
    this.id = '',
    this.name,
    this.storeName,
    this.avatarUrl,
    this.phoneNumber,
    this.isVerified = false,
  });

  final String id;
  final String? name;
  final String? storeName;
  final String? avatarUrl;
  final String? phoneNumber;
  final bool isVerified;

  String get displayName => storeName ?? name ?? 'Mitra Travelindo';

  bool get hasProfile => id.isNotEmpty;
}

class _DestCoords {
  const _DestCoords({this.name, this.lat, this.lng});
  final String? name;
  final double? lat;
  final double? lng;
}
