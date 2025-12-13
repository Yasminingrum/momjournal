import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '/data/datasources/local/hive_database.dart';
import '/data/repositories/schedule_repository.dart';
import '/domain/entities/schedule_entity.dart';

/// ViewModel for Schedule management
/// Manages schedule state and business logic using Provider pattern
class ScheduleProvider extends ChangeNotifier {

  ScheduleProvider(this._hiveDatabase);
  final ScheduleRepository _repository = ScheduleRepository();
  final Uuid _uuid = const Uuid();
  final HiveDatabase _hiveDatabase;

  List<ScheduleEntity> _schedules = [];
  List<ScheduleEntity> _todaySchedules = [];
  DateTime _selectedDate = DateTime.now();
  ScheduleCategory? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ScheduleEntity> get schedules => _schedules;
  List<ScheduleEntity> get todaySchedules => _todaySchedules;
  DateTime get selectedDate => _selectedDate;
  ScheduleCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize provider
  Future<void> init() async {
    await _repository.init();
    await loadAllSchedules();
    await loadTodaySchedules();
  }

  /// Load all schedules
  Future<void> loadAllSchedules() async {
    try {
      _setLoading(true);
      _schedules = await _repository.getAllSchedules();
      _clearError();
    } catch (e) {
      _setError('Failed to load schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load schedules for today
  Future<void> loadTodaySchedules() async {
    try {
      _todaySchedules = await _repository.getSchedulesByDate(DateTime.now());
      notifyListeners();
    } catch (e) {
      _setError('Failed to load today\'s schedules: $e');
    }
  }

  /// Load schedules for selected date
  Future<void> loadSchedulesForDate(DateTime date) async {
    try {
      _setLoading(true);
      _selectedDate = date;
      _schedules = await _repository.getSchedulesByDate(date);
      _clearError();
    } catch (e) {
      _setError('Failed to load schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load schedules for a month
  Future<void> loadSchedulesForMonth(int year, int month) async {
    try {
      _setLoading(true);
      _schedules = await _repository.getSchedulesByMonth(year, month);
      _clearError();
    } catch (e) {
      _setError('Failed to load schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Filter by category
  Future<void> filterByCategory(ScheduleCategory? category) async {
    try {
      _setLoading(true);
      _selectedCategory = category;
      
      if (category == null) {
        await loadAllSchedules();
      } else {
        _schedules = await _repository.getSchedulesByCategory(category);
      }
      _clearError();
    } catch (e) {
      _setError('Failed to filter schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new schedule
  Future<bool> createSchedule({
    required String title,
    required ScheduleCategory category,
    required DateTime dateTime,
    String? notes,
    bool hasReminder = false,
    int? reminderMinutes,
    String? userId,
  }) async {
    try {
      _setLoading(true);
      
      final schedule = ScheduleEntity(
        id: _uuid.v4(),
        userId: userId ?? 'default_user',
        title: title,
        category: category,
        dateTime: dateTime,
        notes: notes,
        hasReminder: hasReminder,
        reminderMinutes: reminderMinutes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createSchedule(schedule);
      await loadAllSchedules();
      await loadTodaySchedules();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to create schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing schedule
  Future<bool> updateSchedule(ScheduleEntity schedule) async {
    try {
      _setLoading(true);
      await _repository.updateSchedule(schedule);
      await loadAllSchedules();
      await loadTodaySchedules();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mark schedule as completed
  Future<bool> markAsCompleted(String id) async {
    try {
      await _repository.markAsCompleted(id);
      await loadAllSchedules();
      await loadTodaySchedules();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to mark as completed: $e');
      return false;
    }
  }

  /// Delete a schedule
  Future<bool> deleteSchedule(String id) async {
    try {
      _setLoading(true);
      await _repository.deleteSchedule(id);
      await loadAllSchedules();
      await loadTodaySchedules();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get upcoming schedules
  Future<List<ScheduleEntity>> getUpcomingSchedules() async {
    try {
      return await _repository.getUpcomingSchedules();
    } catch (e) {
      _setError('Failed to get upcoming schedules: $e');
      return [];
    }
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadSchedulesForDate(date);
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