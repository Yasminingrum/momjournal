/// Create Schedule Use Case
/// 
/// Use case untuk membuat schedule baru
/// Location: lib/domain/usecases/schedule/create_schedule.dart

import '../../../data/repositories/schedule_repository.dart';
import '../../entities/schedule_entity.dart';
import '../../../core/errors/exceptions.dart';

class CreateScheduleUseCase {
  final ScheduleRepository repository;

  CreateScheduleUseCase(this.repository);

  Future<void> execute(ScheduleEntity schedule) async {
    try {
      // Validate schedule
      _validateSchedule(schedule);
      
      // Create schedule
      await repository.createSchedule(schedule);
      
      print('✅ UseCase: Schedule created successfully');
    } catch (e) {
      print('❌ UseCase: Failed to create schedule: $e');
      rethrow;
    }
  }

  void _validateSchedule(ScheduleEntity schedule) {
    if (schedule.title.trim().isEmpty) {
      throw ValidationException('Judul jadwal tidak boleh kosong');
    }

    if (schedule.title.trim().length < 3) {
      throw ValidationException('Judul jadwal minimal 3 karakter');
    }

    if (schedule.dateTime.isBefore(DateTime.now().subtract(const Duration(days: 365)))) {
      throw ValidationException('Tanggal jadwal tidak valid');
    }
  }
}