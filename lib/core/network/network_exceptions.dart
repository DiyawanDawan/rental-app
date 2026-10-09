import 'package:dio/dio.dart';

import '../errors/failure.dart';

class NetworkExceptions {
  const NetworkExceptions._();

  static Failure fromDioException(DioException error) {
    final responseData = error.response?.data;
    final statusCode = error.response?.statusCode;

    if (responseData is Map<String, dynamic>) {
      final meta = responseData['meta'];
      if (meta is Map<String, dynamic>) {
        return Failure(
          message: meta['message']?.toString() ?? error.message ?? 'Request failed',
          statusCode: statusCode,
          details: responseData['data'],
        );
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Failure(
          message: 'Koneksi ke server timeout',
          statusCode: statusCode,
          details: error,
        );
      case DioExceptionType.connectionError:
        return Failure(
          message: 'Tidak bisa terhubung ke server',
          statusCode: statusCode,
          details: error,
        );
      case DioExceptionType.cancel:
        return Failure(
          message: 'Request dibatalkan',
          statusCode: statusCode,
          details: error,
        );
      case DioExceptionType.badCertificate:
        return Failure(
          message: 'Sertifikat server tidak valid',
          statusCode: statusCode,
          details: error,
        );
      case DioExceptionType.badResponse:
        return Failure(
          message: 'Permintaan gagal diproses',
          statusCode: statusCode,
          details: error,
        );
      case DioExceptionType.unknown:
        return Failure(
          message: 'Terjadi kesalahan jaringan',
          statusCode: statusCode,
          details: error,
        );
    }
  }
}
