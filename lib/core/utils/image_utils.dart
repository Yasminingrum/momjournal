import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Image Utilities
/// Helper functions for image manipulation and optimization
class ImageUtils {
  static const int defaultQuality = 85;
  static const int thumbnailSize = 300;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  
  /// Compress image file
  static Future<File?> compressImage(
    File file, {
    int quality = defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final targetPath = await _getTemporaryFilePath('compressed_${_generateFileName()}.jpg');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth ?? maxImageWidth,
        minHeight: maxHeight ?? maxImageHeight,
      );
      
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }
  
  /// Compress image to bytes
  static Future<Uint8List?> compressImageToBytes(
    File file, {
    int quality = defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        minWidth: maxWidth ?? maxImageWidth,
        minHeight: maxHeight ?? maxImageHeight,
      );
      
      return result;
    } catch (e) {
      print('Error compressing image to bytes: $e');
      return null;
    }
  }
  
  /// Create thumbnail
  static Future<File?> createThumbnail(
    File file, {
    int size = thumbnailSize,
    int quality = defaultQuality,
  }) async {
    try {
      final targetPath = await _getTemporaryFilePath('thumb_${_generateFileName()}.jpg');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: size,
        minHeight: size,
      );
      
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error creating thumbnail: $e');
      return null;
    }
  }
  
  /// Create thumbnail from bytes
  static Future<Uint8List?> createThumbnailFromBytes(
    Uint8List bytes, {
    int size = thumbnailSize,
    int quality = defaultQuality,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: size,
        minHeight: size,
      );
      
      return result;
    } catch (e) {
      print('Error creating thumbnail from bytes: $e');
      return null;
    }
  }
  
  /// Resize image
  static Future<File?> resizeImage(
    File file, {
    required int width,
    required int height,
    int quality = defaultQuality,
  }) async {
    try {
      final targetPath = await _getTemporaryFilePath('resized_${_generateFileName()}.jpg');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: width,
        minHeight: height,
      );
      
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error resizing image: $e');
      return null;
    }
  }
  
  /// Get image file size in bytes
  static Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }
  
  /// Get image file size in MB
  static Future<double> getFileSizeMB(File file) async {
    final bytes = await getFileSize(file);
    return bytes / (1024 * 1024);
  }
  
  /// Check if file size is within limit
  static Future<bool> isFileSizeValid(
    File file, {
    int maxSizeBytes = maxFileSizeBytes,
  }) async {
    final size = await getFileSize(file);
    return size <= maxSizeBytes;
  }
  
  /// Get file extension
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }
  
  /// Check if file is a valid image
  static bool isValidImageExtension(String path) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = getFileExtension(path);
    return validExtensions.contains(extension);
  }
  
  /// Convert image format
  static Future<File?> convertImageFormat(
    File file, {
    String format = 'jpg',
    int quality = defaultQuality,
  }) async {
    try {
      final targetPath = await _getTemporaryFilePath('converted_${_generateFileName()}.$format');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        format: _getCompressFormat(format),
      );
      
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error converting image format: $e');
      return null;
    }
  }
  
  /// Save bytes to file
  static Future<File?> saveBytesToFile(
    Uint8List bytes, {
    String? fileName,
    String extension = 'jpg',
  }) async {
    try {
      final name = fileName ?? _generateFileName();
      final path = await _getTemporaryFilePath('$name.$extension');
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print('Error saving bytes to file: $e');
      return null;
    }
  }
  
  /// Read file as bytes
  static Future<Uint8List?> readFileAsBytes(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      print('Error reading file as bytes: $e');
      return null;
    }
  }
  
  /// Delete file
  static Future<bool> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
  
  /// Delete file by path
  static Future<bool> deleteFileByPath(String path) async {
    try {
      final file = File(path);
      return await deleteFile(file);
    } catch (e) {
      print('Error deleting file by path: $e');
      return false;
    }
  }
  
  /// Copy file
  static Future<File?> copyFile(File source, String targetPath) async {
    try {
      return await source.copy(targetPath);
    } catch (e) {
      print('Error copying file: $e');
      return null;
    }
  }
  
  /// Move file
  static Future<File?> moveFile(File source, String targetPath) async {
    try {
      return await source.rename(targetPath);
    } catch (e) {
      print('Error moving file: $e');
      return null;
    }
  }
  
  /// Generate unique file name
  static String _generateFileName() {
    const uuid = Uuid();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${timestamp}_${uuid.v4().substring(0, 8)}';
  }
  
  /// Get temporary file path
  static Future<String> _getTemporaryFilePath(String fileName) async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/$fileName';
  }
  
  /// Get compress format from string
  static CompressFormat _getCompressFormat(String format) {
    switch (format.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return CompressFormat.jpeg;
      case 'png':
        return CompressFormat.png;
      case 'webp':
        return CompressFormat.webp;
      case 'heic':
        return CompressFormat.heic;
      default:
        return CompressFormat.jpeg;
    }
  }
  
  /// Calculate compression ratio needed to fit size limit
  static Future<int> calculateCompressionQuality(
    File file, {
    int maxSizeBytes = maxFileSizeBytes,
    int initialQuality = defaultQuality,
  }) async {
    final currentSize = await getFileSize(file);
    
    if (currentSize <= maxSizeBytes) {
      return initialQuality;
    }
    
    // Calculate required compression ratio
    final ratio = maxSizeBytes / currentSize;
    final quality = (initialQuality * ratio).round();
    
    // Ensure quality is within valid range (1-100)
    return quality.clamp(1, 100);
  }
  
  /// Compress image until it fits size limit
  static Future<File?> compressToFitSize(
    File file, {
    int maxSizeBytes = maxFileSizeBytes,
    int maxAttempts = 5,
  }) async {
    var currentFile = file;
    var quality = defaultQuality;
    
    for (var i = 0; i < maxAttempts; i++) {
      final isValid = await isFileSizeValid(currentFile, maxSizeBytes: maxSizeBytes);
      
      if (isValid) {
        return currentFile;
      }
      
      // Reduce quality by 15% for next attempt
      quality = (quality * 0.85).round();
      
      if (quality < 10) {
        // Quality too low, might affect image significantly
        break;
      }
      
      final compressed = await compressImage(currentFile, quality: quality);
      
      if (compressed == null) {
        return null;
      }
      
      currentFile = compressed;
    }
    
    // If still too large after all attempts, return the best we got
    return currentFile;
  }
  
  /// Get image dimensions (width and height)
  static Future<Map<String, int>?> getImageDimensions(File file) async {
    try {
      // This would require image package or platform-specific code
      // For now, returning null as placeholder
      // TODO: Implement actual dimension reading
      return null;
    } catch (e) {
      print('Error getting image dimensions: $e');
      return null;
    }
  }
  
  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  // Private constructor to prevent instantiation
  ImageUtils._();
}