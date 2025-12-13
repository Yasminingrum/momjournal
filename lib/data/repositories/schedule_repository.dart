import 'package:hive/hive.dart';
import '/domain/entities/schedule_entity.dart';

/// Repository for Schedule data management
/// Implements offline-first approach with cloud sync capability
class ScheduleRepository {
  static const String _boxName = 'schedules';
  Box<ScheduleEntity>? _box;

  /// Initialize the Hive box for schedules
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<ScheduleEntity>(_boxName);
    }
  }

  /// Create a new schedule
  Future<void> createSchedule(ScheduleEntity schedule) async {
    await init();
    await _box!.put(schedule.id, schedule);
  }

  /// Get all schedules
  Future<List<ScheduleEntity>> getAllSchedules() async {
    await init();
    return _box!.values.toList();
  }

  /// Get schedules for a specific date
  Future<List<ScheduleEntity>> getSchedulesByDate(DateTime date) async {
    await init();
    final schedules = _box!.values.where((schedule) => schedule.dateTime.year == date.year &&
          schedule.dateTime.month == date.month &&
          schedule.dateTime.day == date.day,).toList()
    
    // Sort by time
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return schedules;
  }

  /// Get schedules for a specific month
  Future<List<ScheduleEntity>> getSchedulesByMonth(int year, int month) async {
    await init();
    return _box!.values.where((schedule) => schedule.dateTime.year == year &&
          schedule.dateTime.month == month,).toList();
  }

  /// Get schedules by category
  Future<List<ScheduleEntity>> getSchedulesByCategory(
      ScheduleCategory category,) async {
    await init();
    return _box!.values.where((schedule) => schedule.category == category).toList();
  }

  /// Get upcoming schedules
  Future<List<ScheduleEntity>> getUpcomingSchedules() async {
    await init();
    final now = DateTime.now();
    final schedules = _box!.values.where((schedule) => schedule.dateTime.isAfter(now) && !schedule.isCompleted).toList()
    
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return schedules;
  }

  /// Get a specific schedule by ID
  Future<ScheduleEntity?> getScheduleById(String id) async {
    await init();
    return _box!.get(id);
  }

  /// Update an existing schedule
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    await init();
    final updatedSchedule = schedule.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _box!.put(schedule.id, updatedSchedule);
  }

  /// Mark schedule as completed
  Future<void> markAsCompleted(String id) async {
    await init();
    final schedule = _box!.get(id);
    if (schedule != null) {
      final updated = schedule.copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
        isSynced: false,
      );
      await _box!.put(id, updated);
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String id) async {
    await init();
    await _box!.delete(id);
  }

  /// Get unsynced schedules for cloud sync
  Future<List<ScheduleEntity>> getUnsyncedSchedules() async {
    await init();
    return _box!.values.where((schedule) => !schedule.isSynced).toList();
  }

  /// Mark schedule as synced
  Future<void> markAsSynced(String id) async {
    await init();
    final schedule = _box!.get(id);
    if (schedule != null) {
      final synced = schedule.copyWith(isSynced: true);
      await _box!.put(id, synced);
    }
  }

  /// Clear all schedules (for testing or logout)
  Future<void> clearAll() async {
    await init();
    await _box!.clear();
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
  }
}