import 'package:hive/hive.dart';

import '/data/datasources/local/hive_database.dart';
import '/data/models/journal_model.dart';
import '/domain/entities/journal_entity.dart';

/// Repository for Journal data management (Fixed Version)
/// Menggunakan JournalModel (data layer) alih-alih JournalEntity langsung
/// 
/// Pattern: Repository mengakses data layer (JournalModel dari Hive)
/// kemudian mengkonversi ke domain layer (JournalEntity) untuk business logic
class JournalRepository {
  /// Get the already opened Hive box for journals
  Box<JournalModel> get _box => Hive.box<JournalModel>(HiveDatabase.journalBoxName);

  /// Convert JournalModel to JournalEntity
  JournalEntity _modelToEntity(JournalModel model) => JournalEntity(
      id: model.id,
      userId: model.userId,
      date: model.date,
      mood: _convertMood(model.mood),
      content: model.content,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isSynced: model.isSynced,
    );

  /// Convert JournalEntity to JournalModel
  JournalModel _entityToModel(JournalEntity entity) => JournalModel(
      id: entity.id,
      userId: entity.userId,
      date: entity.date,
      mood: _convertMoodType(entity.mood),
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
    );

  /// Convert Mood (model) to MoodType (entity)
  MoodType _convertMood(Mood mood) {
    switch (mood) {
      case Mood.veryHappy:
        return MoodType.veryHappy;
      case Mood.happy:
        return MoodType.happy;
      case Mood.neutral:
        return MoodType.neutral;
      case Mood.sad:
        return MoodType.sad;
      case Mood.verySad:
        return MoodType.verySad;
    }
  }

  /// Convert MoodType (entity) to Mood (model)
  Mood _convertMoodType(MoodType moodType) {
    switch (moodType) {
      case MoodType.veryHappy:
        return Mood.veryHappy;
      case MoodType.happy:
        return Mood.happy;
      case MoodType.neutral:
        return Mood.neutral;
      case MoodType.sad:
        return Mood.sad;
      case MoodType.verySad:
        return Mood.verySad;
    }
  }

  /// Create a new journal entry
  Future<void> createJournal(JournalEntity journal) async {
    final model = _entityToModel(journal);
    await _box.put(model.id, model);
  }

  /// Get all journals
  Future<List<JournalEntity>> getAllJournals() async {
    final models = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    return models.map(_modelToEntity).toList();
  }

  /// Get journals for a specific date
  Future<List<JournalEntity>> getJournalsByDate(DateTime date) async {
    final models = _box.values.where((journal) {
      final journalDate = journal.date;
      return journalDate.year == date.year &&
          journalDate.month == date.month &&
          journalDate.day == date.day;
    }).toList();
    return models.map(_modelToEntity).toList();
  }

  /// Get journals for a specific month
  Future<List<JournalEntity>> getJournalsByMonth(int year, int month) async {
    final models = _box.values
        .where((journal) =>
            journal.date.year == year && journal.date.month == month,)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return models.map(_modelToEntity).toList();
  }

  /// Get journals by date range
  Future<List<JournalEntity>> getJournalsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = _box.values
        .where((journal) =>
            journal.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            journal.date
                .isBefore(endDate.add(const Duration(days: 1))),)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return models.map(_modelToEntity).toList();
  }

  /// Get journals by mood
  Future<List<JournalEntity>> getJournalsByMood(MoodType mood) async {
    final modelMood = _convertMoodType(mood);
    final models = _box.values
        .where((journal) => journal.mood == modelMood)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return models.map(_modelToEntity).toList();
  }

  /// Get a specific journal by ID
  Future<JournalEntity?> getJournalById(String id) async {
    final model = _box.get(id);
    return model != null ? _modelToEntity(model) : null;
  }

  /// Update an existing journal
  Future<void> updateJournal(JournalEntity journal) async {
    final updatedEntity = journal.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    final model = _entityToModel(updatedEntity);
    await _box.put(model.id, model);
  }

  /// Delete a journal
  Future<void> deleteJournal(String id) async {
    await _box.delete(id);
  }

  /// Get mood statistics
  Future<Map<MoodType, int>> getMoodStats() async {
    final stats = <MoodType, int>{
      MoodType.veryHappy: 0,
      MoodType.happy: 0,
      MoodType.neutral: 0,
      MoodType.sad: 0,
      MoodType.verySad: 0,
    };

    for (final model in _box.values) {
      final moodType = _convertMood(model.mood);
      stats[moodType] = (stats[moodType] ?? 0) + 1;
    }

    return stats;
  }

  /// Get recent journals (last N entries)
  Future<List<JournalEntity>> getRecentJournals(int count) async {
    final models = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return models.take(count).map(_modelToEntity).toList();
  }

  /// Get unsynced journals for cloud sync
  Future<List<JournalEntity>> getUnsyncedJournals() async {
    final models = _box.values.where((journal) => !journal.isSynced).toList();
    return models.map(_modelToEntity).toList();
  }

  /// Mark journal as synced
  Future<void> markAsSynced(String id) async {
    final model = _box.get(id);
    if (model != null) {
      final synced = model.copyWith(isSynced: true);
      await _box.put(id, synced);
    }
  }

  /// Clear all journals (for testing or logout)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Close the box - tidak diperlukan karena box dikelola oleh HiveDatabase
  Future<void> close() async {
    // Box akan ditutup oleh HiveDatabase saat app terminate
    // Tidak perlu close di sini
  }
}