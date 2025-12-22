import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '/data/datasources/local/hive_database.dart';
import '/data/models/photo_model.dart';
import '/domain/entities/photo_entity.dart';

/// Repository for Photo data management
/// Implements offline-first approach with cloud sync capability
class PhotoRepository {
  /// Get the already opened Hive box for photos
  Box<PhotoModel> get _box => Hive.box<PhotoModel>(HiveDatabase.photoBoxName);

  /// Create a new photo (basic version - save to local DB only)
  /// Cloud upload akan ditambahkan nanti
  Future<void> createPhoto(PhotoEntity photo) async {
    final model = PhotoModel.fromEntity(photo);
    await _box.put(photo.id, model);
  }

  /// Get all photos
  Future<List<PhotoEntity>> getAllPhotos() async {
    final photos = _box.values
        .map((model) => model.toEntity())
        .toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken)); // Most recent first
    return photos;
  }

  /// Get photos for a specific date
  Future<List<PhotoEntity>> getPhotosByDate(DateTime date) async {
    return _box.values
        .map((model) => model.toEntity())
        .where((photo) {
          final photoDate = photo.dateTaken;
          return photoDate.year == date.year &&
              photoDate.month == date.month &&
              photoDate.day == date.day;
        })
        .toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
  }

  /// Get photos for a specific month
  Future<List<PhotoEntity>> getPhotosByMonth(int year, int month) async {
    return _box.values
        .map((model) => model.toEntity())
        .where((photo) =>
            photo.dateTaken.year == year && photo.dateTaken.month == month)
        .toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
  }

  /// Get photos by date range
  Future<List<PhotoEntity>> getPhotosByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _box.values
        .map((model) => model.toEntity())
        .where((photo) =>
            photo.dateTaken.isAfter(startDate.subtract(const Duration(days: 1))) &&
            photo.dateTaken.isBefore(endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
  }

  /// Get milestone photos only
  Future<List<PhotoEntity>> getMilestonePhotos() async {
    return _box.values
        .map((model) => model.toEntity())
        .where((photo) => photo.isMilestone)
        .toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
  }

  /// Get a specific photo by ID
  Future<PhotoEntity?> getPhotoById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  /// Update an existing photo
  Future<void> updatePhoto(PhotoEntity photo) async {
    final updated = photo.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    final model = PhotoModel.fromEntity(updated);
    await _box.put(photo.id, model);
  }

  /// Delete a photo
  Future<void> deletePhoto(String id) async {
    final model = _box.get(id);
    if (model != null) {
      final photo = model.toEntity();
      
      // Delete local file if exists
      if (photo.localPath != null) {
        try {
          final file = File(photo.localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Error deleting local file: $e');
        }
      }
      
      // Delete from database
      await _box.delete(id);
    }
  }

  /// Get recent photos (last N entries)
  Future<List<PhotoEntity>> getRecentPhotos(int count) async {
    final photos = _box.values
        .map((model) => model.toEntity())
        .toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
    return photos.take(count).toList();
  }

  /// Get unsynced photos for cloud sync
  Future<List<PhotoEntity>> getUnsyncedPhotos() async {
    return _box.values
        .map((model) => model.toEntity())
        .where((photo) => !photo.isSynced)
        .toList();
  }

  /// Mark photo as synced
  Future<void> markAsSynced(String id) async {
    final model = _box.get(id);
    if (model != null) {
      final photo = model.toEntity();
      final synced = photo.copyWith(isSynced: true);
      final updatedModel = PhotoModel.fromEntity(synced);
      await _box.put(id, updatedModel);
    }
  }

  /// Clear all photos (for testing or logout)
  Future<void> clearAll() async {
    // Delete all local files first
    for (final model in _box.values) {
      final photo = model.toEntity();
      if (photo.localPath != null) {
        try {
          final file = File(photo.localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Error deleting local file: $e');
        }
      }
    }
    
    // Clear database
    await _box.clear();
  }

  /// Close the box - tidak diperlukan karena box dikelola oleh HiveDatabase
  Future<void> close() async {
    // Box akan ditutup oleh HiveDatabase saat app terminate
    // Tidak perlu close di sini
  }
}