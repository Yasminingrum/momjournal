import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '/core/errors/exceptions.dart';
import '../../models/photo_model.dart';


/// Local datasource for photo metadata using Hive database

class PhotoLocalDataSource {
  static const String _boxName = 'photos';
  late Box<PhotoModel> _photoBox;

  /// Initialize the photo box
  /// Must be called before any other operations
  Future<void> init() async {
    try {
      _photoBox = await Hive.openBox<PhotoModel>(_boxName);
    } catch (e) {
      throw CacheException(
        'Failed to initialize photo box: ${e.toString()}',
      );
    }
  }

  /// Check if the box is initialized
  bool get isInitialized => Hive.isBoxOpen(_boxName);

  // ===========================================================================
  // CREATE OPERATIONS
  // ===========================================================================

  /// Create a new photo entry
  /// 
  /// Stores the photo metadata in Hive with its ID as the key
  /// Throws [CacheException] if the operation fails
  Future<void> createPhoto(PhotoModel photo) async {
    try {
      await _photoBox.put(photo.id, photo);
    } catch (e) {
      throw CacheException(
        'Failed to create photo: ${e.toString()}',
      );
    }
  }

  /// Create multiple photo entries in a batch
  /// 
  /// More efficient than calling createPhoto multiple times
  /// Throws [CacheException] if the operation fails
  Future<void> createPhotosBatch(List<PhotoModel> photos) async {
    try {
      final Map<String, PhotoModel> photoMap = {
        for (var photo in photos) photo.id: photo,
      };
      await _photoBox.putAll(photoMap);
    } catch (e) {
      throw CacheException(
        'Failed to create photos batch: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // READ OPERATIONS
  // ===========================================================================

  /// Get a photo by ID
  /// 
  /// Returns null if the photo is not found
  /// Throws [CacheException] if the operation fails
  PhotoModel? getPhotoById(String id) {
    try {
      return _photoBox.get(id);
    } catch (e) {
      throw CacheException(
        'Failed to get photo: ${e.toString()}',
      );
    }
  }

  /// Get all photos
  /// 
  /// Returns an empty list if no photos are found
  /// Sorted by date in descending order (newest first)
  List<PhotoModel> getAllPhotos() {
    try {
      final photos = _photoBox.values.toList()
      
      // Sort by date descending (newest first)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return photos;
    } catch (e) {
      throw CacheException(
        'Failed to get all photos: ${e.toString()}',
      );
    }
  }

  /// Get photos within a date range
  /// 
  /// [startDate] - Start of the date range (inclusive)
  /// [endDate] - End of the date range (inclusive)
  /// 
  /// Returns photos sorted by date descending
  List<PhotoModel> getPhotosByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      // Normalize dates to start and end of day
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      final photos = _photoBox.values.where((photo) => photo.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
               photo.createdAt.isBefore(end.add(const Duration(seconds: 1))),).toList()

      // Sort by date descending
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return photos;
    } catch (e) {
      throw CacheException(
        'Failed to get photos by date range: ${e.toString()}',
      );
    }
  }

  /// Get photos for a specific month
  /// 
  /// [year] - Year of the month
  /// [month] - Month number (1-12)
  /// 
  /// Returns photos sorted by date descending
  List<PhotoModel> getPhotosByMonth(int year, int month) {
    try {
      // Get first and last day of the month
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0, 23, 59, 59);

      return getPhotosByDateRange(firstDay, lastDay);
    } catch (e) {
      throw CacheException(
        'Failed to get photos by month: ${e.toString()}',
      );
    }
  }

  /// Get photos for a specific year
  /// 
  /// Returns photos sorted by date descending
  List<PhotoModel> getPhotosByYear(int year) {
    try {
      final firstDay = DateTime(year, 1, 1);
      final lastDay = DateTime(year, 12, 31, 23, 59, 59);

      return getPhotosByDateRange(firstDay, lastDay);
    } catch (e) {
      throw CacheException(
        'Failed to get photos by year: ${e.toString()}',
      );
    }
  }

  /// Get milestone photos only
  /// 
  /// Returns photos marked as milestones, sorted by date descending
  List<PhotoModel> getMilestonePhotos() {
    try {
      final photos = _photoBox.values.where((photo) {
        return photo.isMilestone;
      }).toList();

      // Sort by date descending
      photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return photos;
    } catch (e) {
      throw CacheException(
        'Failed to get milestone photos: ${e.toString()}',
      );
    }
  }

  /// Get photos filtered by tag
  /// 
  /// [tag] - Tag to filter by (case-insensitive)
  /// 
  /// Returns photos sorted by date descending
  List<PhotoModel> getPhotosByTag(String tag) {
    try {
      final lowerTag = tag.toLowerCase();
      final photos = _photoBox.values.where((photo) {
        return photo.tags?.any((t) => t.toLowerCase() == lowerTag) ?? false;
      }).toList();

      // Sort by date descending
      photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return photos;
    } catch (e) {
      throw CacheException(
        'Failed to get photos by tag: ${e.toString()}',
      );
    }
  }

  /// Search photos by caption
  /// 
  /// [query] - Search query (case-insensitive)
  /// 
  /// Searches in caption and tags
  /// Returns photos sorted by date descending
  List<PhotoModel> searchPhotos(String query) {
    try {
      if (query.isEmpty) {
        return getAllPhotos();
      }

      final lowerQuery = query.toLowerCase();
      final photos = _photoBox.values.where((photo) {
        // Search in caption
        final captionMatch = photo.caption?.toLowerCase().contains(lowerQuery) ?? false;
        
        // Search in tags if they exist
        final tagsMatch = photo.tags?.any((tag) =>
          tag.toLowerCase().contains(lowerQuery)
        ) ?? false;

        return captionMatch || tagsMatch;
      }).toList()

      // Sort by date descending
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return photos;
    } catch (e) {
      throw CacheException(
        'Failed to search photos: ${e.toString()}',
      );
    }
  }

  /// Get recent photos
  /// 
  /// [limit] - Maximum number of photos to return
  /// 
  /// Returns the most recent photos
  List<PhotoModel> getRecentPhotos({int limit = 20}) {
    try {
      final photos = getAllPhotos();
      
      // Already sorted by date descending in getAllPhotos
      return photos.take(limit).toList();
    } catch (e) {
      throw CacheException(
        'Failed to get recent photos: ${e.toString()}',
      );
    }
  }

  /// Get photos with pagination
  /// 
  /// [page] - Page number (0-indexed)
  /// [pageSize] - Number of photos per page
  /// 
  /// Returns a page of photos
  List<PhotoModel> getPhotosPaginated({
    required int page,
    int pageSize = 20,
  }) {
    try {
      final allPhotos = getAllPhotos();
      final startIndex = page * pageSize;
      
      if (startIndex >= allPhotos.length) {
        return [];
      }
      
      final endIndex = (startIndex + pageSize).clamp(0, allPhotos.length);
      
      return allPhotos.sublist(startIndex, endIndex);
    } catch (e) {
      throw CacheException(
        'Failed to get paginated photos: ${e.toString()}',
      );
    }
  }

  /// Get photo count for pagination
  int getPhotoCount() {
    try {
      return _photoBox.length;
    } catch (e) {
      throw CacheException(
        'Failed to get photo count: ${e.toString()}',
      );
    }
  }

  /// Calculate total pages for pagination
  int getTotalPages({int pageSize = 20}) {
    final totalPhotos = getPhotoCount();
    return (totalPhotos / pageSize).ceil();
  }

  // ===========================================================================
  // UPDATE OPERATIONS
  // ===========================================================================

  /// Update an existing photo entry
  /// 
  /// Throws [CacheException] if the operation fails
  /// Throws [NotFoundException] if the photo doesn't exist
  Future<void> updatePhoto(PhotoModel photo) async {
    try {
      if (!_photoBox.containsKey(photo.id)) {
        throw NotFoundException(
          'Photo not found: ${photo.id}',
        );
      }
      
      await _photoBox.put(photo.id, photo);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to update photo: ${e.toString()}',
      );
    }
  }

  /// Update photo caption
  /// 
  /// Updates only the caption and updatedAt timestamp
  Future<void> updatePhotoCaption(String id, String? caption) async {
    try {
      final photo = getPhotoById(id);
      if (photo == null) {
        throw NotFoundException(
          'Photo not found: $id',);
      }

      final updatedPhoto = photo.copyWith(
        caption: caption,
        updatedAt: DateTime.now(),
      );

      await _photoBox.put(id, updatedPhoto);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to update photo caption: ${e.toString()}',
      );
    }
  }

  /// Toggle milestone status
  /// 
  /// Updates the milestone flag and updatedAt timestamp
  Future<void> toggleMilestone(String id) async {
    try {
      final photo = getPhotoById(id);
      if (photo == null) {
        throw NotFoundException(
          'Photo not found: $id',);
      }

      final updatedPhoto = photo.copyWith(
        isMilestone: !photo.isMilestone,
        updatedAt: DateTime.now(),
      );

      await _photoBox.put(id, updatedPhoto);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to toggle milestone: ${e.toString()}',
      );
    }
  }

  /// Update photo tags
  /// 
  /// Replaces existing tags with new ones
  Future<void> updatePhotoTags(String id, List<String> tags) async {
    try {
      final photo = getPhotoById(id);
      if (photo == null) {
        throw NotFoundException(
          'Photo not found: $id',);
      }

      final updatedPhoto = photo.copyWith(
        tags: tags,
        updatedAt: DateTime.now(),
      );

      await _photoBox.put(id, updatedPhoto);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to update photo tags: ${e.toString()}',
      );
    }
  }

  /// Add a tag to a photo
  /// 
  /// Appends a new tag without removing existing ones
  Future<void> addPhotoTag(String id, String tag) async {
    try {
      final photo = getPhotoById(id);
      if (photo == null) {
        throw NotFoundException(
          'Photo not found: $id',);
      }

      final currentTags = photo.tags ?? [];
      
      // Don't add if tag already exists (case-insensitive)
      if (currentTags.any((t) => t.toLowerCase() == tag.toLowerCase())) {
        return;
      }

      final updatedTags = [...currentTags, tag];
      await updatePhotoTags(id, updatedTags);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to add photo tag: ${e.toString()}',
      );
    }
  }

  /// Remove a tag from a photo
  Future<void> removePhotoTag(String id, String tag) async {
    try {
      final photo = getPhotoById(id);
      if (photo == null) {
        throw NotFoundException(
          'Photo not found: $id',);
      }

      final currentTags = photo.tags ?? [];
      final updatedTags = currentTags.where(
        (t) => t.toLowerCase() != tag.toLowerCase(),
      ).toList();

      await updatePhotoTags(id, updatedTags);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to remove photo tag: ${e.toString()}',
      );
    }
  }

  /// Update cloud storage URL
  /// 
  /// Updates the cloudStorageUrl after successful upload
  Future<void> updateCloudStorageUrl(String id, String url) async {
    try {
      final photo = getPhotoById(id);
      if (photo == null) {
        throw NotFoundException(
          'Photo not found: $id',);
      }

      final updatedPhoto = photo.copyWith(
        imageUrl: url,
        updatedAt: DateTime.now(),
      );

      await _photoBox.put(id, updatedPhoto);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to update cloud storage URL: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // DELETE OPERATIONS
  // ===========================================================================

  /// Delete a photo by ID
  /// 
  /// Note: This only deletes the metadata. The actual image file should be
  /// deleted separately using StorageService
  /// 
  /// Returns true if the photo was deleted, false if it didn't exist
  /// Throws [CacheException] if the operation fails
  Future<bool> deletePhoto(String id) async {
    try {
      if (!_photoBox.containsKey(id)) {
        return false;
      }
      
      await _photoBox.delete(id);
      return true;
    } catch (e) {
      throw CacheException(
        'Failed to delete photo: ${e.toString()}',
      );
    }
  }

  /// Delete multiple photos by IDs
  /// 
  /// Returns the number of photos deleted
  Future<int> deletePhotosBatch(List<String> ids) async {
    try {
      int deletedCount = 0;
      
      for (final id in ids) {
        if (_photoBox.containsKey(id)) {
          await _photoBox.delete(id);
          deletedCount++;
        }
      }
      
      return deletedCount;
    } catch (e) {
      throw CacheException(
        'Failed to delete photos batch: ${e.toString()}',
      );
    }
  }

  /// Delete photos older than a specific date
  /// 
  /// Returns the number of photos deleted
  Future<int> deletePhotosOlderThan(DateTime date) async {
    try {
      final oldPhotos = _photoBox.values.where((photo) => photo.createdAt.isBefore(date)).toList();

      int deletedCount = 0;
      for (final photo in oldPhotos) {
        await _photoBox.delete(photo.id);
        deletedCount++;
      }

      return deletedCount;
    } catch (e) {
      throw CacheException(
        'Failed to delete old photos: ${e.toString()}',
      );
    }
  }

  /// Delete all photos
  /// 
  /// USE WITH CAUTION - This will delete all photo metadata
  /// Returns the number of photos deleted
  Future<int> deleteAllPhotos() async {
    try {
      final count = _photoBox.length;
      await _photoBox.clear();
      return count;
    } catch (e) {
      throw CacheException(
        'Failed to delete all photos: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // STATISTICS & ANALYTICS
  // ===========================================================================

  /// Get total count of photos
  int getTotalPhotoCount() {
    try {
      return _photoBox.length;
    } catch (e) {
      throw CacheException(
        'Failed to get photo count: ${e.toString()}',
      );
    }
  }

  /// Get milestone count
  int getMilestoneCount() {
    try {
      return _photoBox.values.where((photo) => photo.isMilestone).length;
    } catch (e) {
      throw CacheException(
        'Failed to get milestone count: ${e.toString()}',
      );
    }
  }

  /// Get photo counts by month for a year
  /// 
  /// Returns a map of month (1-12) -> count
  Map<int, int> getMonthlyPhotoCounts(int year) {
    try {
      final monthlyCounts = <int, int>{};
      
      // Initialize all months with 0
      for (int month = 1; month <= 12; month++) {
        monthlyCounts[month] = 0;
      }
      
      // Count photos for each month
      final yearPhotos = getPhotosByYear(year);
      for (final photo in yearPhotos) {
        monthlyCounts[photo.createdAt.month] = 
          (monthlyCounts[photo.createdAt.month] ?? 0) + 1;
      }
      
      return monthlyCounts;
    } catch (e) {
      throw CacheException(
        'Failed to get monthly photo counts: ${e.toString()}',
      );
    }
  }

  /// Get all unique tags
  /// 
  /// Returns a list of all unique tags used across all photos
  List<String> getAllTags() {
    try {
      final tagSet = <String>{};
      
      for (final photo in _photoBox.values) {
        if (photo.tags != null) {
          tagSet.addAll(photo.tags!);
        }
      }
      
      final tagList = tagSet.toList()
      ..sort(); // Sort alphabetically
      
      return tagList;
    } catch (e) {
      throw CacheException(
        'Failed to get all tags: ${e.toString()}',
      );
    }
  }

  /// Get tag usage statistics
  /// 
  /// Returns a map of tag -> count
  Map<String, int> getTagStatistics() {
    try {
      final tagCounts = <String, int>{};
      
      for (final photo in _photoBox.values) {
        if (photo.tags != null) {
          for (final tag in photo.tags!) {
            tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
          }
        }
      }
      
      return tagCounts;
    } catch (e) {
      throw CacheException(
        'Failed to get tag statistics: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // SYNC OPERATIONS
  // ===========================================================================

  /// Get photos that need to be synced
  /// 
  /// Returns photos where isSynced is false
  List<PhotoModel> getUnsyncedPhotos() {
    try {
      final photos = _photoBox.values.where((photo) => !photo.isSynced).toList()

      // Sort by date ascending (oldest first for sync)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return photos;
    } catch (e) {
      throw CacheException(
        'Failed to get unsynced photos: ${e.toString()}',
      );
    }
  }

  /// Mark photo as synced
  Future<void> markPhotoAsSynced(String id) async {
    try {
      final photo = getPhotoById(id);
      if (photo == null) {
        throw NotFoundException(
          'Photo not found: $id',);
      }

      final syncedPhoto = photo.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      );

      await _photoBox.put(id, syncedPhoto);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to mark photo as synced: ${e.toString()}',
      );
    }
  }

  /// Mark multiple photos as synced
  Future<void> markPhotosAsSynced(List<String> ids) async {
    try {
      for (final id in ids) {
        await markPhotoAsSynced(id);
      }
    } catch (e) {
      throw CacheException(
        'Failed to mark photos as synced: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // FILE MANAGEMENT HELPERS
  // ===========================================================================

  /// Check if local file exists
  /// 
  /// Verifies that the file referenced by the photo still exists
  Future<bool> doesLocalFileExist(String id) async {
    try {
      final photo = getPhotoById(id);
      if (photo == null) {
        return false;
      }

      final file = File(photo.localFilePath!);
      // ignore: avoid_slow_async_io
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get photos with missing local files
  /// 
  /// Returns photos whose local files no longer exist
  Future<List<PhotoModel>> getPhotosWithMissingFiles() async {
    try {
      final photosWithMissingFiles = <PhotoModel>[];
      
      for (final photo in _photoBox.values) {
        final fileExists = await doesLocalFileExist(photo.id);
        if (!fileExists) {
          photosWithMissingFiles.add(photo);
        }
      }
      
      return photosWithMissingFiles;
    } catch (e) {
      throw CacheException(
        'Failed to get photos with missing files: ${e.toString()}',
      );
    }
  }

  /// Clean orphaned photo metadata
  /// 
  /// Removes metadata for photos whose files no longer exist
  /// Returns the number of orphaned entries removed
  Future<int> cleanOrphanedMetadata() async {
    try {
      final orphanedPhotos = await getPhotosWithMissingFiles();
      
      int cleanedCount = 0;
      for (final photo in orphanedPhotos) {
        await _photoBox.delete(photo.id);
        cleanedCount++;
      }
      
      return cleanedCount;
    } catch (e) {
      throw CacheException(
        'Failed to clean orphaned metadata: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // UTILITY OPERATIONS
  // ===========================================================================

  /// Compact the photo box
  /// 
  /// Reclaims deleted space in the Hive box
  Future<void> compactBox() async {
    try {
      await _photoBox.compact();
    } catch (e) {
      throw CacheException(
        'Failed to compact photo box: ${e.toString()}',
      );
    }
  }

  /// Export all photos as JSON
  /// 
  /// Returns a list of photo data in JSON format
  List<Map<String, dynamic>> exportPhotosToJson() {
    try {
      return _photoBox.values.map((photo) => photo.toJson()).toList();
    } catch (e) {
      throw CacheException(
        'Failed to export photos: ${e.toString()}',
      );
    }
  }

  /// Get storage statistics
  /// 
  /// Returns information about photo storage usage
  Future<Map<String, dynamic>> getStorageStatistics() async {
    try {
      final allPhotos = getAllPhotos();
      int totalSize = 0;
      int localCount = 0;
      int cloudCount = 0;

      for (final photo in allPhotos) {
        // Count local files
        if (await doesLocalFileExist(photo.id)) {
          final file = File(photo.localFilePath!);
          totalSize += await file.length();
          localCount++;
        }

        // Count cloud files
        if (photo.imageUrl != null) {
          cloudCount++;
        }
      }

      return {
        'totalPhotos': allPhotos.length,
        'localPhotos': localCount,
        'cloudPhotos': cloudCount,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'milestoneCount': getMilestoneCount(),
      };
    } catch (e) {
      throw CacheException(
        'Failed to get storage statistics: ${e.toString()}',
      );
    }
  }

  /// Close the photo box
  /// 
  /// Should be called when the datasource is no longer needed
  Future<void> close() async {
    try {
      if (_photoBox.isOpen) {
        await _photoBox.close();
      }
    } catch (e) {
      throw CacheException(
        'Failed to close photo box: ${e.toString()}',
      );
    }
  }
}