/// Get Journals Use Case
/// 
/// Use case untuk mendapatkan list journals
/// Location: lib/domain/usecases/journal/get_journals.dart

import '../../../data/repositories/journal_repository.dart';
import '../../entities/journal_entity.dart';

class GetJournalsUseCase {
  final JournalRepository repository;

  GetJournalsUseCase(this.repository);

  /// Get all journals
  Future<List<JournalEntity>> execute() async {
    try {
      final journals = await repository.getAllJournals();
      print('✅ UseCase: Retrieved ${journals.length} journals');
      return journals;
    } catch (e) {
      print('❌ UseCase: Failed to get journals: $e');
      rethrow;
    }
  }

  /// Get journals by date range
  Future<List<JournalEntity>> executeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final journals = await repository.getJournalsByDateRange(
        startDate,
        endDate,
      );
      
      print('✅ UseCase: Retrieved ${journals.length} journals for date range');
      return journals;
    } catch (e) {
      print('❌ UseCase: Failed to get journals by date range: $e');
      rethrow;
    }
  }

  /// Get journals by month
  Future<List<JournalEntity>> executeByMonth(int year, int month) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
      
      final journals = await repository.getJournalsByDateRange(
        startOfMonth,
        endOfMonth,
      );
      
      print('✅ UseCase: Retrieved ${journals.length} journals for $year-$month');
      return journals;
    } catch (e) {
      print('❌ UseCase: Failed to get journals by month: $e');
      rethrow;
    }
  }

  /// Get recent journals
  Future<List<JournalEntity>> executeRecent({int limit = 10}) async {
    try {
      final journals = await repository.getAllJournals();
      
      // Take only recent entries
      final recent = journals.take(limit).toList();
      
      print('✅ UseCase: Retrieved ${recent.length} recent journals');
      return recent;
    } catch (e) {
      print('❌ UseCase: Failed to get recent journals: $e');
      rethrow;
    }
  }

  /// Check if journal exists for date
  Future<JournalEntity?> executeForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final journals = await repository.getJournalsByDateRange(
        startOfDay,
        endOfDay,
      );
      
      return journals.isNotEmpty ? journals.first : null;
    } catch (e) {
      print('❌ UseCase: Failed to check journal for date: $e');
      rethrow;
    }
  }
}