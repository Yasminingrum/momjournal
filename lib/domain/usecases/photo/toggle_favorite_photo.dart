import '../../../data/repositories/photo_repository.dart';

/// Use case untuk toggle status favorite foto
class ToggleFavoritePhotoUseCase {

  ToggleFavoritePhotoUseCase(this.repository);
  final PhotoRepository repository;

  Future<void> execute({
    required String photoId,
  }) async {
    try {
      // Get existing photo
      final photos = await repository.getAllPhotos();
      final photo = photos.firstWhere(
        (p) => p.id == photoId,
        orElse: () => throw Exception('Photo not found'),
      );

      // Toggle favorite status
      final updatedPhoto = photo.copyWith(
        isFavorite: !photo.isFavorite,
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