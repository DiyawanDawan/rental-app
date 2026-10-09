class MitraDriverModel {
  const MitraDriverModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.simNumber,
    this.simType,
    this.status,
    this.photoUrl,
    this.simExpiry,
  });

  final String id;
  final String fullName;
  final String phoneNumber;
  final String simNumber;
  final String? simType;
  final String? status;
  final String? photoUrl;
  final DateTime? simExpiry;

  factory MitraDriverModel.fromJson(Map<String, dynamic> json) {
    return MitraDriverModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      simNumber: json['simNumber']?.toString() ?? '',
      simType: json['simType']?.toString(),
      status: json['status']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      simExpiry: json['simExpiry'] == null
          ? null
          : DateTime.tryParse(json['simExpiry'].toString()),
    );
  }
}
