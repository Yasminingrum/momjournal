import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '/data/repositories/schedule_repository.dart';
import '/domain/entities/schedule_entity.dart';

/// ViewModel for Schedule management
/// Manages schedule state and business logic using Provider pattern
/// 
/// UPDATED: Uses String for category instead of enum
/// Location: lib/presentation/providers/schedule_provider.dart
class ScheduleProvider extends ChangeNotifier {

  ScheduleProvider();
  final ScheduleRepository _repository = ScheduleRepository();
  final Uuid _uuid = const Uuid();

  List<ScheduleEntity> _schedules = [];
  List<ScheduleEntity> _todaySchedules = [];
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;  // ✅ Changed from ScheduleCategory? to String?
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ScheduleEntity> get schedules => _schedules;
  List<ScheduleEntity> get todaySchedules => _todaySchedules;
  DateTime get selectedDate => _selectedDate;
  String? get selectedCategory => _selectedCategory;  // ✅ Returns String? now
  bool get isLoading => _isLoading;
  String? get error => _error;

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
  /// ✅ NOW ACCEPTS String? instead of ScheduleCategory?
  Future<void> filterByCategory(String? category) async {
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
  /// ✅ PARAMETER CHANGED: category is now String
  Future<bool> createSchedule({
    required String title,
    required String category,  // ✅ Changed from ScheduleCategory to String
    required DateTime dateTime,
    DateTime? endDateTime,  // 🆕 Multi-day support
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
        category: category,  // ✅ Direct String usage
        dateTime: dateTime,
        endDateTime: endDateTime,  // 🆕 Multi-day support
        notes: notes,
        hasReminder: hasReminder,
        reminderMinutes: reminderMinutes ?? 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createSchedule(schedule);
      
      // Reload data yang sesuai dengan context
      await _reloadCurrentView();
      
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
      
      // Reload data yang sesuai dengan context
      await _reloadCurrentView();
      
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
      
      // Reload data yang sesuai dengan context
      await _reloadCurrentView();
      
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
      
      // Reload data yang sesuai dengan context
      await _reloadCurrentView();
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle schedule completion status
  Future<bool> toggleScheduleCompletion(String scheduleId) async {
    try {
      _setLoading(true);
      
      // Find schedule in list
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index == -1) {
        _setError('Schedule not found');
        return false;
      }

      final schedule = _schedules[index];
      
      // Toggle completion
      final updatedSchedule = schedule.copyWith(
        isCompleted: !schedule.isCompleted,
        updatedAt: DateTime.now(),
      );

      // Update in repository
      await _repository.updateSchedule(updatedSchedule);
      
      // Update in local list
      _schedules[index] = updatedSchedule;
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Mark schedule as complete
  Future<bool> markScheduleComplete(String scheduleId, {String? notes}) async {
    try {
      _setLoading(true);
      
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index == -1) {
        _setError('Schedule not found');
        return false;
      }

      final schedule = _schedules[index];
      
      final updatedSchedule = schedule.copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );

      await _repository.updateSchedule(updatedSchedule);
      _schedules[index] = updatedSchedule;
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Mark schedule as incomplete
  Future<bool> markScheduleIncomplete(String scheduleId) async {
    try {
      _setLoading(true);
      
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index == -1) {
        _setError('Schedule not found');
        return false;
      }

      final schedule = _schedules[index];
      
      final updatedSchedule = schedule.copyWith(
        isCompleted: false,
        updatedAt: DateTime.now(),
      );

      await _repository.updateSchedule(updatedSchedule);
      _schedules[index] = updatedSchedule;
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
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

  /// Reload schedules for current view context
  /// This ensures we only reload the data that's currently being displayed
  Future<void> _reloadCurrentView() async {
    // Always reload today's schedules for dashboard
    await loadTodaySchedules();
    
    // Reload schedules for the currently selected date in schedule screen
    // This prevents showing wrong schedules temporarily
    await loadSchedulesForDate(_selectedDate);
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