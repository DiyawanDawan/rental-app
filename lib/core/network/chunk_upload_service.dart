import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../app/env.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'upload_resilience.dart';

/// Level-3 chunked upload: init → parts → complete.
class ChunkUploadService {
  const ChunkUploadService(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultChunkSize = 512 * 1024;

  Future<ChunkUploadResult> uploadFile({
    required String filePath,
    required String mimeType,
    String folder = 'uploads/chunks',
    int chunkSize = defaultChunkSize,
    void Function(int sent, int total)? onProgress,
  }) async {
    final file = File(filePath);
    final totalSize = await file.length();
    final fileName = filePath.split(Platform.pathSeparator).last;

    final initResponse = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.storageUploadInit,
      data: {
        'fileName': fileName,
        'mimeType': mimeType,
        'totalSize': totalSize,
        'chunkSize': chunkSize,
        'folder': folder,
      },
      options: Options(
        sendTimeout: Duration(milliseconds: AppEnv.uploadTimeoutMs),
        receiveTimeout: Duration(milliseconds: AppEnv.uploadTimeoutMs),
      ),
    );

    final initData = initResponse.data?['data'] as Map<String, dynamic>? ?? {};
    final uploadId = initData['uploadId']?.toString() ?? '';
    final effectiveChunkSize =
        (initData['chunkSize'] as num?)?.toInt() ?? chunkSize;

    if (uploadId.isEmpty) {
      throw Exception('Gagal memulai sesi chunk upload');
    }

    final randomAccess = await file.open();
    var partNumber = 1;
    var sent = 0;

    try {
      await UploadResilience.withRetry(() async {
        while (sent < totalSize) {
          final remaining = totalSize - sent;
          final readSize = remaining < effectiveChunkSize ? remaining : effectiveChunkSize;
          final buffer = await randomAccess.read(readSize);

          await _uploadPart(
            uploadId: uploadId,
            partNumber: partNumber,
            bytes: buffer,
          );

          sent += readSize;
          partNumber++;
          onProgress?.call(sent, totalSize);
        }
      });

      final completeResponse = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.storageUploadComplete(uploadId),
        options: Options(
          sendTimeout: Duration(milliseconds: AppEnv.uploadTimeoutMs),
          receiveTimeout: Duration(milliseconds: AppEnv.uploadTimeoutMs),
        ),
      );

      final result = completeResponse.data?['data'] as Map<String, dynamic>? ?? {};
      return ChunkUploadResult(
        path: result['path']?.toString() ?? '',
        url: result['url']?.toString() ?? '',
        size: (result['size'] as num?)?.toInt() ?? totalSize,
      );
    } catch (error) {
      try {
        await _apiClient.delete<Map<String, dynamic>>(
          ApiEndpoints.storageUploadAbort(uploadId),
        );
      } catch (_) {}
      rethrow;
    } finally {
      await randomAccess.close();
    }
  }

  Future<void> _uploadPart({
    required String uploadId,
    required int partNumber,
    required Uint8List bytes,
  }) async {
    final formData = FormData.fromMap({
      'partNumber': partNumber.toString(),
      'chunk': MultipartFile.fromBytes(bytes, filename: 'part_$partNumber.bin'),
    });

    await _apiClient.upload<Map<String, dynamic>>(
      ApiEndpoints.storageUploadPart(uploadId),
      formData: formData,
    );
  }
}

class ChunkUploadResult {
  const ChunkUploadResult({
    required this.path,
    required this.url,
    required this.size,
  });

  final String path;
  final String url;
  final int size;
}
