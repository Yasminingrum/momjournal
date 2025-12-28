// ignore_for_file: lines_longer_than_80_chars

import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/journal_model.dart';


/// Local datasource for journal entries using Hive database
/// 
/// Provides CRUD operations for journal entries with support for:
/// - Create, read, update, delete operations
/// - Mood tracking and filtering
/// - Date-based queries
/// - Batch operations
/// - Data export
/// 
/// All operations are synchronous and optimized for offline-first usage
class JournalLocalDataSource {
  static const String _boxName = 'journals';
  late Box<JournalModel> _journalBox;

  /// Initialize the journal box
  /// Must be called before any other operations
  Future<void> init() async {
    try {
      _journalBox = await Hive.openBox<JournalModel>(_boxName);
    } catch (e) {
      throw CacheException(
        'Failed to initialize journal box: ${e.toString()}',
      );
    }
  }

  /// Check if the box is initialized
  bool get isInitialized => Hive.isBoxOpen(_boxName);

  // ===========================================================================
  // CREATE OPERATIONS
  // ===========================================================================

  /// Create a new journal entry
  /// 
  /// Stores the journal entry in Hive with its ID as the key
  /// Throws [CacheException] if the operation fails
  Future<void> createJournal(JournalModel journal) async {
    try {
      await _journalBox.put(journal.id, journal);
    } catch (e) {
      throw CacheException(
        'Failed to create journal: ${e.toString()}',
      );
    }
  }

  /// Create multiple journal entries in a batch
  /// 
  /// More efficient than calling createJournal multiple times
  /// Throws [CacheException] if the operation fails
  Future<void> createJournalsBatch(List<JournalModel> journals) async {
    try {
      final Map<String, JournalModel> journalMap = {
        for (final journal in journals) journal.id: journal,
      };
      await _journalBox.putAll(journalMap);
    } catch (e) {
      throw CacheException(
        'Failed to create journals batch: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // READ OPERATIONS
  // ===========================================================================

  /// Get a journal entry by ID
  /// 
  /// Returns null if the journal is not found
  /// Throws [CacheException] if the operation fails
  JournalModel? getJournalById(String id) {
    try {
      return _journalBox.get(id);
    } catch (e) {
      throw CacheException(
        'Failed to get journal: ${e.toString()}',
      );
    }
  }

  /// Get all journal entries
  /// 
  /// Returns an empty list if no journals are found
  /// Sorted by date in descending order (newest first)
  List<JournalModel> getAllJournals() {
    try {
      final journals = _journalBox.values.toList()
      
      // Sort by date descending (newest first)
      ..sort((a, b) => b.date.compareTo(a.date));
      
      return journals;
    } catch (e) {
      throw CacheException(
        'Failed to get all journals: ${e.toString()}',
      );
    }
  }

  /// Get journals within a date range
  /// 
  /// [startDate] - Start of the date range (inclusive)
  /// [endDate] - End of the date range (inclusive)
  /// 
  /// Returns journals sorted by date descending
  List<JournalModel> getJournalsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      // Normalize dates to start and end of day
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      final journals = _journalBox.values.where((journal) => journal.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
               journal.date.isBefore(end.add(const Duration(seconds: 1))),).toList()

      // Sort by date descending
      ..sort((a, b) => b.date.compareTo(a.date));

      return journals;
    } catch (e) {
      throw CacheException(
        'Failed to get journals by date range: ${e.toString()}',
      );
    }
  }

  /// Get journals for a specific month
  /// 
  /// [year] - Year of the month
  /// [month] - Month number (1-12)
  /// 
  /// Returns journals sorted by date descending
  List<JournalModel> getJournalsByMonth(int year, int month) {
    try {
      // Get first and last day of the month
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0, 23, 59, 59);

      return getJournalsByDateRange(firstDay, lastDay);
    } catch (e) {
      throw CacheException(
        'Failed to get journals by month: ${e.toString()}',
      );
    }
  }

  /// Get journals for a specific year
  /// 
  /// Returns journals sorted by date descending
  List<JournalModel> getJournalsByYear(int year) {
    try {
      final firstDay = DateTime(year, 1, 1);
      final lastDay = DateTime(year, 12, 31, 23, 59, 59);

      return getJournalsByDateRange(firstDay, lastDay);
    } catch (e) {
      throw CacheException(
        'Failed to get journals by year: ${e.toString()}',
      );
    }
  }

  /// Get journals filtered by mood
  /// 
  /// [mood] - Mood to filter by
  /// 
  /// Returns journals sorted by date descending
  List<JournalModel> getJournalsByMood(String mood) {
    try {
      final journals = _journalBox.values.where((journal) =>
        // Convert Mood enum to string for comparison
        journal.mood.toString().split('.').last.toLowerCase() == 
               mood.toLowerCase(),
      ).toList()

      // Sort by date descending
      ..sort((a, b) => b.date.compareTo(a.date));

      return journals;
    } catch (e) {
      throw CacheException(
        'Failed to get journals by mood: ${e.toString()}',
      );
    }
  }

  /// Search journals by content
  /// 
  /// [query] - Search query (case-insensitive)
  /// 
  /// Searches in content and tags
  /// Returns journals sorted by date descending
  List<JournalModel> searchJournals(String query) {
    try {
      if (query.isEmpty) {
        return getAllJournals();
      }

      final lowerQuery = query.toLowerCase();
      final journals = _journalBox.values.where((journal) {
        // Search in content
        final contentMatch = journal.content.toLowerCase().contains(lowerQuery);
        
        // Search in tags if they exist
        final tagsMatch = journal.tags?.any((tag) =>
          tag.toLowerCase().contains(lowerQuery),
        ) ?? false;

        return contentMatch || tagsMatch;
      }).toList()

      // Sort by date descending
      ..sort((a, b) => b.date.compareTo(a.date));

      return journals;
    } catch (e) {
      throw CacheException(
        'Failed to search journals: ${e.toString()}',
      );
    }
  }

  /// Get recent journals
  /// 
  /// [limit] - Maximum number of journals to return
  /// 
  /// Returns the most recent journals
  List<JournalModel> getRecentJournals({int limit = 10}) {
    try {
      final journals = getAllJournals();
      
      // Already sorted by date descending in getAllJournals
      return journals.take(limit).toList();
    } catch (e) {
      throw CacheException(
        'Failed to get recent journals: ${e.toString()}',
      );
    }
  }

  /// Check if a journal exists for a specific date
  /// 
  /// Returns true if at least one journal exists for the date
  bool hasJournalOnDate(DateTime date) {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      return _journalBox.values.any((journal) {
        final journalDate = DateTime(
          journal.date.year,
          journal.date.month,
          journal.date.day,
        );
        return journalDate.isAtSameMomentAs(dateOnly);
      });
    } catch (e) {
      throw CacheException(
        'Failed to check journal existence: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // UPDATE OPERATIONS
  // ===========================================================================

  /// Update an existing journal entry
  /// 
  /// Throws [CacheException] if the operation fails
  /// Throws [NotFoundException] if the journal doesn't exist
  Future<void> updateJournal(JournalModel journal) async {
    try {
      if (!_journalBox.containsKey(journal.id)) {
        throw NotFoundException(
          'Journal not found: ${journal.id}',
        );
      }
      
      await _journalBox.put(journal.id, journal);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to update journal: ${e.toString()}',
      );
    }
  }

  /// Update journal content
  /// 
  /// Updates only the content and updatedAt timestamp
  Future<void> updateJournalContent(String id, String content) async {
    try {
      final journal = getJournalById(id);
      if (journal == null) {
        throw NotFoundException(
          'Journal not found: $id',);
      }

      final updatedJournal = journal.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      );

      await _journalBox.put(id, updatedJournal);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to update journal content: ${e.toString()}',
      );
    }
  }

  /// Update journal mood
  /// 
  /// Updates only the mood and updatedAt timestamp
  /// [mood] - String representation of mood (e.g., 'happy', 'sad', 'veryHappy')
  Future<void> updateJournalMood(String id, String mood) async {
    try {
      final journal = getJournalById(id);
      if (journal == null) {
        throw NotFoundException(
          'Journal not found: $id',);
      }

      // Convert String to Mood enum
      final moodEnum = _stringToMood(mood);

      final updatedJournal = journal.copyWith(
        mood: moodEnum,
        updatedAt: DateTime.now(),
      );

      await _journalBox.put(id, updatedJournal);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to update journal mood: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // DELETE OPERATIONS
  // ===========================================================================

  /// Delete a journal entry by ID
  /// 
  /// Returns true if the journal was deleted, false if it didn't exist
  /// Throws [CacheException] if the operation fails
  Future<bool> deleteJournal(String id) async {
    try {
      if (!_journalBox.containsKey(id)) {
        return false;
      }
      
      await _journalBox.delete(id);
      return true;
    } catch (e) {
      throw CacheException(
        'Failed to delete journal: ${e.toString()}',
      );
    }
  }

  /// Delete multiple journals by IDs
  /// 
  /// Returns the number of journals deleted
  Future<int> deleteJournalsBatch(List<String> ids) async {
    try {
      int deletedCount = 0;
      
      for (final id in ids) {
        if (_journalBox.containsKey(id)) {
          await _journalBox.delete(id);
          deletedCount++;
        }
      }
      
      return deletedCount;
    } catch (e) {
      throw CacheException(
        'Failed to delete journals batch: ${e.toString()}',
      );
    }
  }

  /// Delete journals older than a specific date
  /// 
  /// Returns the number of journals deleted
  Future<int> deleteJournalsOlderThan(DateTime date) async {
    try {
      final oldJournals = _journalBox.values.where((journal) => journal.date.isBefore(date)).toList();

      int deletedCount = 0;
      for (final journal in oldJournals) {
        await _journalBox.delete(journal.id);
        deletedCount++;
      }

      return deletedCount;
    } catch (e) {
      throw CacheException(
        'Failed to delete old journals: ${e.toString()}',
      );
    }
  }

  /// Delete all journals
  /// 
  /// USE WITH CAUTION - This will delete all journal data
  /// Returns the number of journals deleted
  Future<int> deleteAllJournals() async {
    try {
      final count = _journalBox.length;
      await _journalBox.clear();
      return count;
    } catch (e) {
      throw CacheException(
        'Failed to delete all journals: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // STATISTICS & ANALYTICS
  // ===========================================================================

  /// Get total count of journals
  int getJournalCount() {
    try {
      return _journalBox.length;
    } catch (e) {
      throw CacheException(
        'Failed to get journal count: ${e.toString()}',
      );
    }
  }

  /// Get mood statistics
  /// 
  /// Returns a map of mood -> count
  Map<String, int> getMoodStatistics() {
    try {
      final moodCounts = <String, int>{};
      
      for (final journal in _journalBox.values) {
        // Convert Mood enum to string
        final moodString = journal.mood.toString().split('.').last;
        moodCounts[moodString] = (moodCounts[moodString] ?? 0) + 1;
      }
      
      return moodCounts;
    } catch (e) {
      throw CacheException(
        'Failed to get mood statistics: ${e.toString()}',
      );
    }
  }

  /// Get mood statistics for a date range
  Map<String, int> getMoodStatisticsForRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      final journals = getJournalsByDateRange(startDate, endDate);
      final moodCounts = <String, int>{};
      
      for (final journal in journals) {
        // Convert Mood enum to string
        final moodString = journal.mood.toString().split('.').last;
        moodCounts[moodString] = (moodCounts[moodString] ?? 0) + 1;
      }
      
      return moodCounts;
    } catch (e) {
      throw CacheException(
        'Failed to get mood statistics for range: ${e.toString()}',
      );
    }
  }

  /// Get journal count by month for a year
  /// 
  /// Returns a map of month (1-12) -> count
  Map<int, int> getMonthlyJournalCounts(int year) {
    try {
      final monthlyCounts = <int, int>{};
      
      // Initialize all months with 0
      for (int month = 1; month <= 12; month++) {
        monthlyCounts[month] = 0;
      }
      
      // Count journals for each month
      final yearJournals = getJournalsByYear(year);
      for (final journal in yearJournals) {
        monthlyCounts[journal.date.month] = 
          (monthlyCounts[journal.date.month] ?? 0) + 1;
      }
      
      return monthlyCounts;
    } catch (e) {
      throw CacheException(
        'Failed to get monthly journal counts: ${e.toString()}',
      );
    }
  }

  /// Get average mood score
  /// 
  /// Assumes moods have numeric values:
  /// very_happy = 5, happy = 4, neutral = 3, sad = 2, very_sad = 1
  /// 
  /// Returns null if no journals exist
  double? getAverageMoodScore() {
    try {
      final journals = getAllJournals();
      if (journals.isEmpty) {
        return null;
      }

      int totalScore = 0;
      for (final journal in journals) {
        // Convert Mood enum to string before passing to _moodToScore
        totalScore += _moodToScore(journal.mood.toString().split('.').last);
      }

      return totalScore / journals.length;
    } catch (e) {
      throw CacheException(
        'Failed to get average mood score: ${e.toString()}',
      );
    }
  }

  /// Convert mood string to numeric score
  int _moodToScore(String mood) {
    switch (mood.toLowerCase()) {
      case 'very_happy':
      case 'veryhappy':
        return 5;
      case 'happy':
        return 4;
      case 'neutral':
        return 3;
      case 'sad':
        return 2;
      case 'very_sad':
      case 'verysad':
        return 1;
      default:
        return 3; // Default to neutral
    }
  }

  /// Convert string to Mood enum
  /// 
  /// Accepts various string formats:
  /// - Exact enum name: 'veryHappy', 'happy', 'neutral', 'sad', 'verySad'
  /// - Snake case: 'very_happy', 'very_sad'
  /// - Lowercase: 'veryhappy', 'verysad'
  /// 
  /// Returns Mood.neutral as default if string doesn't match
  Mood _stringToMood(String moodString) {
    final normalized = moodString.toLowerCase().replaceAll('_', '');
    
    switch (normalized) {
      case 'veryhappy':
        return Mood.veryHappy;
      case 'happy':
        return Mood.happy;
      case 'neutral':
        return Mood.neutral;
      case 'sad':
        return Mood.sad;
      case 'verysad':
        return Mood.verySad;
      default:
        return Mood.neutral; // Default fallback
    }
  }

  // ===========================================================================
  // UTILITY OPERATIONS
  // ===========================================================================

  /// Get journals that need to be synced
  /// 
  /// Returns journals where isSynced is false
  List<JournalModel> getUnsyncedJournals() {
    try {
      final journals = _journalBox.values.where((journal) => !journal.isSynced).toList()

      // Sort by date ascending (oldest first for sync)
      ..sort((a, b) => a.date.compareTo(b.date));

      return journals;
    } catch (e) {
      throw CacheException(
        'Failed to get unsynced journals: ${e.toString()}',
      );
    }
  }

  /// Mark journal as synced
  Future<void> markJournalAsSynced(String id) async {
    try {
      final journal = getJournalById(id);
      if (journal == null) {
        throw NotFoundException(
          'Journal not found: $id',);
      }

      final syncedJournal = journal.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      );

      await _journalBox.put(id, syncedJournal);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(
        'Failed to mark journal as synced: ${e.toString()}',
      );
    }
  }

  /// Mark multiple journals as synced
  Future<void> markJournalsAsSynced(List<String> ids) async {
    try {
      for (final id in ids) {
        await markJournalAsSynced(id);
      }
    } catch (e) {
      throw CacheException(
        'Failed to mark journals as synced: ${e.toString()}',
      );
    }
  }

  /// Compact the journal box
  /// 
  /// Reclaims deleted space in the Hive box
  Future<void> compactBox() async {
    try {
      await _journalBox.compact();
    } catch (e) {
      throw CacheException(
        'Failed to compact journal box: ${e.toString()}',
      );
    }
  }

  /// Export all journals as JSON
  /// 
  /// Returns a list of journal data in JSON format
  List<Map<String, dynamic>> exportJournalsToJson() {
    try {
      return _journalBox.values.map((journal) => journal.toJson()).toList();
    } catch (e) {
      throw CacheException(
        'Failed to export journals: ${e.toString()}',
      );
    }
  }

  /// Close the journal box
  /// 
  /// Should be called when the datasource is no longer needed
  Future<void> close() async {
    try {
      if (_journalBox.isOpen) {
        await _journalBox.close();
      }
    } catch (e) {
      throw CacheException(
        'Failed to close journal box: ${e.toString()}',
      );
    }
  }

  /// Get all journals INCLUDING deleted ones (for sync purposes)
  List<JournalModel> getAllJournalsIncludingDeleted() => _journalBox.values.toList();

}