import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/journal_entity.dart';
import '../../domain/entities/photo_entity.dart';
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

/// HYBRID SYNC REPOSITORY
/// 
/// Handles the case where:
/// - Local datasources work with MODEL types (Hive)
/// - Remote datasources work with ENTITY types (Firestore)

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncResult {

  SyncResult({
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
    debugPrint('🔄 Starting full sync...');

    int schedulesCount = 0;
    int journalsCount = 0;
    int photosCount = 0;
    final List<String> errors = [];

    try {
      await syncSchedules();
      final schedules = scheduleLocal.getAllSchedules();
      schedulesCount = schedules.length;
    } catch (e) {
      errors.add('Schedules: $e');
      debugPrint('❌ Schedule sync failed: $e');
    }

    try {
      await syncJournals();
      final journals = journalLocal.getAllJournals();
      journalsCount = journals.length;
    } catch (e) {
      errors.add('Journals: $e');
      debugPrint('❌ Journal sync failed: $e');
    }

    try {
      await syncPhotos();
      final photos = photoLocal.getAllPhotos();
      photosCount = photos.length;
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
      debugPrint('✅ Full sync completed: ${result.totalSynced} items');
    } else {
      debugPrint('⚠️ Sync completed with errors: ${errors.length} errors');
    }

    return result;
  }

  @override
  Future<void> syncSchedules() async {
    try {
      debugPrint('🔄 Syncing schedules...');

      // Remote returns List<ScheduleEntity>
      final remoteEntities = await scheduleRemote.getAllSchedules();
      
      // Local returns List<ScheduleModel>
      final localModels = scheduleLocal.getAllSchedules();

      // Convert remote entities to models for comparison
      final remoteModels = remoteEntities.map<ScheduleModel>(_entityToModel).toList();

      // Create maps
      final remoteMap = {for (final s in remoteModels) s.id: s};
      final localMap = {for (final s in localModels) s.id: s};

      // Sync remote -> local (Entity → Model)
      for (final remoteModel in remoteModels) {
        final localModel = localMap[remoteModel.id];

        if (localModel == null) {
          await scheduleLocal.addSchedule(remoteModel);
        } else if (remoteModel.updatedAt.isAfter(localModel.updatedAt)) {
          await scheduleLocal.updateSchedule(remoteModel);
        }
      }

      // Sync local -> remote (Model → Entity)
      for (final localModel in localModels) {
        final remoteModel = remoteMap[localModel.id];

        if (remoteModel == null) {
          final entity = _modelToEntity(localModel);
          await scheduleRemote.createSchedule(entity);
        } else if (localModel.updatedAt.isAfter(remoteModel.updatedAt)) {
          final entity = _modelToEntity(localModel);
          await scheduleRemote.updateSchedule(entity);
        }
      }

      debugPrint('✅ Schedules synced successfully');
    } catch (e) {
      debugPrint('❌ Schedule sync failed: $e');
      throw SyncException('Gagal sync schedules: $e');
    }
  }

  @override
  Future<void> syncJournals() async {
    try {
      debugPrint('🔄 Syncing journals...');

      final remoteEntities = await journalRemote.getAllJournals();
      final localModels = journalLocal.getAllJournals();

      final remoteModels = remoteEntities.map(_journalEntityToModel).toList();

      final remoteMap = {for (final j in remoteModels) j.id: j};
      final localMap = {for (final j in localModels) j.id: j};

      // Sync remote -> local
      for (final remoteModel in remoteModels) {
        final localModel = localMap[remoteModel.id];

        if (localModel == null) {
          await journalLocal.createJournal(remoteModel);
        } else if (remoteModel.updatedAt.isAfter(localModel.updatedAt)) {
          await journalLocal.updateJournal(remoteModel);
        }
      }

      // Sync local -> remote
      for (final localModel in localModels) {
        final remoteModel = remoteMap[localModel.id];

        if (remoteModel == null) {
          final entity = _journalModelToEntity(localModel);
          await journalRemote.createJournal(entity);
        } else if (localModel.updatedAt.isAfter(remoteModel.updatedAt)) {
          final entity = _journalModelToEntity(localModel);
          await journalRemote.updateJournal(entity);
        }
      }

      debugPrint('✅ Journals synced successfully');
    } catch (e) {
      debugPrint('❌ Journal sync failed: $e');
      throw SyncException('Gagal sync journals: $e');
    }
  }

  @override
  Future<void> syncPhotos() async {
    try {
      debugPrint('🔄 Syncing photos...');

      final remoteEntities = await photoRemote.getAllPhotos();
      final localModels = photoLocal.getAllPhotos();

      final remoteModels = remoteEntities.map(_photoEntityToModel).toList();

      final remoteMap = {for (final p in remoteModels) p.id: p};
      final localMap = {for (final p in localModels) p.id: p};

      // Sync remote -> local
      for (final remoteModel in remoteModels) {
        final localModel = localMap[remoteModel.id];

        if (localModel == null) {
          await photoLocal.createPhoto(remoteModel);
        } else if (remoteModel.updatedAt.isAfter(localModel.updatedAt)) {
          await photoLocal.updatePhoto(remoteModel);
        }
      }

      // Sync local -> remote
      for (final localModel in localModels) {
        final remoteModel = remoteMap[localModel.id];

        final hasImageUrl = localModel.imageUrl != null && localModel.imageUrl!.isNotEmpty;

        if (remoteModel == null && hasImageUrl) {
          final entity = _photoModelToEntity(localModel);
          await photoRemote.createPhotoMetadata(entity);
        } else if (remoteModel != null &&
            localModel.updatedAt.isAfter(remoteModel.updatedAt)) {
          final entity = _photoModelToEntity(localModel);
          await photoRemote.updatePhoto(entity);
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
  ScheduleModel _entityToModel(schedule_entity.ScheduleEntity entity) => ScheduleModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.notes,
      category: _mapEntityCategoryToModel(entity.category),
      scheduledTime: entity.dateTime,
      reminderEnabled: entity.hasReminder,
      reminderMinutesBefore: entity.reminderMinutes,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: true,
    );

  /// Convert ScheduleModel (from local) to ScheduleEntity (for remote)
  schedule_entity.ScheduleEntity _modelToEntity(ScheduleModel model) => schedule_entity.ScheduleEntity(
      id: model.id,
      userId: model.userId,
      title: model.title,
      category: _mapCategoryToEntity(model.category),
      dateTime: model.scheduledTime,
      notes: model.description,
      hasReminder: model.reminderEnabled,
      reminderMinutes: model.reminderMinutesBefore,
      isCompleted: model.isCompleted,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

  // ==================== JOURNAL CONVERTERS ====================

  JournalModel _journalEntityToModel(JournalEntity entity) => JournalModel(
      id: entity.id,
      userId: entity.userId,
      date: entity.date,
      mood: _mapMoodToModel(entity.mood),
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: true, // From remote = already synced
    );

  JournalEntity _journalModelToEntity(JournalModel model) => JournalEntity(
      id: model.id,
      userId: model.userId,
      date: model.date,
      mood: _mapMoodToEntity(model.mood),
      content: model.content,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

  // ==================== PHOTO CONVERTERS ====================

  PhotoModel _photoEntityToModel(PhotoEntity entity) => PhotoModel(
      id: entity.id,
      userId: entity.userId,
      localFilePath: entity.localPath ?? '',
      imageUrl: entity.cloudUrl,
      caption: entity.caption,
      isMilestone: entity.isMilestone,
      date: entity.dateTaken,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: true, // From remote = already synced
      uploadStatus: 'completed', // From remote = already uploaded
    );

  PhotoEntity _photoModelToEntity(PhotoModel model) => PhotoEntity(
      id: model.id,
      userId: model.userId,
      localPath: model.localFilePath,
      cloudUrl: model.imageUrl,
      caption: model.caption,
      isMilestone: model.isMilestone,
      dateTaken: model.date,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

  // ==================== ENUM MAPPERS ====================

  schedule_entity.ScheduleCategory _mapCategoryToEntity(ScheduleCategory modelCategory) {
    switch (modelCategory) {
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

  ScheduleCategory _mapEntityCategoryToModel(schedule_entity.ScheduleCategory entityCategory) {
    switch (entityCategory) {
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

  MoodType _mapMoodToEntity(Mood modelMood) {
    switch (modelMood) {
      case Mood.veryHappy:
        return MoodType.veryHappy;
      case Mood.happy:
        return MoodType.happy;
      case Mood.neutral:
        return MoodType.neutral;
      case Mood.sad:
        return MoodType.sad;
      case Mood.verySad:
        return MoodType.verySad;
    }
  }

  Mood _mapMoodToModel(MoodType entityMood) {
    switch (entityMood) {
      case MoodType.veryHappy:
        return Mood.veryHappy;
      case MoodType.happy:
        return Mood.happy;
      case MoodType.neutral:
        return Mood.neutral;
      case MoodType.sad:
        return Mood.sad;
      case MoodType.verySad:
        return Mood.verySad;
    }
  }
}