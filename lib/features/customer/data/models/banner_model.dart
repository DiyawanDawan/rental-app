class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.linkUrl,
    this.position,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? linkUrl;
  final String? position;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      linkUrl: json['linkUrl']?.toString(),
      position: json['position']?.toString(),
    );
  }
}
