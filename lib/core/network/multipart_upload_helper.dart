import 'package:dio/dio.dart';

/// Builds multipart [FormData] payloads for upload endpoints.
class MultipartUploadHelper {
  const MultipartUploadHelper._();

  static Future<FormData> buildVehicleCreateForm({
    required Map<String, dynamic> fields,
    required List<String> photoPaths,
  }) async {
    final formData = FormData();

    for (final entry in fields.entries) {
      if (entry.value == null) continue;
      formData.fields.add(MapEntry(entry.key, entry.value.toString()));
    }

    for (final path in photoPaths) {
      formData.files.add(
        MapEntry('photos', await MultipartFile.fromFile(path)),
      );
    }

    return formData;
  }

  static Future<FormData> buildSinglePhotoForm({
    required String fieldName,
    required String filePath,
    Map<String, String>? extraFields,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (extraFields != null) ...extraFields,
    });
    return formData;
  }

  static Future<FormData> buildNamedDocForm(
    Map<String, String> fieldToPath, {
    Map<String, String>? extraFields,
  }) async {
    final formData = FormData();

    for (final entry in fieldToPath.entries) {
      formData.files.add(
        MapEntry(entry.key, await MultipartFile.fromFile(entry.value)),
      );
    }

    if (extraFields != null) {
      for (final entry in extraFields.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value));
      }
    }

    return formData;
  }

  static Future<FormData> buildProfileForm(
    Map<String, dynamic> fields, {
    String? avatarPath,
    String? bannerPath,
  }) async {
    final formData = FormData();

    for (final entry in fields.entries) {
      if (entry.value == null) continue;
      formData.fields.add(MapEntry(entry.key, entry.value.toString()));
    }

    if (avatarPath != null && avatarPath.isNotEmpty) {
      formData.files.add(
        MapEntry('avatar', await MultipartFile.fromFile(avatarPath)),
      );
    }

    if (bannerPath != null && bannerPath.isNotEmpty) {
      formData.files.add(
        MapEntry('banner', await MultipartFile.fromFile(bannerPath)),
      );
    }

    return formData;
  }

  /// Upload multiple files sequentially using the same endpoint + single-file field.
  static Future<void> uploadPhotosSequential({
    required Future<Response<Map<String, dynamic>>> Function(FormData formData) upload,
    required String fieldName,
    required List<String> paths,
    Map<String, String> extraFields = const {},
    bool markFirstAsPrimary = false,
  }) async {
    for (var i = 0; i < paths.length; i++) {
      final fields = Map<String, String>.from(extraFields);
      if (markFirstAsPrimary && i == 0) {
        fields['isPrimary'] = 'true';
      }
      final formData = await buildSinglePhotoForm(
        fieldName: fieldName,
        filePath: paths[i],
        extraFields: fields,
      );
      await upload(formData);
    }
  }
}

/// Valid booking document field names accepted by POST /bookings/:id/documents.
class BookingDocField {
  const BookingDocField._();

  static const String ktp = 'ktp';
  static const String sim = 'sim';
  static const String handoverPhoto = 'handoverPhoto';
  static const String returnedPhoto = 'returnedPhoto';
}
