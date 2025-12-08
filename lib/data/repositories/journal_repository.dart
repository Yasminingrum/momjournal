import 'package:hive/hive.dart';
import '/domain/entities/journal_entity.dart';

/// Repository for Journal data management
/// Implements offline-first approach with cloud sync capability
class JournalRepository {
  static const String _boxName = 'journals';
  Box<JournalEntity>? _box;

  /// Initialize the Hive box for journals
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<JournalEntity>(_boxName);
    }
  }

  /// Create a new journal entry
  Future<void> createJournal(JournalEntity journal) async {
    await init();
    await _box!.put(journal.id, journal);
  }

  /// Get all journals
  Future<List<JournalEntity>> getAllJournals() async {
    await init();
    final journals = _box!.values.toList();
    journals.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    return journals;
  }

  /// Get journal for a specific date
  Future<JournalEntity?> getJournalByDate(DateTime date) async {
    await init();
    try {
      return _box!.values.firstWhere(
        (journal) =>
            journal.date.year == date.year &&
            journal.date.month == date.month &&
            journal.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get journals for a date range
  Future<List<JournalEntity>> getJournalsByDateRange(
      DateTime start, DateTime end,) async {
    await init();
    final journals = _box!.values.where((journal) {
      return journal.date.isAfter(start.subtract(const Duration(days: 1))) &&
          journal.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
    
    journals.sort((a, b) => b.date.compareTo(a.date));
    return journals;
  }

  /// Get a specific journal by ID
  Future<JournalEntity?> getJournalById(String id) async {
    await init();
    return _box!.get(id);
  }

  /// Update an existing journal
  Future<void> updateJournal(JournalEntity journal) async {
    await init();
    final updatedJournal = journal.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _box!.put(journal.id, updatedJournal);
  }

  /// Delete a journal
  Future<void> deleteJournal(String id) async {
    await init();
    await _box!.delete(id);
  }

  /// Get mood statistics for a date range
  Future<Map<MoodType, int>> getMoodStats(DateTime start, DateTime end) async {
    await init();
    final journals = await getJournalsByDateRange(start, end);
    
    final stats = <MoodType, int>{
      MoodType.veryHappy: 0,
      MoodType.happy: 0,
      MoodType.neutral: 0,
      MoodType.sad: 0,
      MoodType.verySad: 0,
    };

    for (var journal in journals) {
      stats[journal.mood] = (stats[journal.mood] ?? 0) + 1;
    }

    return stats;
  }

  /// Get recent journals (last N entries)
  Future<List<JournalEntity>> getRecentJournals(int count) async {
    await init();
    final journals = _box!.values.toList();
    journals.sort((a, b) => b.date.compareTo(a.date));
    return journals.take(count).toList();
  }

  /// Get unsynced journals for cloud sync
  Future<List<JournalEntity>> getUnsyncedJournals() async {
    await init();
    return _box!.values.where((journal) => !journal.isSynced).toList();
  }

  /// Mark journal as synced
  Future<void> markAsSynced(String id) async {
    await init();
    final journal = _box!.get(id);
    if (journal != null) {
      final synced = journal.copyWith(isSynced: true);
      await _box!.put(id, synced);
    }
  }

  /// Clear all journals (for testing or logout)
  Future<void> clearAll() async {
    await init();
    await _box!.clear();
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
  }
}