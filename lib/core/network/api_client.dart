import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../../app/env.dart';
import '../errors/failure.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'network_exceptions.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage}) : _tokenStorage = tokenStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.apiV1BaseUrl,
        connectTimeout: Duration(milliseconds: AppEnv.apiTimeoutMs),
        receiveTimeout: Duration(milliseconds: AppEnv.apiTimeoutMs),
        sendTimeout: kIsWeb ? null : Duration(milliseconds: AppEnv.apiTimeoutMs),
        headers: const {
          Headers.acceptHeader: Headers.jsonContentType,
          Headers.contentTypeHeader: Headers.jsonContentType,
        },
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error is DioException && _shouldRefresh(error)) {
            final refreshToken = await _tokenStorage.readRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              return handler.next(error);
            }

            final requestOptions = error.requestOptions;
            requestOptions.extra['retry'] = true;

            final refreshed = await _refreshToken(refreshToken);
            if (!refreshed) {
              return handler.next(error);
            }

            final newAccessToken = await _tokenStorage.readAccessToken();
            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            }

            try {
              final response = await _dio.fetch(requestOptions);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            } catch (retryError) {
              if (retryError is DioException) {
                return handler.next(retryError);
              }
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        TalkerDioLogger(
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: false,
            printResponseMessage: true,
          ),
        ),
      );
    }
  }

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get dio => _dio;

  Future<Response<T>> getAbsolute<T>(Uri uri) {
    return _guard(() => _dio.getUri<T>(uri));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guard(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guard(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guard(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guard(
      () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guard(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    void Function(int sent, int total)? onSendProgress,
  }) {
    return _guard(
      () => _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          sendTimeout: Duration(milliseconds: AppEnv.uploadTimeoutMs),
          receiveTimeout: Duration(milliseconds: AppEnv.uploadTimeoutMs),
        ),
      ),
    );
  }

  Future<Response<T>> uploadPatch<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    void Function(int sent, int total)? onSendProgress,
  }) {
    return _guard(
      () => _dio.patch<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          sendTimeout: Duration(milliseconds: AppEnv.uploadTimeoutMs),
          receiveTimeout: Duration(milliseconds: AppEnv.uploadTimeoutMs),
        ),
      ),
    );
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw NetworkExceptions.fromDioException(error);
    } catch (error) {
      throw Failure(message: 'Terjadi kesalahan tidak terduga', details: error);
    }
  }

  bool _shouldRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    final requestOptions = error.requestOptions;
    return statusCode == 401 &&
        requestOptions.extra['retry'] != true &&
        !requestOptions.path.endsWith(ApiEndpoints.authRefreshToken);
  }

  Future<bool> _refreshToken(String refreshToken) async {
    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
          sendTimeout: _dio.options.sendTimeout,
          headers: const {
            Headers.acceptHeader: Headers.jsonContentType,
            Headers.contentTypeHeader: Headers.jsonContentType,
          },
        ),
      );

      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.authRefreshToken,
        data: {'token': refreshToken},
      );

      final body = response.data;
      if (body == null) {
        return false;
      }

      final data = body['data'];
      if (data is Map<String, dynamic>) {
        final accessToken = data['token']?.toString() ?? '';
        final refreshTokenNew = data['refreshToken']?.toString();

        if (accessToken.isEmpty) {
          return false;
        }

        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshTokenNew,
        );

        return true;
      }

      return false;
    } on DioException {
      await _tokenStorage.clear();
      return false;
    }
  }
}

