/// Create Journal Use Case
/// 
/// Use case untuk membuat journal entry baru
/// Location: lib/domain/usecases/journal/create_journal.dart

import '../../../data/repositories/journal_repository.dart';
import '../../entities/journal_entity.dart';
import '../../../core/errors/exceptions.dart';

class CreateJournalUseCase {
  final JournalRepository repository;

  CreateJournalUseCase(this.repository);

  Future<void> execute(JournalEntity journal) async {
    try {
      // Validate journal
      _validateJournal(journal);
      
      // Create journal
      await repository.createJournal(journal);
      
      print('✅ UseCase: Journal created successfully');
    } catch (e) {
      print('❌ UseCase: Failed to create journal: $e');
      rethrow;
    }
  }

  void _validateJournal(JournalEntity journal) {
    if (journal.content.trim().isEmpty) {
      throw ValidationException('Konten jurnal tidak boleh kosong');
    }

    if (journal.content.trim().length < 10) {
      throw ValidationException('Konten jurnal minimal 10 karakter');
    }

    if (journal.content.length > 500) {
      throw ValidationException('Konten jurnal maksimal 500 karakter');
    }
  }
}