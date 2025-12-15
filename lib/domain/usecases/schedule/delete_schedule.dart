/// Delete Schedule Use Case
/// 
/// Use case untuk menghapus schedule
/// Location: lib/domain/usecases/schedule/delete_schedule.dart
library;

import '../../../core/errors/exceptions.dart';
import '../../../data/repositories/schedule_repository.dart';

class DeleteScheduleUseCase {

  DeleteScheduleUseCase(this.repository);
  final ScheduleRepository repository;

  Future<void> execute(String scheduleId) async {
    try {
      if (scheduleId.isEmpty) {
        throw const ValidationException('Schedule ID tidak boleh kosong');
      }

      await repository.deleteSchedule(scheduleId);
    } catch (e) {
      rethrow;
    }
  }
}