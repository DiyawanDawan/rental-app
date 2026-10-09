import '../../../../core/utils/geo_utils.dart';
import '../../data/models/tour_model.dart';

/// Client-side tour sort including distance-based options.
class TourSortOptions {
  const TourSortOptions._();

  static const options = <String, String>{
    'default': 'Default',
    'price_asc': 'Termurah',
    'price_desc': 'Termahal',
    'duration_asc': 'Terpendek',
    'duration_desc': 'Terlama',
    'distance_asc': 'Terdekat',
    'nearest_cheapest': 'Terdekat & termurah',
  };

  static const geoSorts = {'distance_asc', 'nearest_cheapest'};

  static const radiusKm = 25.0;

  static String label(String value) => options[value] ?? value;

  static bool requiresLocation(String sort) => geoSorts.contains(sort);
}

List<TourPackageModel> applyTourGeoSort(
  List<TourPackageModel> tours,
  String sort,
  double userLat,
  double userLng,
) {
  final enriched = tours.map((t) {
    if (t.destinationLat == null || t.destinationLng == null) {
      return t.copyWith(distanceKm: null);
    }
    return t.copyWith(
      distanceKm: haversineKm(userLat, userLng, t.destinationLat!, t.destinationLng!),
    );
  }).toList();

  enriched.sort((a, b) {
    final distA = a.distanceKm ?? double.infinity;
    final distB = b.distanceKm ?? double.infinity;

    if (sort == 'distance_asc') {
      return distA.compareTo(distB);
    }
    return 0;
  });

  if (sort == 'nearest_cheapest') {
    final withinRadius = enriched
        .where((t) => t.distanceKm != null && t.distanceKm! <= TourSortOptions.radiusKm)
        .toList();
    withinRadius.sort((a, b) {
      final priceDiff = a.price.compareTo(b.price);
      if (priceDiff != 0) return priceDiff;
      return (a.distanceKm ?? double.infinity).compareTo(b.distanceKm ?? double.infinity);
    });
    return withinRadius;
  }

  return enriched;
}
