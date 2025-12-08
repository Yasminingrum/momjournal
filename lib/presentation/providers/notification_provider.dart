/// Notification Provider
/// 
/// State management untuk notification settings
/// Location: lib/presentation/providers/notification_provider.dart

import 'package:flutter/foundation.dart';
import '../../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;

  // Settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 6, minute: 0);
  bool _quietHoursEnabled = true;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  TimeOfDay get quietHoursStart => _quietHoursStart;
  TimeOfDay get quietHoursEnd => _quietHoursEnd;
  bool get quietHoursEnabled => _quietHoursEnabled;

  /// Initialize settings
  Future<void> initialize() async {
    // TODO: Load settings from local storage
    notifyListeners();
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    
    if (!enabled) {
      await _notificationService.cancelAll();
      print('🔕 All notifications cancelled');
    } else {
      print('🔔 Notifications enabled');
    }
    
    // TODO: Save to local storage
  }

  /// Toggle sound
  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
    // TODO: Save to local storage
  }

  /// Toggle vibration
  void toggleVibration(bool enabled) {
    _vibrationEnabled = enabled;
    notifyListeners();
    // TODO: Save to local storage
  }

  /// Set quiet hours start
  void setQuietHoursStart(TimeOfDay time) {
    _quietHoursStart = time;
    notifyListeners();
    // TODO: Save to local storage
  }

  /// Set quiet hours end
  void setQuietHoursEnd(TimeOfDay time) {
    _quietHoursEnd = time;
    notifyListeners();
    // TODO: Save to local storage
  }

  /// Toggle quiet hours
  void toggleQuietHours(bool enabled) {
    _quietHoursEnabled = enabled;
    notifyListeners();
    // TODO: Save to local storage
  }

  /// Check if currently in quiet hours
  bool isInQuietHours() {
    if (!_quietHoursEnabled) return false;

    final now = TimeOfDay.now();
    final start = _quietHoursStart;
    final end = _quietHoursEnd;

    // Check if quiet hours span midnight
    if (start.hour > end.hour) {
      // Spans midnight (e.g., 22:00 - 06:00)
      return _isAfterOrEqual(now, start) || _isBefore(now, end);
    } else {
      // Same day (e.g., 13:00 - 15:00)
      return _isAfterOrEqual(now, start) && _isBefore(now, end);
    }
  }

  bool _isAfterOrEqual(TimeOfDay time, TimeOfDay other) {
    return time.hour > other.hour ||
        (time.hour == other.hour && time.minute >= other.minute);
  }

  bool _isBefore(TimeOfDay time, TimeOfDay other) {
    return time.hour < other.hour ||
        (time.hour == other.hour && time.minute < other.minute);
  }

  /// Schedule notification for schedule
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!_notificationsEnabled) return;
    if (isInQuietHours()) return;

    await _notificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: id,
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(String id) async {
    await _notificationService.cancelNotification(id);
  }

  /// Show instant notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_notificationsEnabled) return;

    await _notificationService.showNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }
}