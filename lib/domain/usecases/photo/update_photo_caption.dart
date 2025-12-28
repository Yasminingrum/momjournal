import '../../../data/repositories/photo_repository.dart';

/// Use case untuk update caption foto
class UpdatePhotoCaptionUseCase {

  UpdatePhotoCaptionUseCase(this.repository);
  final PhotoRepository repository;

  Future<void> execute({
    required String photoId,
    required String caption,
  }) async {
    try {
      // Get existing photo
      final photos = await repository.getAllPhotos();
      final photo = photos.firstWhere(
        (p) => p.id == photoId,
        orElse: () => throw Exception('Photo not found'),
      );

      // Update caption with new timestamp
      final updatedPhoto = photo.copyWith(
        caption: caption,
        updatedAt: DateTime.now(),
        isSynced: false, // Mark as not synced to trigger sync
      );

      // Update photo
      await repository.updatePhoto(updatedPhoto);
    } catch (e) {
      rethrow;
    }
  }
}