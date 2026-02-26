import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/compression_utils.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<List<File>?> pickImages({
    required int maxImages,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      if (source == ImageSource.gallery) {
        final pickedFiles = await _picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        
        if (pickedFiles.isEmpty) return null;
        
        final files = pickedFiles
            .take(maxImages)
            .map((xFile) => File(xFile.path))
            .toList();
            
        return await CompressionUtils.compressMultipleImages(files);
      } else {
        final pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        
        if (pickedFile == null) return null;
        
        final file = File(pickedFile.path);
        final compressed = await CompressionUtils.compressImage(file);
        return [compressed];
      }
    } catch (e) {
      print('Error picking images: $e');
      return null;
    }
  }

  static Future<File?> pickSingleImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final images = await pickImages(maxImages: 1, source: source);
    return images?.firstOrNull;
  }

  static Future<bool> saveImageToCameraRoll(File image) async {
    try {
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        return false;
      }

      // TODO: 実際のカメラロール保存処理を実装
      // image_gallery_saver などのパッケージを使用
      return true;
    } catch (e) {
      print('Error saving to camera roll: $e');
      return false;
    }
  }

  static Future<bool> saveMultipleImagesToCameraRoll(List<File> images) async {
    bool allSuccess = true;
    
    for (final image in images) {
      final success = await saveImageToCameraRoll(image);
      if (!success) {
        allSuccess = false;
      }
    }
    
    return allSuccess;
  }

  static Future<File> saveImageLocally(File image, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    return await image.copy(path);
  }

  static Future<bool> deleteLocalImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  static Future<List<File>> getLocalImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync()
        .where((item) => item is File && _isImageFile(item.path))
        .map((item) => File(item.path))
        .toList();
    
    return files;
  }

  static bool _isImageFile(String path) {
    final extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return extensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  static Future<void> clearCache() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    
    for (final file in files) {
      if (file is File && _isImageFile(file.path)) {
        try {
          await file.delete();
        } catch (e) {
          print('Error deleting cache file: $e');
        }
      }
    }
  }
}
