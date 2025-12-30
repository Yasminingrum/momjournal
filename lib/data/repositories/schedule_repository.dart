import 'package:hive/hive.dart';

import '/data/models/schedule_model.dart' as model;
import '/domain/entities/schedule_entity.dart' as entity;

/// Repository for Schedule data management
/// Implements offline-first approach with cloud sync capability
/// 
/// UPDATED: Uses String for category instead of enum
/// Location: lib/data/repositories/schedule_repository.dart
class ScheduleRepository {
  static const String _boxName = 'schedules';
  
  /// Get the already opened Hive box for schedules (using ScheduleModel)
  Box<model.ScheduleModel> get _box => Hive.box<model.ScheduleModel>(_boxName);

  /// Convert ScheduleModel to ScheduleEntity
  entity.ScheduleEntity _toEntity(model.ScheduleModel scheduleModel) => 
    entity.ScheduleEntity(
      id: scheduleModel.id,
      userId: scheduleModel.userId,
      title: scheduleModel.title,
      category: scheduleModel.category,  // ✅ Direct String usage
      dateTime: scheduleModel.scheduledTime,
      endDateTime: scheduleModel.endTime,  // 🆕 Multi-day support
      notes: scheduleModel.description,
      hasReminder: scheduleModel.reminderEnabled,
      reminderMinutes: scheduleModel.reminderMinutesBefore ?? 0,
      isCompleted: scheduleModel.isCompleted,
      createdAt: scheduleModel.createdAt,
      updatedAt: scheduleModel.updatedAt,
      isSynced: scheduleModel.isSynced,
      isDeleted: scheduleModel.isDeleted,
      deletedAt: scheduleModel.deletedAt,
    );

  /// Convert ScheduleEntity to ScheduleModel
  model.ScheduleModel _toModel(entity.ScheduleEntity scheduleEntity) => 
    model.ScheduleModel(
      id: scheduleEntity.id,
      userId: scheduleEntity.userId,
      title: scheduleEntity.title,
      category: scheduleEntity.category,  // ✅ Direct String usage
      scheduledTime: scheduleEntity.dateTime,
      endTime: scheduleEntity.endDateTime,  // 🆕 Multi-day support
      description: scheduleEntity.notes,
      reminderEnabled: scheduleEntity.hasReminder,
      reminderMinutesBefore: scheduleEntity.reminderMinutes,
      isCompleted: scheduleEntity.isCompleted,
      createdAt: scheduleEntity.createdAt,
      updatedAt: scheduleEntity.updatedAt,
      isSynced: scheduleEntity.isSynced,
      isDeleted: scheduleEntity.isDeleted,
      deletedAt: scheduleEntity.deletedAt,
    );

  /// Create a new schedule
  Future<void> createSchedule(entity.ScheduleEntity schedule) async {
    final scheduleModel = _toModel(schedule);
    await _box.put(scheduleModel.id, scheduleModel);
  }

  /// Get all schedules (EXCLUDING deleted ones)
  Future<List<entity.ScheduleEntity>> getAllSchedules() async => 
    _box.values
      .where((schedule) => !schedule.isDeleted)
      .map(_toEntity)
      .toList();

  /// Get schedules for a specific date (EXCLUDING deleted ones)
  Future<List<entity.ScheduleEntity>> getSchedulesByDate(DateTime date) async {
    final schedules = _box.values
      .where((schedule) =>
          !schedule.isDeleted &&
          schedule.scheduledTime.year == date.year &&
          schedule.scheduledTime.month == date.month &&
          schedule.scheduledTime.day == date.day,)
      .map(_toEntity)
      .toList()
      // Sort by time
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return schedules;
  }

  /// Get schedules for a specific month (EXCLUDING deleted ones)
  Future<List<entity.ScheduleEntity>> getSchedulesByMonth(
    int year, 
    int month,
  ) async => 
    _box.values
      .where((schedule) =>
          !schedule.isDeleted &&
          schedule.scheduledTime.year == year &&
          schedule.scheduledTime.month == month,)
      .map(_toEntity)
      .toList();

  /// Get schedules by category (EXCLUDING deleted ones)
  /// ✅ NOW USES String parameter instead of enum
  Future<List<entity.ScheduleEntity>> getSchedulesByCategory(
    String category,
  ) async => _box.values
      .where((schedule) => 
          !schedule.isDeleted &&
          schedule.category == category,)
      .map(_toEntity)
      .toList();

  /// Get upcoming schedules (EXCLUDING deleted ones)
  Future<List<entity.ScheduleEntity>> getUpcomingSchedules() async {
    final now = DateTime.now();
    final schedules = _box.values
      .where((schedule) =>
          !schedule.isDeleted &&
          schedule.scheduledTime.isAfter(now) && 
          !schedule.isCompleted,)
      .map(_toEntity)
      .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return schedules;
  }

  /// Get a specific schedule by ID (can get deleted ones for sync)
  Future<entity.ScheduleEntity?> getScheduleById(
    String id, {
    bool includeDeleted = false,
  }) async {
    final scheduleModel = _box.get(id);
    if (scheduleModel == null) {
      return null;
    }
    
    // If not including deleted and item is deleted, return null
    if (!includeDeleted && scheduleModel.isDeleted) {
      return null;
    }
    
    return _toEntity(scheduleModel);
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
    if (scheduleModel != null && !scheduleModel.isDeleted) {
      final updated = scheduleModel.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );
      await _box.put(id, updated);
    }
  }

  /// SOFT DELETE - Mark schedule as deleted instead of removing
  Future<void> deleteSchedule(String id) async {
    final scheduleModel = _box.get(id);
    if (scheduleModel != null) {
      final deleted = scheduleModel.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,  // Mark as unsynced to sync deletion
      );
      await _box.put(id, deleted);
    }
  }

  /// HARD DELETE - Actually remove from database (for permanent cleanup)
  Future<void> permanentlyDeleteSchedule(String id) async {
    await _box.delete(id);
  }

  /// Get ALL schedules including deleted ones (for sync purposes)
  Future<List<entity.ScheduleEntity>> getAllSchedulesIncludingDeleted() async => 
    _box.values.map(_toEntity).toList();

  /// Get unsynced schedules for cloud sync (INCLUDING deleted ones)
  Future<List<entity.ScheduleEntity>> getUnsyncedSchedules() async => 
    _box.values
      .where((schedule) => !schedule.isSynced)  // Include deleted ones for sync
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

  /// Get schedules for a date range (useful for multi-day events)
  /// 🆕 NEW METHOD for multi-day support
  Future<List<entity.ScheduleEntity>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async => _box.values
      .where((schedule) =>
          !schedule.isDeleted &&
          schedule.scheduledTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
          schedule.scheduledTime.isBefore(endDate.add(const Duration(days: 1))),)
      .map(_toEntity)
      .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  /// Get today's schedules (including multi-day events that span today)
  /// 🆕 ENHANCED for multi-day support
  Future<List<entity.ScheduleEntity>> getTodaySchedules() async => _box.values
      .where((schedule) {
        if (schedule.isDeleted) {
          return false;
        }
        
        final entity = _toEntity(schedule);
        // Check if today falls within the schedule's date range
        return entity.isToday;
      })
      .map(_toEntity)
      .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
}