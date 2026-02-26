import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class CompressionUtils {
  // 画像圧縮設定
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;
  static const int jpegQuality = 85;
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  static Future<File> compressImage(File file) async {
    // 元の画像を読み込み
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('画像の読み込みに失敗しました');
    }

    // リサイズ
    img.Image resized = image;
    if (image.width > maxWidth || image.height > maxHeight) {
      resized = img.copyResize(
        image,
        width: image.width > image.height ? maxWidth : null,
        height: image.height >= image.width ? maxHeight : null,
      );
    }

    // JPEG圧縮
    final compressed = img.encodeJpg(resized, quality: jpegQuality);

    // 一時ファイルに保存
    final tempPath = '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressedFile = File(tempPath);
    await compressedFile.writeAsBytes(compressed);

    return compressedFile;
  }

  static Future<bool> checkFileSize(File file) async {
    final size = await file.length();
    return size <= maxFileSizeBytes;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  static Future<FileSizeInfo> getFileSizeInfo(File file) async {
    final size = await file.length();
    return FileSizeInfo(
      bytes: size,
      formatted: formatFileSize(size),
      exceedsLimit: size > maxFileSizeBytes,
    );
  }

  static Future<List<File>> compressMultipleImages(List<File> files) async {
    final compressed = <File>[];
    for (final file in files) {
      try {
        final compressedFile = await compressImage(file);
        compressed.add(compressedFile);
      } catch (e) {
        // エラーの場合は元のファイルを使用
        compressed.add(file);
      }
    }
    return compressed;
  }
}

class FileSizeInfo {
  final int bytes;
  final String formatted;
  final bool exceedsLimit;

  FileSizeInfo({
    required this.bytes,
    required this.formatted,
    required this.exceedsLimit,
  });
}
