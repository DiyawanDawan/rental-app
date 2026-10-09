class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    return PaginationMeta(
      page: _asInt(json?['page'], fallback: 1),
      limit: _asInt(json?['limit'], fallback: 10),
      total: _asInt(json?['total']),
      totalPages: _asInt(json?['totalPages'], fallback: 1),
    );
  }

  static int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
    required this.pagination,
  });

  final bool success;
  final int status;
  final String message;
  final List<T> data;
  final PaginationMeta pagination;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromItem,
  ) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final rawData = json['data'];
    final items = rawData is List ? rawData.map(fromItem).toList() : <T>[];

    return PaginatedResponse<T>(
      success: meta['success'] == true,
      status: meta['status'] is int ? meta['status'] as int : 0,
      message: meta['message']?.toString() ?? '',
      data: items,
      pagination: PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>?),
    );
  }
}
