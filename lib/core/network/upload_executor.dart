import 'package:dio/dio.dart';

import '../utils/image_prepare_util.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'chunk_upload_service.dart';
import 'multipart_upload_helper.dart';
import 'upload_resilience.dart';

typedef UploadProgressCallback = void Function(int current, int total);

/// Unified resilient upload: compress → chunk or multipart → retry.
class UploadExecutor {
  UploadExecutor(this._apiClient) : _chunkService = ChunkUploadService(_apiClient);

  final ApiClient _apiClient;
  final ChunkUploadService _chunkService;

  Future<void> uploadVehiclePhoto({
    required String vehicleId,
    required String filePath,
    bool isPrimary = false,
    void Function(int sent, int total)? onProgress,
  }) async {
    final prepared = await ImagePrepareUtil.prepareForUpload(filePath);
    final useChunk = await ImagePrepareUtil.shouldUseChunkUpload(prepared);

    try {
    await UploadResilience.withRetry(() async {
      if (useChunk) {
        final result = await _chunkService.uploadFile(
          filePath: prepared,
          mimeType: 'image/jpeg',
          folder: 'vehicles/$vehicleId',
          onProgress: onProgress,
        );
        await _apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.vehiclePhotoRegister(vehicleId),
          data: {
            'path': result.path,
            'isPrimary': isPrimary,
          },
        );
        return;
      }

      final formData = await MultipartUploadHelper.buildSinglePhotoForm(
        fieldName: 'photo',
        filePath: prepared,
        extraFields: {if (isPrimary) 'isPrimary': 'true'},
      );

      await _apiClient.upload<Map<String, dynamic>>(
        ApiEndpoints.vehiclePhotos(vehicleId),
        formData: formData,
        onSendProgress: onProgress,
      );
    });
    } finally {
      await ImagePrepareUtil.deletePreparedFile(prepared, originalPath: filePath);
    }
  }

  Future<void> uploadPhotosToVehicle({
    required String vehicleId,
    required List<String> paths,
    void Function(int current, int total)? onPhotoProgress,
  }) async {
    for (var i = 0; i < paths.length; i++) {
      await uploadVehiclePhoto(
        vehicleId: vehicleId,
        filePath: paths[i],
        isPrimary: i == 0,
        onProgress: onPhotoProgress == null
            ? null
            : (sent, total) => onPhotoProgress(i + 1, paths.length),
      );
    }
  }

  Future<void> uploadNamedDocument({
    required String endpoint,
    required String fieldName,
    required String filePath,
    Map<String, String> extraFields = const {},
    void Function(int sent, int total)? onProgress,
  }) async {
    final prepared = await ImagePrepareUtil.prepareForUpload(filePath);

    try {
      await UploadResilience.withRetry(() async {
        final formData = await MultipartUploadHelper.buildNamedDocForm(
          {fieldName: prepared},
          extraFields: extraFields,
        );

        await _apiClient.upload<Map<String, dynamic>>(
          endpoint,
          formData: formData,
          onSendProgress: onProgress,
        );
      });
    } finally {
      await ImagePrepareUtil.deletePreparedFile(prepared, originalPath: filePath);
    }
  }

  Future<void> uploadMultipart({
    required String endpoint,
    required FormData formData,
    bool usePatch = false,
    void Function(int sent, int total)? onProgress,
  }) async {
    await UploadResilience.withRetry(() async {
      if (usePatch) {
        await _apiClient.uploadPatch<Map<String, dynamic>>(
          endpoint,
          formData: formData,
          onSendProgress: onProgress,
        );
      } else {
        await _apiClient.upload<Map<String, dynamic>>(
          endpoint,
          formData: formData,
          onSendProgress: onProgress,
        );
      }
    });
  }
}
