class MitraReviewItemModel {
  const MitraReviewItemModel({
    required this.id,
    required this.rating,
    this.comment,
    this.mitraReply,
    this.createdAt,
    this.vehicleBrand,
    this.vehicleModel,
    this.customerName,
    this.customerAvatarUrl,
  });

  final String id;
  final int rating;
  final String? comment;
  final String? mitraReply;
  final DateTime? createdAt;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? customerName;
  final String? customerAvatarUrl;

  String get vehicleName => [vehicleBrand, vehicleModel]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .join(' ');

  bool get hasReply => mitraReply != null && mitraReply!.trim().isNotEmpty;

  factory MitraReviewItemModel.fromJson(Map<String, dynamic> json) {
    return MitraReviewItemModel(
      id: json['id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString(),
      mitraReply: json['mitraReply']?.toString() ?? json['reply']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      vehicleBrand: json['vehicleBrand']?.toString(),
      vehicleModel: json['vehicleModel']?.toString(),
      customerName: json['customerName']?.toString() ?? json['customer']?['fullName']?.toString(),
      customerAvatarUrl: json['customerAvatarUrl']?.toString() ?? json['customer']?['avatarUrl']?.toString(),
    );
  }
}

class MitraReviewPaginatedModel {
  const MitraReviewPaginatedModel({
    required this.reviews,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<MitraReviewItemModel> reviews;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  factory MitraReviewPaginatedModel.fromJson(Map<String, dynamic> json) {
    final list = (json['reviews'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(MitraReviewItemModel.fromJson)
            .toList() ??
        [];
    return MitraReviewPaginatedModel(
      reviews: list,
      total: (json['total'] as num?)?.toInt() ?? list.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
