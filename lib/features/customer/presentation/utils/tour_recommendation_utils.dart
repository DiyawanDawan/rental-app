import '../../data/models/tour_model.dart';

/// Picks tour packages to highlight as recommendations on Home and detail pages.
List<TourPackageModel> pickRecommendedTours(
  List<TourPackageModel> tours, {
  int limit = 6,
  String? excludeId,
}) {
  final candidates = tours.where((t) => t.id.isNotEmpty && t.id != excludeId).toList();
  candidates.sort((a, b) => _recommendScore(b).compareTo(_recommendScore(a)));
  return candidates.take(limit).toList();
}

int _recommendScore(TourPackageModel tour) {
  var score = 0;
  if (tour.imageUrl != null) score += 3;
  if (tour.destinations.length > 1) score += 2;
  if (tour.description != null && tour.description!.trim().length > 40) score += 2;
  if (tour.durationText != null || tour.durationDays != null) score += 1;
  if (tour.addons.isNotEmpty) score += 1;
  if (tour.mitra?.name != null) score += 1;
  return score;
}
