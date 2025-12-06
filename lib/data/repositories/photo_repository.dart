import 'package:hive/hive.dart';
import '../domain/entities/photo_entity.dart';

/// Repository for Photo data management
/// Implements offline-first approach with cloud sync capability
class PhotoRepository {
  static const String _boxName = 'photos';
  Box<PhotoEntity>? _box;

  /// Initialize the Hive box for photos
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<PhotoEntity>(_boxName);
    }
  }

  /// Create a new photo entry
  Future<void> createPhoto(PhotoEntity photo) async {
    await init();
    await _box!.put(photo.id, photo);
  }

  /// Get all photos
  Future<List<PhotoEntity>> getAllPhotos() async {
    await init();
    final photos = _box!.values.toList();
    photos.sort((a, b) => b.dateTaken.compareTo(a.dateTaken)); // Most recent first
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
    final photos = _box!.values.where((photo) => photo.isMilestone).toList();
    photos.sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
    return photos;
  }

  /// Get photos for a specific date
  Future<List<PhotoEntity>> getPhotosByDate(DateTime date) async {
    await init();
    return _box!.values.where((photo) {
      return photo.dateTaken.year == date.year &&
          photo.dateTaken.month == date.month &&
          photo.dateTaken.day == date.day;
    }).toList();
  }

  /// Get photos for a date range
  Future<List<PhotoEntity>> getPhotosByDateRange(
      DateTime start, DateTime end) async {
    await init();
    final photos = _box!.values.where((photo) {
      return photo.dateTaken.isAfter(start.subtract(const Duration(days: 1))) &&
          photo.dateTaken.isBefore(end.add(const Duration(days: 1)));
    }).toList();
    
    photos.sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
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

  /// Delete a photo
  Future<void> deletePhoto(String id) async {
    await init();
    await _box!.delete(id);
  }

  /// Get photos that need to be uploaded
  Future<List<PhotoEntity>> getPhotosToUpload() async {
    await init();
    return _box!.values.where((photo) => !photo.isUploaded).toList();
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