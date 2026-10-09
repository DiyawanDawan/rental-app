import 'review_model.dart';

class VehicleReviewAggregateModel {
  const VehicleReviewAggregateModel({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  final List<ReviewModel> reviews;
  final double averageRating;
  final int totalReviews;

  factory VehicleReviewAggregateModel.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['reviews'] as List? ?? [];
    return VehicleReviewAggregateModel(
      reviews: rawReviews
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList(),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? rawReviews.length,
    );
  }
}
