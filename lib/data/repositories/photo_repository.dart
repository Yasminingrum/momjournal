import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '/domain/entities/photo_entity.dart';

/// Repository for Photo data management
/// Implements offline-first approach with cloud sync capability
class PhotoRepository {
  static const String _boxName = 'photos';
  Box<PhotoEntity>? _box;
  
  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Initialize the Hive box for photos
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<PhotoEntity>(_boxName);
    }
  }

  /// Upload photo to Firebase Storage and save to local DB
  /// This is the main method for adding new photos with cloud upload
  Future<void> uploadPhoto({
    required PhotoEntity photo,
    required String imagePath,
    void Function(double)? onProgress,
  }) async {
    try {
      await init();

      // Step 1: Compress image
      final compressedFile = await _compressImage(imagePath);

      // Step 2: Upload to Firebase Storage
      final cloudUrl = await _uploadToFirebase(
        file: compressedFile,
        photoId: photo.id,
        onProgress: onProgress,
      );

      // Step 3: Save to local DB with cloud URL
      final photoWithUrl = photo.copyWith(
        localPath: compressedFile.path,
        cloudUrl: cloudUrl,
        isUploaded: true,
        isSynced: true,
        updatedAt: DateTime.now(),
      );

      await _box!.put(photo.id, photoWithUrl);

      // Clean up compressed file if different from original
      if (compressedFile.path != imagePath) {
        // Keep the compressed file as it's now the localPath
      }
    } catch (e) {
      // If upload fails, still save locally for retry later
      final photoWithoutUrl = photo.copyWith(
        localPath: imagePath,
        isUploaded: false,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      await _box!.put(photo.id, photoWithoutUrl);
      rethrow;
    }
  }

  /// Compress image before upload
  Future<File> _compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      
      // Get file size
      final fileSize = await file.length();
      
      // If file is already small (<500KB), don't compress
      if (fileSize < 500 * 1024) {
        return file;
      }

      // Create compressed file path
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compress with quality based on file size
      int quality = 85;
      if (fileSize > 5 * 1024 * 1024) {
        quality = 70; // 5MB+
      } else if (fileSize > 2 * 1024 * 1024) {
        quality = 80; // 2-5MB
      }

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: quality,
        minWidth: 1920,
        minHeight: 1920,
      );

      return compressedFile != null ? File(compressedFile.path) : file;
    } catch (e) {
      // If compression fails, return original file
      if (kDebugMode) {
        debugPrint('Image compression failed: $e');
      }
      return File(imagePath);
    }
  }

  /// Upload file to Firebase Storage
  Future<String> _uploadToFirebase({
    required File file,
    required String photoId,
    void Function(double)? onProgress,
  }) async {
    try {
      // Create storage reference with organized path
      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'photos/$photoId/${timestamp}_$fileName';
      
      final storageRef = _storage.ref().child(storagePath);

      // Upload with progress tracking
      final uploadTask = storageRef.putFile(file);

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (onProgress != null) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload to Firebase Storage: $e');
    }
  }

  /// Create a new photo entry (without upload - for local only)
  Future<void> createPhoto(PhotoEntity photo) async {
    await init();
    await _box!.put(photo.id, photo);
  }

  /// Get all photos
  Future<List<PhotoEntity>> getAllPhotos() async {
    await init();
    final photos = _box!.values.toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken)); // Most recent first
    return photos;
  }

  /// Get photos with pagination
  Future<List<PhotoEntity>> getPhotosPaginated(int page, int pageSize) async {
    await init();
    final allPhotos = await getAllPhotos();
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, allPhotos.length);
    
    if (startIndex >= allPhotos.length) {
      return [];
    }
    
    return allPhotos.sublist(startIndex, endIndex);
  }

  /// Get milestone photos only
  Future<List<PhotoEntity>> getMilestonePhotos() async {
    await init();
    final photos = _box!.values.where((photo) => photo.isMilestone).toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
    return photos;
  }

  /// Get photos for a specific date
  Future<List<PhotoEntity>> getPhotosByDate(DateTime date) async {
    await init();
    return _box!.values
        .where((photo) =>
            photo.dateTaken.year == date.year &&
            photo.dateTaken.month == date.month &&
            photo.dateTaken.day == date.day,)
        .toList();
  }

  /// Get photos for a date range
  Future<List<PhotoEntity>> getPhotosByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    await init();
    final photos = _box!.values
        .where((photo) =>
            photo.dateTaken.isAfter(start.subtract(const Duration(days: 1))) &&
            photo.dateTaken.isBefore(end.add(const Duration(days: 1))),)
        .toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
    return photos;
  }

  /// Get a specific photo by ID
  Future<PhotoEntity?> getPhotoById(String id) async {
    await init();
    return _box!.get(id);
  }

  /// Update an existing photo
  Future<void> updatePhoto(PhotoEntity photo) async {
    await init();
    final updatedPhoto = photo.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _box!.put(photo.id, updatedPhoto);
  }

  /// Update cloud URL after upload
  Future<void> updateCloudUrl(String id, String cloudUrl) async {
    await init();
    final photo = _box!.get(id);
    if (photo != null) {
      final updated = photo.copyWith(
        cloudUrl: cloudUrl,
        isUploaded: true,
        updatedAt: DateTime.now(),
      );
      await _box!.put(id, updated);
    }
  }

  /// Delete a photo (also delete from Firebase Storage if uploaded)
  Future<void> deletePhoto(String id) async {
    await init();
    
    // Get photo to check if it has cloud URL
    final photo = _box!.get(id);
    
    if (photo != null && photo.cloudUrl != null) {
      try {
        // Delete from Firebase Storage
        final ref = _storage.refFromURL(photo.cloudUrl!);
        await ref.delete();
      } catch (e) {
        // Continue even if cloud deletion fails
        if (kDebugMode) {
          debugPrint('Failed to delete from cloud: $e');
        }
      }
    }
    
    // Delete from local DB
    await _box!.delete(id);
  }

  /// Get photos that need to be uploaded
  Future<List<PhotoEntity>> getPhotosToUpload() async {
    await init();
    return _box!.values.where((photo) => !photo.isUploaded).toList();
  }

  /// Retry uploading failed photos
  Future<void> retryFailedUploads({
    void Function(double)? onProgress,
  }) async {
    await init();
    final photosToUpload = await getPhotosToUpload();
    
    for (final photo in photosToUpload) {
      try {
        if (photo.localPath != null) {
          await uploadPhoto(
            photo: photo,
            imagePath: photo.localPath!,
            onProgress: onProgress,
          );
        }
      } catch (e) {
        // Continue with next photo even if one fails
        if (kDebugMode) {
          debugPrint('Failed to retry upload for ${photo.id}: $e');
        }
      }
    }
  }

  /// Get unsynced photos for cloud sync
  Future<List<PhotoEntity>> getUnsyncedPhotos() async {
    await init();
    return _box!.values.where((photo) => !photo.isSynced).toList();
  }

  /// Mark photo as synced
  Future<void> markAsSynced(String id) async {
    await init();
    final photo = _box!.get(id);
    if (photo != null) {
      final synced = photo.copyWith(isSynced: true);
      await _box!.put(id, synced);
    }
  }

  /// Get photo count
  Future<int> getPhotoCount() async {
    await init();
    return _box!.length;
  }

  /// Get milestone photo count
  Future<int> getMilestoneCount() async {
    await init();
    return _box!.values.where((photo) => photo.isMilestone).length;
  }

  /// Clear all photos (for testing or logout)
  Future<void> clearAll() async {
    await init();
    await _box!.clear();
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
  }
}