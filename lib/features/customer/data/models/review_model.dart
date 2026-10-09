class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    this.userName,
    this.userAvatar,
    this.reply,
    this.createdAt,
    this.vehicleLabel,
    this.ratingCleanliness,
    this.ratingService,
    this.ratingCondition,
  });

  final String id;
  final int rating;
  final String? comment;
  final String? userName;
  final String? userAvatar;
  final String? reply;
  final String? createdAt;
  final String? vehicleLabel;
  final int? ratingCleanliness;
  final int? ratingService;
  final int? ratingCondition;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString(),
      userName:
          json['user']?['fullName']?.toString() ??
          json['customer']?['fullName']?.toString() ??
          json['customerName']?.toString(),
      userAvatar:
          json['user']?['avatarUrl']?.toString() ??
          json['customer']?['avatarUrl']?.toString() ??
          json['customerAvatarUrl']?.toString(),
      reply:
          json['reply']?.toString() ??
          json['replyText']?.toString() ??
          json['mitraReply']?.toString(),
      createdAt: json['createdAt']?.toString(),
      vehicleLabel: _vehicleLabel(json['vehicle']) ?? _flatVehicleLabel(json),
      ratingCleanliness: (json['ratingCleanliness'] as num?)?.toInt(),
      ratingService: (json['ratingService'] as num?)?.toInt(),
      ratingCondition: (json['ratingCondition'] as num?)?.toInt(),
    );
  }

  static String? _vehicleLabel(Object? vehicle) {
    if (vehicle is! Map<String, dynamic>) return null;
    final parts = [
      vehicle['brand']?.toString(),
      vehicle['model']?.toString(),
    ].whereType<String>().where((part) => part.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(' ');
  }

  static String? _flatVehicleLabel(Map<String, dynamic> json) {
    final parts = [
      json['vehicleBrand']?.toString(),
      json['vehicleModel']?.toString(),
    ].whereType<String>().where((part) => part.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(' ');
  }

  static List<ReviewModel> listFromResponse(Object? json) {
    if (json is List) {
      return json
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();
    }
    if (json is Map<String, dynamic>) {
      final reviews = json['reviews'];
      if (reviews is List) {
        return reviews
            .whereType<Map<String, dynamic>>()
            .map(ReviewModel.fromJson)
            .toList();
      }
    }
    return const [];
  }
}
