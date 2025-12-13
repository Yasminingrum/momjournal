/// Update Schedule Use Case
/// 
/// Use case untuk update schedule
/// Location: lib/domain/usecases/schedule/update_schedule.dart
library;

import '../../../core/errors/exceptions.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../entities/schedule_entity.dart';

class UpdateScheduleUseCase {

  UpdateScheduleUseCase(this.repository);
  final ScheduleRepository repository;

  Future<void> execute(ScheduleEntity schedule) async {
    try {
      // Validate schedule
      _validateSchedule(schedule);
      
      // Update schedule
      await repository.updateSchedule(schedule);
      
      print('✅ UseCase: Schedule updated successfully');
    } catch (e) {
      print('❌ UseCase: Failed to update schedule: $e');
      rethrow;
    }
  }

  void _validateSchedule(ScheduleEntity schedule) {
    if (schedule.id.isEmpty) {
      throw const ValidationException('Schedule ID tidak boleh kosong');
    }

    if (schedule.title.trim().isEmpty) {
      throw const ValidationException('Judul jadwal tidak boleh kosong');
    }

    if (schedule.title.trim().length < 3) {
      throw const ValidationException('Judul jadwal minimal 3 karakter');
    }
  }

  /// Toggle schedule completion
  Future<void> toggleCompletion(ScheduleEntity schedule) async {
    final updated = schedule.copyWith(
      isCompleted: !schedule.isCompleted,
    );
    
    await execute(updated);
  }
}