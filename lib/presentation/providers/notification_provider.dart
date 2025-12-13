library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {

  NotificationProvider({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;
  final NotificationService _notificationService;

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
    notifyListeners();
  }

  /// Toggle notifications
  Future<void> toggleNotifications({required bool enabled}) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    
    if (!enabled) {
      await _notificationService.cancelAllNotifications();
      if (kDebugMode) {
        print('🔕 All notifications cancelled');
      }
    } else {
      if (kDebugMode) {
        print('🔔 Notifications enabled');
      }
    }
    
  }

  /// Toggle sound
  void toggleSound({required bool enabled}) {
    _soundEnabled = enabled;
    notifyListeners();
  }

  /// Toggle vibration
  void toggleVibration({required bool enabled}) {
    _vibrationEnabled = enabled;
    notifyListeners();
  }

  /// Set quiet hours start
  void setQuietHoursStart(TimeOfDay time) {
    _quietHoursStart = time;
    notifyListeners();
  }

  /// Set quiet hours end
  void setQuietHoursEnd(TimeOfDay time) {
    _quietHoursEnd = time;
    notifyListeners();
  }

  /// Toggle quiet hours
  void toggleQuietHours({required bool enabled}) {
    _quietHoursEnabled = enabled;
    notifyListeners();
  }

  /// Check if currently in quiet hours
  bool isInQuietHours() {
    if (!_quietHoursEnabled) {
      return false;
    }

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

  bool _isAfterOrEqual(TimeOfDay time, TimeOfDay other) => time.hour > other.hour ||
        (time.hour == other.hour && time.minute >= other.minute);

  bool _isBefore(TimeOfDay time, TimeOfDay other) => time.hour < other.hour ||
        (time.hour == other.hour && time.minute < other.minute);

  /// Schedule notification for schedule
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_notificationsEnabled) {
      return;
    }
    if (isInQuietHours()) {
      return;
    }

    // Convert String id to int for notification service
    final notificationId = id.hashCode % 1000000;

    await _notificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: id,
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(String id) async {
    // Convert String id to int for notification service
    final notificationId = id.hashCode % 1000000;
    await _notificationService.cancelNotification(notificationId);
  }

  /// Show instant notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_notificationsEnabled) {
      return;
    }

    // Generate a unique id for instant notification
    final notificationId = DateTime.now().millisecondsSinceEpoch % 1000000;

    await _notificationService.showNotification(
      id: notificationId,
      title: title,
      body: body,
      payload: payload,
    );
  }
}