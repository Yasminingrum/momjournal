/// Get Schedules Use Case
/// 
/// Use case untuk mendapatkan list schedules
/// Location: lib/domain/usecases/schedule/get_schedules.dart

import '../../../data/repositories/schedule_repository.dart';
import '../../entities/schedule_entity.dart';

class GetSchedulesUseCase {
  final ScheduleRepository repository;

  GetSchedulesUseCase(this.repository);

  /// Get all schedules
  Future<List<ScheduleEntity>> execute() async {
    try {
      final schedules = await repository.getAllSchedules();
      print('✅ UseCase: Retrieved ${schedules.length} schedules');
      return schedules;
    } catch (e) {
      print('❌ UseCase: Failed to get schedules: $e');
      rethrow;
    }
  }

  /// Get schedules by date
  Future<List<ScheduleEntity>> executeByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final schedules = await repository.getSchedulesByDateRange(
        startOfDay,
        endOfDay,
      );
      
      print('✅ UseCase: Retrieved ${schedules.length} schedules for ${date.toString()}');
      return schedules;
    } catch (e) {
      print('❌ UseCase: Failed to get schedules by date: $e');
      rethrow;
    }
  }

  /// Get schedules by month
  Future<List<ScheduleEntity>> executeByMonth(int year, int month) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
      
      final schedules = await repository.getSchedulesByDateRange(
        startOfMonth,
        endOfMonth,
      );
      
      print('✅ UseCase: Retrieved ${schedules.length} schedules for $year-$month');
      return schedules;
    } catch (e) {
      print('❌ UseCase: Failed to get schedules by month: $e');
      rethrow;
    }
  }

  /// Get upcoming schedules
  Future<List<ScheduleEntity>> executeUpcoming({int days = 7}) async {
    try {
      final now = DateTime.now();
      final future = now.add(Duration(days: days));
      
      final schedules = await repository.getSchedulesByDateRange(now, future);
      
      // Filter only incomplete schedules
      final upcoming = schedules
          .where((s) => !s.isCompleted && s.dateTime.isAfter(now))
          .toList();
      
      // Sort by date
      upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      print('✅ UseCase: Retrieved ${upcoming.length} upcoming schedules');
      return upcoming;
    } catch (e) {
      print('❌ UseCase: Failed to get upcoming schedules: $e');
      rethrow;
    }
  }

  /// Get today's schedules
  Future<List<ScheduleEntity>> executeToday() async {
    return executeByDate(DateTime.now());
  }
}