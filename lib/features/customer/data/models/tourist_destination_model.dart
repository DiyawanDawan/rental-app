class DestinationMediaModel {
  const DestinationMediaModel({
    required this.url,
    this.mediaType = 'IMAGE',
    this.isPrimary = false,
  });

  final String url;
  final String mediaType;
  final bool isPrimary;

  bool get isImage => mediaType.toUpperCase() == 'IMAGE';
  bool get isVideo => mediaType.toUpperCase() == 'VIDEO';
  bool get isDocument => mediaType.toUpperCase() == 'DOCUMENT';

  factory DestinationMediaModel.fromJson(Map<String, dynamic> json) {
    return DestinationMediaModel(
      url: json['url']?.toString() ?? '',
      mediaType: json['mediaType']?.toString() ?? 'IMAGE',
      isPrimary: json['isPrimary'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'mediaType': mediaType,
        'isPrimary': isPrimary,
      };
}

class TouristDestinationModel {
  const TouristDestinationModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.media = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<DestinationMediaModel> media;

  String get excerpt {
    final text = description ?? address ?? '';
    if (text.length <= 120) return text;
    return '${text.substring(0, 117)}...';
  }

  List<DestinationMediaModel> get imageMedia =>
      media.where((m) => m.isImage && m.url.isNotEmpty).toList();

  List<DestinationMediaModel> get videoMedia =>
      media.where((m) => m.isVideo && m.url.isNotEmpty).toList();

  List<String> get galleryUrls {
    final images = imageMedia.map((m) => m.url).toList();
    if (images.isNotEmpty) return images;
    if (imageUrl != null) return [imageUrl!];
    return const [];
  }

  factory TouristDestinationModel.fromJson(Map<String, dynamic> json) {
    final parsedMedia = _parseMedia(json['media']);
    final primary = parsedMedia.where((m) => m.isPrimary).map((m) => m.url).firstOrNull;
    return TouristDestinationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      imageUrl: primary ?? parsedMedia.where((m) => m.isImage).map((m) => m.url).firstOrNull,
      media: parsedMedia,
    );
  }

  static List<DestinationMediaModel> _parseMedia(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(DestinationMediaModel.fromJson)
        .where((m) => m.url.isNotEmpty)
        .toList();
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
