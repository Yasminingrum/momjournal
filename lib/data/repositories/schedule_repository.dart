import 'package:hive/hive.dart';

import '/data/models/schedule_model.dart' as model;
import '/domain/entities/schedule_entity.dart' as entity;

/// Repository for Schedule data management
/// Implements offline-first approach with cloud sync capability
class ScheduleRepository {
  static const String _boxName = 'schedules';
  
  /// Get the already opened Hive box for schedules (using ScheduleModel)
  Box<model.ScheduleModel> get _box => Hive.box<model.ScheduleModel>(_boxName);

  /// Convert ScheduleModel to ScheduleEntity
  entity.ScheduleEntity _toEntity(model.ScheduleModel scheduleModel) => entity.ScheduleEntity(
      id: scheduleModel.id,
      userId: scheduleModel.userId,
      title: scheduleModel.title,
      category: _convertCategory(scheduleModel.category),
      dateTime: scheduleModel.scheduledTime,
      notes: scheduleModel.description,
      hasReminder: scheduleModel.reminderEnabled,
      reminderMinutes: scheduleModel.reminderMinutesBefore,
      isCompleted: scheduleModel.isCompleted,
      createdAt: scheduleModel.createdAt,
      updatedAt: scheduleModel.updatedAt,
      isSynced: scheduleModel.isSynced,
    );

  /// Convert ScheduleEntity to ScheduleModel
  model.ScheduleModel _toModel(entity.ScheduleEntity scheduleEntity) => model.ScheduleModel(
      id: scheduleEntity.id,
      userId: scheduleEntity.userId,
      title: scheduleEntity.title,
      category: _convertCategoryToModel(scheduleEntity.category),
      scheduledTime: scheduleEntity.dateTime,
      description: scheduleEntity.notes,
      reminderEnabled: scheduleEntity.hasReminder,
      reminderMinutesBefore: scheduleEntity.reminderMinutes,
      isCompleted: scheduleEntity.isCompleted,
      createdAt: scheduleEntity.createdAt,
      updatedAt: scheduleEntity.updatedAt,
      isSynced: scheduleEntity.isSynced,
    );

  /// Convert ScheduleModel.ScheduleCategory to ScheduleEntity.ScheduleCategory
  entity.ScheduleCategory _convertCategory(
      model.ScheduleCategory modelCategory,) {
    switch (modelCategory) {
      case model.ScheduleCategory.feeding:
        return entity.ScheduleCategory.feeding;
      case model.ScheduleCategory.sleeping:
        return entity.ScheduleCategory.sleep;
      case model.ScheduleCategory.health:
        return entity.ScheduleCategory.health;
      case model.ScheduleCategory.milestone:
        return entity.ScheduleCategory.milestone;
      case model.ScheduleCategory.other:
        return entity.ScheduleCategory.other;
    }
  }

  /// Convert ScheduleEntity.ScheduleCategory to ScheduleModel.ScheduleCategory
  model.ScheduleCategory _convertCategoryToModel(
      entity.ScheduleCategory entityCategory,) {
    switch (entityCategory) {
      case entity.ScheduleCategory.feeding:
        return model.ScheduleCategory.feeding;
      case entity.ScheduleCategory.sleep:
        return model.ScheduleCategory.sleeping;
      case entity.ScheduleCategory.health:
        return model.ScheduleCategory.health;
      case entity.ScheduleCategory.milestone:
        return model.ScheduleCategory.milestone;
      case entity.ScheduleCategory.other:
        return model.ScheduleCategory.other;
    }
  }

  /// Create a new schedule
  Future<void> createSchedule(entity.ScheduleEntity schedule) async {
    final scheduleModel = _toModel(schedule);
    await _box.put(scheduleModel.id, scheduleModel);
  }

  /// Get all schedules
  Future<List<entity.ScheduleEntity>> getAllSchedules() async => _box.values.map(_toEntity).toList();

  /// Get schedules for a specific date
  Future<List<entity.ScheduleEntity>> getSchedulesByDate(DateTime date) async {
    final schedules = _box.values
        .where((schedule) =>
            schedule.scheduledTime.year == date.year &&
            schedule.scheduledTime.month == date.month &&
            schedule.scheduledTime.day == date.day,)
        .map(_toEntity)
        .toList()
      // Sort by time
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return schedules;
  }

  /// Get schedules for a specific month
  Future<List<entity.ScheduleEntity>> getSchedulesByMonth(int year, int month) async => _box.values
        .where((schedule) =>
            schedule.scheduledTime.year == year &&
            schedule.scheduledTime.month == month,)
        .map(_toEntity)
        .toList();

  /// Get schedules by category
  Future<List<entity.ScheduleEntity>> getSchedulesByCategory(
      entity.ScheduleCategory category,) async {
    final modelCategory = _convertCategoryToModel(category);
    return _box.values
        .where((schedule) => schedule.category == modelCategory)
        .map(_toEntity)
        .toList();
  }

  /// Get upcoming schedules
  Future<List<entity.ScheduleEntity>> getUpcomingSchedules() async {
    final now = DateTime.now();
    final schedules = _box.values
        .where((schedule) =>
            schedule.scheduledTime.isAfter(now) && !schedule.isCompleted,)
        .map(_toEntity)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return schedules;
  }

  /// Get a specific schedule by ID
  Future<entity.ScheduleEntity?> getScheduleById(String id) async {
    final scheduleModel = _box.get(id);
    return scheduleModel != null ? _toEntity(scheduleModel) : null;
  }

  /// Update an existing schedule
  Future<void> updateSchedule(entity.ScheduleEntity schedule) async {
    final scheduleModel = _toModel(schedule);
    final updatedModel = scheduleModel.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _box.put(schedule.id, updatedModel);
  }

  /// Mark schedule as completed
  Future<void> markAsCompleted(String id) async {
    final scheduleModel = _box.get(id);
    if (scheduleModel != null) {
      final updated = scheduleModel.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );
      await _box.put(id, updated);
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String id) async {
    await _box.delete(id);
  }

  /// Get unsynced schedules for cloud sync
  Future<List<entity.ScheduleEntity>> getUnsyncedSchedules() async => _box.values
        .where((schedule) => !schedule.isSynced)
        .map(_toEntity)
        .toList();

  /// Mark schedule as synced
  Future<void> markAsSynced(String id) async {
    final scheduleModel = _box.get(id);
    if (scheduleModel != null) {
      final synced = scheduleModel.copyWith(isSynced: true);
      await _box.put(id, synced);
    }
  }

  /// Clear all schedules (for testing or logout)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Close the box - tidak diperlukan karena box dikelola oleh HiveDatabase
  Future<void> close() async {
    // Box akan ditutup oleh HiveDatabase saat app terminate
    // Tidak perlu close di sini
  }
}
