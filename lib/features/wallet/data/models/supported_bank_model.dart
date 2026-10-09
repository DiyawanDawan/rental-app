class SupportedBankModel {
  const SupportedBankModel({
    required this.id,
    required this.code,
    required this.name,
    this.logoUrl,
    this.isActive = true,
  });

  final String id;
  final String code;
  final String name;
  final String? logoUrl;
  final bool isActive;

  factory SupportedBankModel.fromJson(Map<String, dynamic> json) {
    return SupportedBankModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      isActive: json['isActive'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    if (logoUrl != null) 'logoUrl': logoUrl,
    'isActive': isActive,
  };
}
