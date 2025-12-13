import '../../../data/repositories/schedule_repository.dart';
import '../../entities/schedule_entity.dart';

class GetSchedulesUseCase {

  GetSchedulesUseCase(this.repository);
  final ScheduleRepository repository;

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
      final schedules = await repository.getSchedulesByDate(date);
      
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
      final schedules = await repository.getSchedulesByMonth(year, month);
      
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
      
      // Get all upcoming schedules from repository
      final allUpcoming = await repository.getUpcomingSchedules();
      
      // Filter by date range (within specified days)
      final schedules = allUpcoming
          .where((s) => s.dateTime.isBefore(future) || s.dateTime.isAtSameMomentAs(future))
          .toList();
      
      // Already sorted by repository
      print('✅ UseCase: Retrieved ${schedules.length} upcoming schedules');
      return schedules;
    } catch (e) {
      print('❌ UseCase: Failed to get upcoming schedules: $e');
      rethrow;
    }
  }

  /// Get today's schedules
  Future<List<ScheduleEntity>> executeToday() async => executeByDate(DateTime.now());
}