import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '/core/constants/app_constants.dart';

/// Storage Service
/// Handles local file storage and cache management
class StorageService {
  factory StorageService() => _instance;
  StorageService._internal();
  static final StorageService _instance = StorageService._internal();
  
  Directory? _appDocDir;
  Directory? _tempDir;
  Directory? _cacheDir;
  
  /// Initialize storage service
  Future<void> initialize() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _tempDir = await getTemporaryDirectory();
    _cacheDir = await getApplicationCacheDirectory();
  }
  
  /// Get application documents directory
  Directory get appDocumentsDirectory {
    if (_appDocDir == null) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
    return _appDocDir!;
  }
  
  /// Get temporary directory
  Directory get temporaryDirectory {
    if (_tempDir == null) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
    return _tempDir!;
  }
  
  /// Get cache directory
  Directory get cacheDirectory {
    if (_cacheDir == null) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
    return _cacheDir!;
  }
  
  /// Save file to app documents directory
  Future<File> saveFile({
    required String fileName,
    required List<int> bytes,
    String? subDirectory,
  }) async {
    final directory = subDirectory != null
        ? Directory('${appDocumentsDirectory.path}/$subDirectory')
        : appDocumentsDirectory;
    
    // Create directory if it doesn't exist
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    
    return file;
  }
  
  /// Read file from app documents directory
  Future<List<int>?> readFile({
    required String fileName,
    String? subDirectory,
  }) async {
    try {
      final directory = subDirectory != null
          ? Directory('${appDocumentsDirectory.path}/$subDirectory')
          : appDocumentsDirectory;
      
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      if (file.existsSync()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading file: $e');
      return null;
    }
  }
  
  /// Delete file from app documents directory
  Future<bool> deleteFile({
    required String fileName,
    String? subDirectory,
  }) async {
    try {
      final directory = subDirectory != null
          ? Directory('${appDocumentsDirectory.path}/$subDirectory')
          : appDocumentsDirectory;
      
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      if (file.existsSync()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }
  
  /// Check if file exists
  Future<bool> fileExists({
    required String fileName,
    String? subDirectory,
  }) async {
    try {
      final directory = subDirectory != null
          ? Directory('${appDocumentsDirectory.path}/$subDirectory')
          : appDocumentsDirectory;
      
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      return file.existsSync();
    } catch (e) {
      debugPrint('Error checking file existence: $e');
      return false;
    }
  }
  
  /// Get file path
  String getFilePath({
    required String fileName,
    String? subDirectory,
  }) {
    final directory = subDirectory != null
        ? '${appDocumentsDirectory.path}/$subDirectory'
        : appDocumentsDirectory.path;
    
    return '$directory/$fileName';
  }
  
  /// List files in directory
  Future<List<FileSystemEntity>> listFiles({
    String? subDirectory,
  }) async {
    try {
      final directory = subDirectory != null
          ? Directory('${appDocumentsDirectory.path}/$subDirectory')
          : appDocumentsDirectory;
      
      if (directory.existsSync()) {
        return directory.listSync();
      }
      return [];
    } catch (e) {
      debugPrint('Error listing files: $e');
      return [];
    }
  }
  
  /// Get directory size
  Future<int> getDirectorySize({
    String? subDirectory,
  }) async {
    try {
      final directory = subDirectory != null
          ? Directory('${appDocumentsDirectory.path}/$subDirectory')
          : appDocumentsDirectory;
      
      if (!directory.existsSync()) {
        return 0;
      }
      
      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
      return 0;
    }
  }
  
  /// Get cache size
  Future<int> getCacheSize() async => getDirectorySize();
  
  /// Clear cache
  Future<bool> clearCache() async {
    try {
      if (cacheDirectory.existsSync()) {
        await cacheDirectory.delete(recursive: true);
        await cacheDirectory.create();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      return false;
    }
  }
  
  /// Clear temporary directory
  Future<bool> clearTemporaryFiles() async {
    try {
      if (temporaryDirectory.existsSync()) {
        await temporaryDirectory.delete(recursive: true);
        await temporaryDirectory.create();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing temporary files: $e');
      return false;
    }
  }
  
  /// Clear old cache files (older than specified days)
  Future<int> clearOldCache({
    int maxAgeInDays = AppConstants.cacheMaxAge,
  }) async {
    try {
      if (!cacheDirectory.existsSync()) {
        return 0;
      }
      
      int deletedCount = 0;
      final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));
      
      await for (final entity in cacheDirectory.list(recursive: true)) {
        if (entity is File) {
          final lastModified = entity.lastModifiedSync();
          if (lastModified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }
      
      return deletedCount;
    } catch (e) {
      debugPrint('Error clearing old cache: $e');
      return 0;
    }
  }
  
  /// Ensure cache size limit
  Future<bool> ensureCacheSizeLimit({
    int maxSizeInBytes = AppConstants.cacheSizeLimit,
  }) async {
    try {
      final currentSize = await getCacheSize();
      
      if (currentSize <= maxSizeInBytes) {
        return true;
      }
      
      // Delete oldest files until size is under limit
      final files = <File>[];
      await for (final entity in cacheDirectory.list(recursive: true)) {
        if (entity is File) {
          files.add(entity);
        }
      }
      
      // Sort by last modified date (oldest first)
      files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
      
      int deletedSize = 0;
      for (final file in files) {
        if (currentSize - deletedSize <= maxSizeInBytes) {
          break;
        }
        
        deletedSize += await file.length();
        await file.delete();
      }
      
      return true;
    } catch (e) {
      debugPrint('Error ensuring cache size limit: $e');
      return false;
    }
  }
  
  /// Copy file
  Future<File?> copyFile({
    required File source,
    required String destinationPath,
  }) async {
    try {
      return await source.copy(destinationPath);
    } catch (e) {
      debugPrint('Error copying file: $e');
      return null;
    }
  }
  
  /// Move file
  Future<File?> moveFile({
    required File source,
    required String destinationPath,
  }) async {
    try {
      return await source.rename(destinationPath);
    } catch (e) {
      debugPrint('Error moving file: $e');
      return null;
    }
  }
  
  /// Create directory
  Future<Directory?> createDirectory({
    required String directoryName,
    String? parentDirectory,
  }) async {
    try {
      final parentPath = parentDirectory != null
          ? '${appDocumentsDirectory.path}/$parentDirectory'
          : appDocumentsDirectory.path;
      
      final directory = Directory('$parentPath/$directoryName');
      
      if (!directory.existsSync()) {
        return await directory.create(recursive: true);
      }
      
      return directory;
    } catch (e) {
      debugPrint('Error creating directory: $e');
      return null;
    }
  }
  
  /// Delete directory
  Future<bool> deleteDirectory({
    required String directoryName,
    String? parentDirectory,
  }) async {
    try {
      final parentPath = parentDirectory != null
          ? '${appDocumentsDirectory.path}/$parentDirectory'
          : appDocumentsDirectory.path;
      
      final directory = Directory('$parentPath/$directoryName');
      
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error deleting directory: $e');
      return false;
    }
  }
  
  /// Format bytes to human-readable size
  String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
  
  /// Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    final cacheSize = await getCacheSize();
    final appDocSize = await getDirectorySize();
    
    return {
      'cacheSize': cacheSize,
      'cacheSizeFormatted': formatBytes(cacheSize),
      'appDocSize': appDocSize,
      'appDocSizeFormatted': formatBytes(appDocSize),
      'totalSize': cacheSize + appDocSize,
      'totalSizeFormatted': formatBytes(cacheSize + appDocSize),
    };
  }
}