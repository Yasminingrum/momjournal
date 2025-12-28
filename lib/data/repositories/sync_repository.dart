// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/journal_entity.dart' as journal_entity;
import '../../domain/entities/photo_entity.dart' as photo_entity;
import '../../domain/entities/schedule_entity.dart' as schedule_entity;
import '../datasources/local/journal_local_datasource.dart';
import '../datasources/local/photo_local_datasource.dart';
import '../datasources/local/schedule_local_datasource.dart';
import '../datasources/remote/journal_remote_datasource.dart';
import '../datasources/remote/photo_remote_datasource.dart';
import '../datasources/remote/schedule_remote_datasource.dart';
import '../models/journal_model.dart';
import '../models/photo_model.dart';
import '../models/schedule_model.dart';

/// COMPLETE SYNC REPOSITORY WITH SOFT DELETE SUPPORT
/// 
/// Handles synchronization between local (Hive) and remote (Firestore)
/// for Schedule, Journal, and Photo data with soft delete support
/// 
/// Key Features:
/// - Syncs ALL items including soft-deleted ones
/// - Uses timestamp comparison for conflict resolution
/// - Maintains deletion status across devices
/// - Supports offline-first architecture

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncResult {
  const SyncResult({
    required this.schedulessynced,
    required this.journalsSynced,
    required this.photosSynced,
    required this.errors,
  });

  final int schedulessynced;
  final int journalsSynced;
  final int photosSynced;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => !hasErrors;
  int get totalSynced => schedulessynced + journalsSynced + photosSynced;
}

abstract class SyncRepository {
  Future<SyncResult> syncAll();
  Future<void> syncSchedules();
  Future<void> syncJournals();
  Future<void> syncPhotos();
}

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required this.scheduleLocal,
    required this.scheduleRemote,
    required this.journalLocal,
    required this.journalRemote,
    required this.photoLocal,
    required this.photoRemote,
  });

  final ScheduleLocalDataSource scheduleLocal;
  final ScheduleRemoteDatasource scheduleRemote;
  final JournalLocalDataSource journalLocal;
  final JournalRemoteDatasource journalRemote;
  final PhotoLocalDataSource photoLocal;
  final PhotoRemoteDatasource photoRemote;

  @override
  Future<SyncResult> syncAll() async {
    debugPrint('🔄 Starting full sync with soft delete support...');

    int schedulesCount = 0;
    int journalsCount = 0;
    int photosCount = 0;
    final List<String> errors = [];

    try {
      await syncSchedules();
      final schedules = scheduleLocal.getAllSchedules();
      schedulesCount = schedules.length;
      debugPrint('✅ Schedules synced: $schedulesCount items');
    } catch (e) {
      errors.add('Schedules: $e');
      debugPrint('❌ Schedule sync failed: $e');
    }

    try {
      await syncJournals();
      final journals = journalLocal.getAllJournals();
      journalsCount = journals.length;
      debugPrint('✅ Journals synced: $journalsCount items');
    } catch (e) {
      errors.add('Journals: $e');
      debugPrint('❌ Journal sync failed: $e');
    }

    try {
      await syncPhotos();
      final photos = photoLocal.getAllPhotos();
      photosCount = photos.length;
      debugPrint('✅ Photos synced: $photosCount items');
    } catch (e) {
      errors.add('Photos: $e');
      debugPrint('❌ Photo sync failed: $e');
    }

    final result = SyncResult(
      schedulessynced: schedulesCount,
      journalsSynced: journalsCount,
      photosSynced: photosCount,
      errors: errors,
    );

    if (errors.isEmpty) {
      debugPrint('✅ Full sync completed successfully: ${result.totalSynced} items');
    } else {
      debugPrint('⚠️ Sync completed with ${errors.length} error(s)');
    }

    return result;
  }

  // ==================== SCHEDULE SYNC ====================

  @override
  Future<void> syncSchedules() async {
    try {
      debugPrint('🔄 Syncing schedules with soft delete support...');

      // Get ALL items INCLUDING deleted from both sources
      final remoteEntities = await scheduleRemote.getAllSchedulesIncludingDeleted();
      final localModels = scheduleLocal.getAllSchedulesIncludingDeleted();

      // Convert to maps for easy lookup
      final remoteMap = {for (final s in remoteEntities) s.id: s};
      final localMap = {for (final s in localModels) s.id: s};

      // SYNC REMOTE → LOCAL
      for (final remoteEntity in remoteEntities) {
        final localModel = localMap[remoteEntity.id];

        if (localModel == null) {
          // Not in local, add it (even if deleted)
          final model = _scheduleEntityToModel(remoteEntity);
          await scheduleLocal.createSchedule(model);
          debugPrint('✅ Added schedule from remote: ${remoteEntity.id} (isDeleted: ${remoteEntity.isDeleted})');
        } else {
          // Exists in local, check timestamps
          if (remoteEntity.updatedAt.isAfter(localModel.updatedAt)) {
            // Remote is newer, update local
            final model = _scheduleEntityToModel(remoteEntity);
            await scheduleLocal.updateSchedule(model);
            debugPrint('✅ Updated schedule from remote: ${remoteEntity.id} (isDeleted: ${remoteEntity.isDeleted})');
          }
        }
      }

      // SYNC LOCAL → REMOTE
      for (final localModel in localModels) {
        final remoteEntity = remoteMap[localModel.id];

        if (remoteEntity == null) {
          // Not in remote, upload it (even if deleted)
          final entity = _scheduleModelToEntity(localModel);
          if (localModel.isDeleted) {
            // If already marked deleted, update on remote
            await scheduleRemote.updateSchedule(entity);
          } else {
            await scheduleRemote.createSchedule(entity);
          }
          debugPrint('✅ Uploaded schedule to remote: ${localModel.id} (isDeleted: ${localModel.isDeleted})');
        } else {
          // Exists in remote, check timestamps
          if (localModel.updatedAt.isAfter(remoteEntity.updatedAt)) {
            // Local is newer, update remote
            final entity = _scheduleModelToEntity(localModel);
            await scheduleRemote.updateSchedule(entity);
            debugPrint('✅ Updated schedule on remote: ${localModel.id} (isDeleted: ${localModel.isDeleted})');
          }
        }
      }

      debugPrint('✅ Schedules synced successfully');
    } catch (e) {
      debugPrint('❌ Schedule sync failed: $e');
      throw SyncException('Gagal sync schedules: $e');
    }
  }

  // ==================== JOURNAL SYNC ====================

  @override
  Future<void> syncJournals() async {
    try {
      debugPrint('🔄 Syncing journals with soft delete support...');

      // Get ALL items INCLUDING deleted from both sources
      final remoteEntities = await journalRemote.getAllJournalsIncludingDeleted();
      final localModels = journalLocal.getAllJournalsIncludingDeleted();

      // Convert to maps for easy lookup
      final remoteMap = {for (final j in remoteEntities) j.id: j};
      final localMap = {for (final j in localModels) j.id: j};

      // SYNC REMOTE → LOCAL
      for (final remoteEntity in remoteEntities) {
        final localModel = localMap[remoteEntity.id];

        if (localModel == null) {
          // Not in local, add it (even if deleted)
          final model = _journalEntityToModel(remoteEntity);
          await journalLocal.createJournal(model);
          debugPrint('✅ Added journal from remote: ${remoteEntity.id} (isDeleted: ${remoteEntity.isDeleted})');
        } else {
          // Exists in local, check timestamps
          if (remoteEntity.updatedAt.isAfter(localModel.updatedAt)) {
            // Remote is newer, update local
            final model = _journalEntityToModel(remoteEntity);
            await journalLocal.updateJournal(model);
            debugPrint('✅ Updated journal from remote: ${remoteEntity.id} (isDeleted: ${remoteEntity.isDeleted})');
          }
        }
      }

      // SYNC LOCAL → REMOTE
      for (final localModel in localModels) {
        final remoteEntity = remoteMap[localModel.id];
        final entity = _journalModelToEntity(localModel);

        if (remoteEntity == null) {
          // Not in remote, upload it (even if deleted)
          if (localModel.isDeleted) {
            // If already marked deleted, update on remote
            await journalRemote.updateJournal(entity);
          } else {
            await journalRemote.createJournal(entity);
          }
          debugPrint('✅ Uploaded journal to remote: ${localModel.id} (isDeleted: ${localModel.isDeleted})');
        } else {
          // Exists in remote, check timestamps
          if (localModel.updatedAt.isAfter(remoteEntity.updatedAt)) {
            // Local is newer, update remote
            await journalRemote.updateJournal(entity);
            debugPrint('✅ Updated journal on remote: ${localModel.id} (isDeleted: ${localModel.isDeleted})');
          }
        }
      }

      debugPrint('✅ Journals synced successfully');
    } catch (e) {
      debugPrint('❌ Journal sync failed: $e');
      throw SyncException('Gagal sync journals: $e');
    }
  }

  // ==================== PHOTO SYNC ====================

  @override
  Future<void> syncPhotos() async {
    try {
      debugPrint('🔄 Syncing photos with soft delete support...');

      // Get ALL items INCLUDING deleted from both sources
      final remoteEntities = await photoRemote.getAllPhotosIncludingDeleted();
      final localModels = photoLocal.getAllPhotosIncludingDeleted();

      // Convert to maps for easy lookup
      final remoteMap = {for (final p in remoteEntities) p.id: p};
      final localMap = {for (final p in localModels) p.id: p};

      // SYNC REMOTE → LOCAL
      for (final remoteEntity in remoteEntities) {
        final localModel = localMap[remoteEntity.id];

        if (localModel == null) {
          // Not in local, add it
          final model = _photoEntityToModel(remoteEntity);
          await photoLocal.createPhoto(model);
          debugPrint('✅ Added photo from remote: ${remoteEntity.id} (isDeleted: ${remoteEntity.isDeleted})');
        } else {
          // Exists in local, check timestamps
          if (remoteEntity.updatedAt.isAfter(localModel.updatedAt)) {
            // Remote is newer, update local
            final model = _photoEntityToModel(remoteEntity);
            await photoLocal.updatePhoto(model);
            debugPrint('✅ Updated photo from remote: ${remoteEntity.id} (isDeleted: ${remoteEntity.isDeleted})');
          }
        }
      }

      // SYNC LOCAL → REMOTE
      for (final localModel in localModels) {
        final remoteEntity = remoteMap[localModel.id];

        if (remoteEntity == null) {
          // Not in remote
          final entity = _photoModelToEntity(localModel);
          
          // Handle photo upload if needed
          if (!localModel.isDeleted && localModel.imageUrl == null && localModel.localFilePath != null) {
            // Photo not uploaded yet and not deleted, upload it
            try {
              final file = File(localModel.localFilePath!);
              if (await file.exists()) {
                final cloudUrl = await photoRemote.uploadPhoto(file, localModel.id);
                final updatedModel = localModel.copyWith(
                  imageUrl: cloudUrl,
                  uploadStatus: 'completed',
                  isSynced: true,
                );
                await photoLocal.updatePhoto(updatedModel);
                
                // Create metadata in Firestore
                final updatedEntity = _photoModelToEntity(updatedModel);
                await photoRemote.createPhotoMetadata(updatedEntity);
                debugPrint('✅ Photo uploaded and synced: ${localModel.id}');
              }
            } catch (e) {
              debugPrint('⚠️ Failed to upload photo ${localModel.id}: $e');
            }
          } else if (localModel.imageUrl != null || localModel.isDeleted) {
            // Photo already has cloudUrl or is deleted, just sync metadata
            if (localModel.isDeleted) {
              await photoRemote.updatePhoto(entity);
            } else {
              await photoRemote.createPhotoMetadata(entity);
            }
            debugPrint('✅ Photo metadata synced: ${localModel.id} (isDeleted: ${localModel.isDeleted})');
          }
        } else {
          // Exists in remote, check timestamps
          if (localModel.updatedAt.isAfter(remoteEntity.updatedAt)) {
            // Local is newer, update remote
            final entity = _photoModelToEntity(localModel);
            await photoRemote.updatePhoto(entity);
            debugPrint('✅ Updated photo on remote: ${localModel.id} (isDeleted: ${localModel.isDeleted})');
          }
        }
      }

      debugPrint('✅ Photos synced successfully');
    } catch (e) {
      debugPrint('❌ Photo sync failed: $e');
      throw SyncException('Gagal sync photos: $e');
    }
  }

  // ==================== SCHEDULE CONVERTERS ====================

  /// Convert ScheduleEntity (from remote) to ScheduleModel (for local)
  ScheduleModel _scheduleEntityToModel(schedule_entity.ScheduleEntity entity) => ScheduleModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.notes,
      category: _mapScheduleEntityCategoryToModel(entity.category),
      scheduledTime: entity.dateTime,
      reminderEnabled: entity.hasReminder,
      reminderMinutesBefore: entity.reminderMinutes,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: true,
      isDeleted: entity.isDeleted,      // 🆕 ADDED
      deletedAt: entity.deletedAt,      // 🆕 ADDED
    );

  /// Convert ScheduleModel (from local) to ScheduleEntity (for remote)
  schedule_entity.ScheduleEntity _scheduleModelToEntity(ScheduleModel model) => 
      schedule_entity.ScheduleEntity(
        id: model.id,
        userId: model.userId,
        title: model.title,
        notes: model.description,
        category: _mapScheduleModelCategoryToEntity(model.category),
        dateTime: model.scheduledTime,
        hasReminder: model.reminderEnabled,
        reminderMinutes: model.reminderMinutesBefore ?? 15,
        isCompleted: model.isCompleted,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        isSynced: model.isSynced,
        isDeleted: model.isDeleted,      // 🆕 ADDED
        deletedAt: model.deletedAt,      // 🆕 ADDED
      );

  /// Map entity category to model category
  ScheduleCategory _mapScheduleEntityCategoryToModel(
      schedule_entity.ScheduleCategory entityCat,) {
    switch (entityCat) {
      case schedule_entity.ScheduleCategory.feeding:
        return ScheduleCategory.feeding;
      case schedule_entity.ScheduleCategory.sleep:
        return ScheduleCategory.sleeping;
      case schedule_entity.ScheduleCategory.health:
        return ScheduleCategory.health;
      case schedule_entity.ScheduleCategory.milestone:
        return ScheduleCategory.milestone;
      case schedule_entity.ScheduleCategory.other:
        return ScheduleCategory.other;
    }
  }

  /// Map model category to entity category
  schedule_entity.ScheduleCategory _mapScheduleModelCategoryToEntity(
      ScheduleCategory modelCat,) {
    switch (modelCat) {
      case ScheduleCategory.feeding:
        return schedule_entity.ScheduleCategory.feeding;
      case ScheduleCategory.sleeping:
        return schedule_entity.ScheduleCategory.sleep;
      case ScheduleCategory.health:
        return schedule_entity.ScheduleCategory.health;
      case ScheduleCategory.milestone:
        return schedule_entity.ScheduleCategory.milestone;
      case ScheduleCategory.other:
        return schedule_entity.ScheduleCategory.other;
    }
  }

  // ==================== JOURNAL CONVERTERS ====================

  /// Convert JournalEntity (from remote) to JournalModel (for local)
  JournalModel _journalEntityToModel(journal_entity.JournalEntity entity) => 
      JournalModel(
        id: entity.id,
        userId: entity.userId,
        date: entity.date,
        mood: _mapJournalEntityMoodToModel(entity.mood),
        content: entity.content,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        isSynced: true,
        isDeleted: entity.isDeleted,      // 🆕 ADDED
        deletedAt: entity.deletedAt,      // 🆕 ADDED
      );

  /// Convert JournalModel (from local) to JournalEntity (for remote)
  journal_entity.JournalEntity _journalModelToEntity(JournalModel model) => 
      journal_entity.JournalEntity(
        id: model.id,
        userId: model.userId,
        date: model.date,
        mood: _mapJournalModelMoodToEntity(model.mood),
        content: model.content,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        isSynced: model.isSynced,
        isDeleted: model.isDeleted,      // 🆕 ADDED
        deletedAt: model.deletedAt,      // 🆕 ADDED
      );

  /// Map entity mood to model mood
  Mood _mapJournalEntityMoodToModel(journal_entity.MoodType entityMood) {
    switch (entityMood) {
      case journal_entity.MoodType.veryHappy:
        return Mood.veryHappy;
      case journal_entity.MoodType.happy:
        return Mood.happy;
      case journal_entity.MoodType.neutral:
        return Mood.neutral;
      case journal_entity.MoodType.sad:
        return Mood.sad;
      case journal_entity.MoodType.verySad:
        return Mood.verySad;
    }
  }

  /// Map model mood to entity mood
  journal_entity.MoodType _mapJournalModelMoodToEntity(Mood modelMood) {
    switch (modelMood) {
      case Mood.veryHappy:
        return journal_entity.MoodType.veryHappy;
      case Mood.happy:
        return journal_entity.MoodType.happy;
      case Mood.neutral:
        return journal_entity.MoodType.neutral;
      case Mood.sad:
        return journal_entity.MoodType.sad;
      case Mood.verySad:
        return journal_entity.MoodType.verySad;
    }
  }

  // ==================== PHOTO CONVERTERS ====================

  /// Convert PhotoEntity (from remote) to PhotoModel (for local)
  PhotoModel _photoEntityToModel(photo_entity.PhotoEntity entity) => PhotoModel(
      id: entity.id,
      userId: entity.userId,
      caption: entity.caption,
      date: entity.dateTaken,
      imageUrl: entity.cloudUrl,
      localFilePath: entity.localPath,
      isMilestone: entity.isMilestone,
      uploadStatus: entity.isUploaded ? 'completed' : 'pending',
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: true,
      isDeleted: entity.isDeleted,      // 🆕 ADDED
      deletedAt: entity.deletedAt,      // 🆕 ADDED
    );

  /// Convert PhotoModel (from local) to PhotoEntity (for remote)
  photo_entity.PhotoEntity _photoModelToEntity(PhotoModel model) => 
      photo_entity.PhotoEntity(
        id: model.id,
        userId: model.userId,
        caption: model.caption,
        dateTaken: model.date,
        localPath: model.localFilePath,
        cloudUrl: model.imageUrl,
        isMilestone: model.isMilestone,
        isUploaded: model.uploadStatus == 'completed',
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        isSynced: model.isSynced,
        isDeleted: model.isDeleted,      // 🆕 ADDED
        deletedAt: model.deletedAt,      // 🆕 ADDED
      );
}