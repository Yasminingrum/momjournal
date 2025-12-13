/// Delete Photo Use Case
/// 
/// Use case untuk menghapus photo
/// Location: lib/domain/usecases/photo/delete_photo.dart
library;

import '../../../core/errors/exceptions.dart';
import '../../../data/repositories/photo_repository.dart';
import '../../entities/photo_entity.dart';

class DeletePhotoUseCase {

  DeletePhotoUseCase(this.repository);
  final PhotoRepository repository;

  Future<void> execute(PhotoEntity photo) async {
    try {
      if (photo.id.isEmpty) {
        throw const ValidationException('Photo ID tidak boleh kosong');
      }

      await repository.deletePhoto(photo.id);
      
      print('✅ UseCase: Photo deleted successfully');
    } catch (e) {
      print('❌ UseCase: Failed to delete photo: $e');
      rethrow;
    }
  }

  /// Delete multiple photos
  Future<void> executeMultiple(List<PhotoEntity> photos) async {
    try {
      for (final photo in photos) {
        await repository.deletePhoto(photo.id);
      }
      
      print('✅ UseCase: ${photos.length} photos deleted successfully');
    } catch (e) {
      print('❌ UseCase: Failed to delete multiple photos: $e');
      rethrow;
    }
  }
}