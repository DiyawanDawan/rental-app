class AmenityModel {
  const AmenityModel({required this.id, required this.name, this.iconUrl});

  final String id;
  final String name;
  final String? iconUrl;

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString(),
    );
  }
}

/// Vehicle type values aligned with backend `VehicleType` enum & mitra form.
class VehicleTypeOptions {
  const VehicleTypeOptions._();

  static const options = <String, String>{
    'CAR': 'Mobil',
    'MOTORBIKE': 'Motor',
    'VAN': 'Van',
    'BUS': 'Bus',
    'TRUCK': 'Truk',
  };

  static String label(String value) => options[value] ?? value;
}

class TransmissionOptions {
  const TransmissionOptions._();

  static const options = <String, String>{
    'MATIC': 'Matic',
    'MANUAL': 'Manual',
  };

  static String label(String value) => options[value] ?? value;
}

/// Sort values aligned with backend `GET /vehicles?sort=`.
class VehicleSortOptions {
  const VehicleSortOptions._();

  static const options = <String, String>{
    'newest': 'Terbaru',
    'price_asc': 'Harga Terendah',
    'price_desc': 'Harga Tertinggi',
    'rating': 'Rating Tertinggi',
    'distance_asc': 'Terdekat',
    'nearest_cheapest': 'Terdekat & Termurah',
    'nearest_top_rated': 'Terdekat & Rating',
  };

  static const geoSorts = {'distance_asc', 'nearest_cheapest', 'nearest_top_rated'};

  static String label(String value) => options[value] ?? value;

  static bool requiresLocation(String sort) => geoSorts.contains(sort);
}
