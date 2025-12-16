import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '/data/repositories/journal_repository.dart';
import '/domain/entities/journal_entity.dart';

/// ViewModel for Journal management
/// Manages journal state and business logic using Provider pattern
class JournalProvider extends ChangeNotifier {
  JournalProvider();

  final JournalRepository _repository = JournalRepository();
  final Uuid _uuid = const Uuid();

  List<JournalEntity> _journals = [];
  Map<MoodType, int> _moodStats = {};
  DateTime _selectedDate = DateTime.now();
  MoodType? _selectedMood;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<JournalEntity> get journals => _journals;
  Map<MoodType, int> get moodStats => _moodStats;
  DateTime get selectedDate => _selectedDate;
  MoodType? get selectedMood => _selectedMood;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all journals
  Future<void> loadAllJournals() async {
    try {
      _setLoading(true);
      _journals = await _repository.getAllJournals();
      await loadMoodStats();
      _clearError();
    } catch (e) {
      _setError('Failed to load journals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load journals for selected date
  Future<void> loadJournalsForDate(DateTime date) async {
    try {
      _setLoading(true);
      _selectedDate = date;
      _journals = await _repository.getJournalsByDate(date);
      _clearError();
    } catch (e) {
      _setError('Failed to load journals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load journals for a month
  Future<void> loadJournalsForMonth(int year, int month) async {
    try {
      _setLoading(true);
      _journals = await _repository.getJournalsByMonth(year, month);
      _clearError();
    } catch (e) {
      _setError('Failed to load journals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load journals by date range
  Future<void> loadJournalsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _setLoading(true);
      _journals = await _repository.getJournalsByDateRange(startDate, endDate);
      _clearError();
    } catch (e) {
      _setError('Failed to load journals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Filter by mood
  Future<void> filterByMood(MoodType? mood) async {
    try {
      _setLoading(true);
      _selectedMood = mood;

      if (mood == null) {
        await loadAllJournals();
      } else {
        _journals = await _repository.getJournalsByMood(mood);
      }
      _clearError();
    } catch (e) {
      _setError('Failed to filter journals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load mood statistics
  Future<void> loadMoodStats() async {
    try {
      _moodStats = await _repository.getMoodStats();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load mood stats: $e');
    }
  }

  /// Load today's journal entry
  Future<void> loadTodayEntry() async {
    try {
      final today = DateTime.now();
      await _repository.getJournalsByDate(today);
      // Just load for state, main list not affected
      notifyListeners();
    } catch (e) {
      _setError('Failed to load today entry: $e');
    }
  }

  /// Load weekly mood statistics
  Future<void> loadWeeklyMoodStats() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final weeklyJournals = await _repository.getJournalsByDateRange(
        weekAgo,
        now,
      );
      
      // Calculate mood stats for the week
      final stats = <MoodType, int>{
        MoodType.veryHappy: 0,
        MoodType.happy: 0,
        MoodType.neutral: 0,
        MoodType.sad: 0,
        MoodType.verySad: 0,
      };
      
      for (final journal in weeklyJournals) {
        stats[journal.mood] = (stats[journal.mood] ?? 0) + 1;
      }
      
      _moodStats = stats;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load weekly mood stats: $e');
    }
  }

  /// Create a new journal
  Future<bool> createJournal({
    required MoodType mood,
    required String content,
    DateTime? date,
    String? userId,
  }) async {
    try {
      _setLoading(true);

      final journal = JournalEntity(
        id: _uuid.v4(),
        userId: userId ?? 'default_user',
        date: date ?? DateTime.now(),
        mood: mood,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createJournal(journal);
      await loadAllJournals();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to create journal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing journal
  Future<bool> updateJournal(JournalEntity journal) async {
    try {
      _setLoading(true);
      await _repository.updateJournal(journal);
      await loadAllJournals();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update journal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a journal
  Future<bool> deleteJournal(String id) async {
    try {
      _setLoading(true);
      await _repository.deleteJournal(id);
      await loadAllJournals();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete journal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get recent journals
  Future<List<JournalEntity>> getRecentJournals(int count) async {
    try {
      return await _repository.getRecentJournals(count);
    } catch (e) {
      _setError('Failed to get recent journals: $e');
      return [];
    }
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadJournalsForDate(date);
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}