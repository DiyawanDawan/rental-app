import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Resize & compress images before upload to reduce timeout risk.
class ImagePrepareUtil {
  const ImagePrepareUtil._();

  static const int defaultMaxWidth = 1600;
  static const int defaultQuality = 85;
  static const int chunkThresholdBytes = 1536 * 1024; // 1.5 MB

  static Future<String> prepareForUpload(
    String sourcePath, {
    int maxWidth = defaultMaxWidth,
    int quality = defaultQuality,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) return sourcePath;

    final lower = sourcePath.toLowerCase();
    if (!lower.endsWith('.jpg') &&
        !lower.endsWith('.jpeg') &&
        !lower.endsWith('.png') &&
        !lower.endsWith('.webp')) {
      return sourcePath;
    }

    try {
      final bytes = await source.readAsBytes();
      if (!_looksLikeImage(bytes)) return sourcePath;

      final decoded = img.decodeImage(bytes);
      if (decoded == null) return sourcePath;

      img.Image output = decoded;
      if (decoded.width > maxWidth) {
        output = img.copyResize(decoded, width: maxWidth);
      }

      final encoded = img.encodeJpg(output, quality: quality);
      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(outPath).writeAsBytes(encoded);
      return outPath;
    } catch (_) {
      return sourcePath;
    }
  }

  static Future<int> fileSize(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return file.length();
  }

  static Future<bool> shouldUseChunkUpload(String path) async {
    final size = await fileSize(path);
    return size >= chunkThresholdBytes;
  }

  static bool _looksLikeImage(List<int> bytes) {
    if (bytes.length < 12) return false;
    final isJpeg = bytes[0] == 0xFF && bytes[1] == 0xD8;
    final isPng = bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final isWebp = String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
    return isJpeg || isPng || isWebp;
  }

  static Future<void> deletePreparedFile(String path, {required String originalPath}) async {
    if (path == originalPath) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
