/// Delete Schedule Use Case
/// 
/// Use case untuk menghapus schedule
/// Location: lib/domain/usecases/schedule/delete_schedule.dart

import '../../../data/repositories/schedule_repository.dart';
import '../../../core/errors/exceptions.dart';

class DeleteScheduleUseCase {
  final ScheduleRepository repository;

  DeleteScheduleUseCase(this.repository);

  Future<void> execute(String scheduleId) async {
    try {
      if (scheduleId.isEmpty) {
        throw ValidationException('Schedule ID tidak boleh kosong');
      }

      await repository.deleteSchedule(scheduleId);
      
      print('✅ UseCase: Schedule deleted successfully');
    } catch (e) {
      print('❌ UseCase: Failed to delete schedule: $e');
      rethrow;
    }
  }
}