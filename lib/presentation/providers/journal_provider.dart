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
  JournalEntity? _todayEntry;
  Map<MoodType, int> _moodStats = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<JournalEntity> get journals => _journals;
  JournalEntity? get todayEntry => _todayEntry;
  Map<MoodType, int> get moodStats => _moodStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize provider
  Future<void> init() async {
    await _repository.init();
    await loadAllJournals();
    await loadTodayEntry();
    await loadWeeklyMoodStats();
  }

  /// Load all journals
  Future<void> loadAllJournals() async {
    try {
      _setLoading(true);
      _journals = await _repository.getAllJournals();
      _clearError();
    } catch (e) {
      _setError('Failed to load journals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load today's journal entry
  Future<void> loadTodayEntry() async {
    try {
      _todayEntry = await _repository.getJournalByDate(DateTime.now());
      notifyListeners();
    } catch (e) {
      _setError('Failed to load today\'s entry: $e');
    }
  }

  /// Load journals for date range
  Future<void> loadJournalsByDateRange(DateTime start, DateTime end) async {
    try {
      _setLoading(true);
      _journals = await _repository.getJournalsByDateRange(start, end);
      _clearError();
    } catch (e) {
      _setError('Failed to load journals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load mood statistics for this week
  Future<void> loadWeeklyMoodStats() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      _moodStats = await _repository.getMoodStats(startOfWeek, endOfWeek);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load mood stats: $e');
    }
  }

  /// Load mood statistics for a custom date range
  Future<void> loadMoodStats(DateTime start, DateTime end) async {
    try {
      _moodStats = await _repository.getMoodStats(start, end);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load mood stats: $e');
    }
  }

  /// Create a new journal entry
  Future<bool> createJournal({
    required MoodType mood,
    required String content,
    DateTime? date,
    String? userId,
  }) async {
    try {
      _setLoading(true);
      
      final journalDate = date ?? DateTime.now();
      
      // Check if entry already exists for this date
      final existing = await _repository.getJournalByDate(journalDate);
      if (existing != null) {
        _setError('Journal entry already exists for this date');
        return false;
      }

      final journal = JournalEntity(
        id: _uuid.v4(),
        userId: userId ?? 'default_user',
        date: journalDate,
        mood: mood,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createJournal(journal);
      await loadAllJournals();
      await loadTodayEntry();
      await loadWeeklyMoodStats();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to create journal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing journal entry
  Future<bool> updateJournal(JournalEntity journal) async {
    try {
      _setLoading(true);
      await _repository.updateJournal(journal);
      await loadAllJournals();
      await loadTodayEntry();
      await loadWeeklyMoodStats();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update journal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a journal entry
  Future<bool> deleteJournal(String id) async {
    try {
      _setLoading(true);
      await _repository.deleteJournal(id);
      await loadAllJournals();
      await loadTodayEntry();
      await loadWeeklyMoodStats();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete journal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get recent journal entries
  Future<List<JournalEntity>> getRecentJournals(int count) async {
    try {
      return await _repository.getRecentJournals(count);
    } catch (e) {
      _setError('Failed to get recent journals: $e');
      return [];
    }
  }

  /// Get journal by ID
  Future<JournalEntity?> getJournalById(String id) async {
    try {
      return await _repository.getJournalById(id);
    } catch (e) {
      _setError('Failed to get journal: $e');
      return null;
    }
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