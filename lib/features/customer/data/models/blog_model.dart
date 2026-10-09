class BlogModel {
  const BlogModel({
    required this.id,
    required this.title,
    required this.slug,
    this.content,
    this.excerpt,
    this.imageUrl,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.isPublished = false,
    this.authorName,
    this.authorAvatarUrl,
  });

  final String id;
  final String title;
  final String slug;
  final String? content;
  final String? excerpt;
  final String? imageUrl;
  final String? category;
  final String? createdAt;
  final String? updatedAt;
  final bool isPublished;
  final String? authorName;
  final String? authorAvatarUrl;

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : null;

    return BlogModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      // backend list returns no 'content'; detail endpoint returns 'body'
      content: json['body']?.toString() ?? json['content']?.toString(),
      excerpt: json['excerpt']?.toString() ?? json['summary']?.toString(),
      // backend returns 'coverUrl'; fallback to other variants
      imageUrl: json['coverUrl']?.toString() ??
          json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          json['thumbnailUrl']?.toString(),
      category: json['category']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      isPublished: json['isPublished'] == true,
      authorName: author?['fullName']?.toString() ??
          json['authorName']?.toString(),
      authorAvatarUrl: author?['avatarUrl']?.toString() ??
          json['authorAvatarUrl']?.toString(),
    );
  }
}

