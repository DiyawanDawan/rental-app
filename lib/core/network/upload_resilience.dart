import 'package:dio/dio.dart';

import '../errors/failure.dart';

/// Retry helper for upload operations with exponential backoff.
class UploadResilience {
  const UploadResilience._();

  static const int defaultMaxAttempts = 3;
  static const int baseDelayMs = 500;

  static Future<T> withRetry<T>(
    Future<T> Function() action, {
    int maxAttempts = defaultMaxAttempts,
    bool Function(Object error)? shouldRetry,
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await action();
      } catch (error) {
        lastError = error;
        final retryable = shouldRetry?.call(error) ?? _isRetryable(error);
        if (!retryable || attempt >= maxAttempts) {
          rethrow;
        }
        await Future<void>.delayed(
          Duration(milliseconds: baseDelayMs * attempt * attempt),
        );
      }
    }

    throw lastError ?? Failure(message: 'Upload gagal');
  }

  static bool _isRetryable(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError ||
          (error.response?.statusCode != null && error.response!.statusCode! >= 500);
    }
    if (error is Failure) {
      return error.message.contains('timeout') ||
          error.message.contains('Koneksi');
    }
    return false;
  }
}
