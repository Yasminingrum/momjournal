// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../models/schedule_model.dart';
import 'hive_database.dart';

/// Local data source untuk Schedule menggunakan Hive
/// 
/// Menyediakan CRUD operations dan query methods untuk jadwal
class ScheduleLocalDataSource {

  ScheduleLocalDataSource(this._hiveDatabase) {
    _scheduleBox = _hiveDatabase.scheduleBox;
  }
  final HiveDatabase _hiveDatabase;
  late final Box<ScheduleModel> _scheduleBox;

  // ==================== CREATE ====================

  /// Tambah schedule baru ke local database
  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      await _scheduleBox.put(schedule.id, schedule);
      debugPrint('✓ Schedule added to local DB: ${schedule.id}');
    } catch (e) {
      debugPrint('✗ Error adding schedule to local DB: $e');
      rethrow;
    }
  }

  /// Tambah multiple schedules sekaligus (bulk insert)
  Future<void> addSchedules(List<ScheduleModel> schedules) async {
    try {
      final Map<String, ScheduleModel> entries = {
        for (final schedule in schedules) schedule.id: schedule,
      };
      await _scheduleBox.putAll(entries);
      debugPrint('✓ ${schedules.length} schedules added to local DB');
    } catch (e) {
      debugPrint('✗ Error adding schedules to local DB: $e');
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get schedule by ID
  ScheduleModel? getScheduleById(String id) {
    try {
      return _scheduleBox.get(id);
    } catch (e) {
      debugPrint('✗ Error getting schedule by ID: $e');
      return null;
    }
  }

  /// Get semua schedules
  List<ScheduleModel> getAllSchedules() {
    try {
      return _scheduleBox.values.toList();
    } catch (e) {
      debugPrint('✗ Error getting all schedules: $e');
      return [];
    }
  }

  /// Get schedules untuk user tertentu
  List<ScheduleModel> getSchedulesByUserId(String userId) {
    try {
      return _scheduleBox.values
          .where((schedule) => schedule.userId == userId)
          .toList();
    } catch (e) {
      debugPrint('✗ Error getting schedules by user ID: $e');
      return [];
    }
  }

  /// Get schedules untuk tanggal tertentu
  List<ScheduleModel> getSchedulesByDate(DateTime date, String userId) {
    try {
      final targetDate = DateTime(date.year, date.month, date.day);

      return _scheduleBox.values.where((schedule) {
        if (schedule.userId != userId) {
          return false;
        }

        final scheduleDate = DateTime(
          schedule.scheduledTime.year,
          schedule.scheduledTime.month,
          schedule.scheduledTime.day,
        );

        return scheduleDate == targetDate;
      }).toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    } catch (e) {
      debugPrint('✗ Error getting schedules by date: $e');
      return [];
    }
  }

  /// Get schedules untuk bulan tertentu
  List<ScheduleModel> getSchedulesByMonth(
    int year,
    int month,
    String userId,
  ) {
    try {
      return _scheduleBox.values.where((schedule) {
        if (schedule.userId != userId) {
          return false;
        }
        return schedule.scheduledTime.year == year &&
            schedule.scheduledTime.month == month;
      }).toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    } catch (e) {
      debugPrint('✗ Error getting schedules by month: $e');
      return [];
    }
  }

  /// Get schedules by category
  List<ScheduleModel> getSchedulesByCategory(
    ScheduleCategory category,
    String userId,
  ) {
    try {
      return _scheduleBox.values
          .where((schedule) =>
              schedule.userId == userId && schedule.category == category,)
          .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    } catch (e) {
      debugPrint('✗ Error getting schedules by category: $e');
      return [];
    }
  }

  /// Get upcoming schedules (belum lewat & belum completed)
  List<ScheduleModel> getUpcomingSchedules(String userId) {
    try {
      final now = DateTime.now();

      return _scheduleBox.values.where((schedule) {
        if (schedule.userId != userId) {
          return false;
        }
        return schedule.scheduledTime.isAfter(now) && !schedule.isCompleted;
      }).toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    } catch (e) {
      debugPrint('✗ Error getting upcoming schedules: $e');
      return [];
    }
  }

  /// Get past schedules (sudah lewat atau completed)
  List<ScheduleModel> getPastSchedules(String userId) {
    try {
      final now = DateTime.now();

      return _scheduleBox.values.where((schedule) {
        if (schedule.userId != userId) {
          return false;
        }
        return schedule.scheduledTime.isBefore(now) || schedule.isCompleted;
      }).toList()
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    } catch (e) {
      debugPrint('✗ Error getting past schedules: $e');
      return [];
    }
  }

  /// Get completed schedules
  List<ScheduleModel> getCompletedSchedules(String userId) {
    try {
      return _scheduleBox.values
          .where(
            (schedule) => schedule.userId == userId && schedule.isCompleted,
          )
          .toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    } catch (e) {
      debugPrint('✗ Error getting completed schedules: $e');
      return [];
    }
  }

  /// Get schedules with reminder enabled
  List<ScheduleModel> getSchedulesWithReminder(String userId) {
    try {
      return _scheduleBox.values
          .where((schedule) =>
              schedule.userId == userId && schedule.reminderEnabled,)
          .toList();
    } catch (e) {
      debugPrint('✗ Error getting schedules with reminder: $e');
      return [];
    }
  }

  /// Get today's schedules
  List<ScheduleModel> getTodaySchedules(String userId) {
    try {
      final now = DateTime.now();
      return getSchedulesByDate(now, userId);
    } catch (e) {
      debugPrint('✗ Error getting today schedules: $e');
      return [];
    }
  }

  /// Get schedules dalam date range
  List<ScheduleModel> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
    String userId,
  ) {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      return _scheduleBox.values.where((schedule) {
        if (schedule.userId != userId) {
          return false;
        }
        return schedule.scheduledTime.isAfter(start) &&
            schedule.scheduledTime.isBefore(end);
      }).toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    } catch (e) {
      debugPrint('✗ Error getting schedules by date range: $e');
      return [];
    }
  }

  // ==================== UPDATE ====================

  /// Update schedule
  Future<void> updateSchedule(ScheduleModel schedule) async {
    try {
      await _scheduleBox.put(schedule.id, schedule);
      debugPrint('✓ Schedule updated in local DB: ${schedule.id}');
    } catch (e) {
      debugPrint('✗ Error updating schedule in local DB: $e');
      rethrow;
    }
  }

  /// Mark schedule as completed
  Future<void> markAsCompleted(String id, {String? notes}) async {
    try {
      final schedule = _scheduleBox.get(id);
      if (schedule == null) {
        throw Exception('Schedule not found: $id');
      }

      final updatedSchedule = schedule.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        completionNotes: notes,
        updatedAt: DateTime.now(),
      );

      await _scheduleBox.put(id, updatedSchedule);
      debugPrint('✓ Schedule marked as completed: $id');
    } catch (e) {
      debugPrint('✗ Error marking schedule as completed: $e');
      rethrow;
    }
  }

  /// Toggle reminder
  Future<void> toggleReminder(String id) async {
    try {
      final schedule = _scheduleBox.get(id);
      if (schedule == null) {
        throw Exception('Schedule not found: $id');
      }

      final updatedSchedule = schedule.copyWith(
        reminderEnabled: !schedule.reminderEnabled,
        updatedAt: DateTime.now(),
      );

      await _scheduleBox.put(id, updatedSchedule);
      debugPrint('✓ Schedule reminder toggled: $id');
    } catch (e) {
      debugPrint('✗ Error toggling reminder: $e');
      rethrow;
    }
  }

  /// Update sync status
  Future<void> updateSyncStatus(String id, {required bool isSynced}) async {
    try {
      final schedule = _scheduleBox.get(id);
      if (schedule == null) {
        throw Exception('Schedule not found: $id');
      }

      final updatedSchedule = schedule.copyWith(isSynced: isSynced);
      await _scheduleBox.put(id, updatedSchedule);
    } catch (e) {
      debugPrint('✗ Error updating sync status: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete schedule by ID
  Future<void> deleteSchedule(String id) async {
    try {
      await _scheduleBox.delete(id);
      debugPrint('✓ Schedule deleted from local DB: $id');
    } catch (e) {
      debugPrint('✗ Error deleting schedule from local DB: $e');
      rethrow;
    }
  }

  /// Delete multiple schedules
  Future<void> deleteSchedules(List<String> ids) async {
    try {
      await _scheduleBox.deleteAll(ids);
      debugPrint('✓ ${ids.length} schedules deleted from local DB');
    } catch (e) {
      debugPrint('✗ Error deleting schedules from local DB: $e');
      rethrow;
    }
  }

  /// Delete all schedules for a user
  Future<void> deleteAllUserSchedules(String userId) async {
    try {
      final userSchedules = getSchedulesByUserId(userId);
      final ids = userSchedules.map((s) => s.id).toList();
      await deleteSchedules(ids);
      debugPrint('✓ All schedules deleted for user: $userId');
    } catch (e) {
      debugPrint('✗ Error deleting all user schedules: $e');
      rethrow;
    }
  }

  /// Delete completed schedules
  Future<void> deleteCompletedSchedules(String userId) async {
    try {
      final completedSchedules = getCompletedSchedules(userId);
      final ids = completedSchedules.map((s) => s.id).toList();
      await deleteSchedules(ids);
      debugPrint('✓ Completed schedules deleted for user: $userId');
    } catch (e) {
      debugPrint('✗ Error deleting completed schedules: $e');
      rethrow;
    }
  }

  /// Delete past schedules (older than specified days)
  Future<void> deletePastSchedules(String userId, {int olderThanDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

      final oldSchedules = _scheduleBox.values.where((schedule) {
        if (schedule.userId != userId) {
          return false;
        }
        return schedule.scheduledTime.isBefore(cutoffDate);
      }).toList();

      final ids = oldSchedules.map((s) => s.id).toList();
      await deleteSchedules(ids);
      debugPrint('✓ Old schedules deleted (older than $olderThanDays days)');
    } catch (e) {
      debugPrint('✗ Error deleting past schedules: $e');
      rethrow;
    }
  }

  // ==================== UTILITY ====================

  /// Get total count of schedules
  int getScheduleCount(String userId) => getSchedulesByUserId(userId).length;

  /// Get count by category
  int getCountByCategory(ScheduleCategory category, String userId) => getSchedulesByCategory(category, userId).length;

  /// Check if schedule exists
  bool scheduleExists(String id) => _scheduleBox.containsKey(id);

  /// Get unsynced schedules (untuk cloud sync)
  List<ScheduleModel> getUnsyncedSchedules(String userId) {
    try {
      return _scheduleBox.values
          .where((schedule) => schedule.userId == userId && !schedule.isSynced)
          .toList();
    } catch (e) {
      debugPrint('✗ Error getting unsynced schedules: $e');
      return [];
    }
  }

  /// Clear all schedules (untuk testing/development)
  Future<void> clearAll() async {
    try {
      await _scheduleBox.clear();
      debugPrint('✓ All schedules cleared from local DB');
    } catch (e) {
      debugPrint('✗ Error clearing schedules: $e');
      rethrow;
    }
  }

  /// Get all schedules INCLUDING deleted ones (for sync purposes)
  List<ScheduleModel> getAllSchedulesIncludingDeleted() => _scheduleBox.values.toList();

  /// Create schedule (if not exists yet, add this)
  Future<void> createSchedule(ScheduleModel schedule) async {
    await _scheduleBox.put(schedule.id, schedule);
  }

  /// Update schedule (if not exists yet, add this)
  Future<void> updateScheduleIfExists(ScheduleModel schedule) async {
    await _scheduleBox.put(schedule.id, schedule);
  }
}