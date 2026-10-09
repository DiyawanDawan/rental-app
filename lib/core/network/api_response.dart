class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.status,
    required this.message,
    this.data,
  });

  final bool success;
  final int status;
  final String message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromData,
  ) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};

    return ApiResponse<T>(
      success: meta['success'] == true,
      status: meta['status'] is int ? meta['status'] as int : 0,
      message: meta['message']?.toString() ?? '',
      data: fromData == null ? json['data'] as T? : fromData(json['data']),
    );
  }
}
