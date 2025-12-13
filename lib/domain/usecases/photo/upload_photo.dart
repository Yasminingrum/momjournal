import 'dart:io';

import '../../../core/errors/exceptions.dart';
import '../../../data/repositories/photo_repository.dart';
import '../../entities/photo_entity.dart';

class UploadPhotoUseCase {

  UploadPhotoUseCase(this.repository);
  final PhotoRepository repository;

  Future<PhotoEntity> execute({
    required File photoFile,
    required String userId,
    String? caption,
    bool isMilestone = false,
    DateTime? capturedAt,
  }) async {
    try {
      // Validate file
      _validatePhotoFile(photoFile);

      final now = DateTime.now();
      final timestamp = capturedAt ?? now;
      
      // Create photo entity
      final photo = PhotoEntity(
        id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        localPath: photoFile.path,
        caption: caption,
        isMilestone: isMilestone,
        dateTaken: timestamp,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isUploaded: false,
      );

      // Upload photo melalui repository
      await repository.createPhoto(photo);
      
      print('✅ UseCase: Photo uploaded successfully');
      return photo;
    } catch (e) {
      print('❌ UseCase: Failed to upload photo: $e');
      rethrow;
    }
  }

  void _validatePhotoFile(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      throw const StorageException('File tidak ditemukan');
    }

    // Check file size (max 10MB)
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    
    if (fileSizeInMB > 10) {
      throw const StorageException('Ukuran file maksimal 10MB');
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    final validExtensions = ['jpg', 'jpeg', 'png'];
    
    if (!validExtensions.contains(extension)) {
      throw const StorageException('Format file harus JPG, JPEG, atau PNG');
    }
  }
}