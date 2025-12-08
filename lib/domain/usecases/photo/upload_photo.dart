/// Upload Photo Use Case
/// 
/// Use case untuk upload photo ke storage
/// Location: lib/domain/usecases/photo/upload_photo.dart

import 'dart:io';
import '../../../data/repositories/photo_repository.dart';
import '../../entities/photo_entity.dart';
import '../../../core/errors/exceptions.dart';

class UploadPhotoUseCase {
  final PhotoRepository repository;

  UploadPhotoUseCase(this.repository);

  Future<PhotoEntity> execute({
    required File photoFile,
    String? caption,
    bool isMilestone = false,
    DateTime? capturedAt,
  }) async {
    try {
      // Validate file
      _validatePhotoFile(photoFile);

      // Create photo entity
      final photo = PhotoEntity.create(
        caption: caption,
        isMilestone: isMilestone,
        capturedAt: capturedAt ?? DateTime.now(),
      );

      // Upload photo
      final uploadedPhoto = await repository.uploadPhoto(photoFile, photo);
      
      print('✅ UseCase: Photo uploaded successfully');
      return uploadedPhoto;
    } catch (e) {
      print('❌ UseCase: Failed to upload photo: $e');
      rethrow;
    }
  }

  void _validatePhotoFile(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      throw StorageException('File tidak ditemukan');
    }

    // Check file size (max 10MB)
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    
    if (fileSizeInMB > 10) {
      throw StorageException('Ukuran file maksimal 10MB');
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    final validExtensions = ['jpg', 'jpeg', 'png'];
    
    if (!validExtensions.contains(extension)) {
      throw StorageException('Format file harus JPG, JPEG, atau PNG');
    }
  }
}