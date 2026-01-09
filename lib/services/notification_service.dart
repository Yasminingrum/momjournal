import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '/core/constants/app_constants.dart';

/// Notification Service
/// Handles local push notifications for schedules and reminders
class NotificationService {
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;
  
  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    
    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // Initialize
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    // Create notification channel for Android
    await _createNotificationChannel();
    
    // Request permissions for Android 13+ and iOS
    await requestPermissions();
    
    _initialized = true;
  }
  
  /// Create notification channel (Android)
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
    }
  }
  
  /// Request permissions (iOS and Android 13+)
  Future<bool> requestPermissions() async {
    // For Android 13+ (API level 33+), request POST_NOTIFICATIONS permission
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      if (granted ?? false) {
        return true;
      }
    }
    
    // For iOS
    final iosImpl = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImpl != null) {
      final result = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    
    return true; // Default untuk platform lain
  }
  
  /// Show instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      _notificationDetails(),
      payload: payload,
    );
  }
  
  /// Schedule notification for specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  /// Schedule notification with reminder (X minutes before)
  Future<void> scheduleNotificationWithReminder({
    required int id,
    required String title,
    required String body,
    required DateTime eventTime,
    required int reminderMinutes,
    String? payload,
  }) async {
    final reminderTime = eventTime.subtract(Duration(minutes: reminderMinutes));
    
    // Only schedule if reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: reminderTime,
        payload: payload,
      );
    }
  }
  
  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async => _notifications.pendingNotificationRequests();
  
  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async => _initialized;
  
  /// Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }
  
  /// Get next instance of time
  tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
  
  /// Check if time is in quiet hours
  bool isQuietHours({
    int quietHourStart = AppConstants.defaultQuietHourStart,
    int quietHourEnd = AppConstants.defaultQuietHourEnd,
  }) {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    if (quietHourStart < quietHourEnd) {
      // Normal case (e.g., 22:00 to 6:00 next day)
      return currentHour >= quietHourStart || currentHour < quietHourEnd;
    } else {
      // Wraps around midnight (e.g., 23:00 to 1:00)
      return currentHour >= quietHourStart && currentHour < quietHourEnd;
    }
  }
  
  /// Get notification details
  NotificationDetails _notificationDetails() => const NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  
  /// Schedule notification for schedule entity
  Future<void> scheduleForScheduleEntity({
    required String scheduleId,
    required String title,
    required String description,
    required DateTime scheduleTime,
    required int reminderMinutes,
  }) async {
    // Use schedule ID hash as notification ID
    final notificationId = 
        scheduleId.hashCode % 1000000 + AppConstants.notificationIdSchedule;
    
    final reminderText = _getReminderText(reminderMinutes);
    
    await scheduleNotificationWithReminder(
      id: notificationId,
      title: '$title',
      body: '$reminderText\n$description',
      eventTime: scheduleTime,
      reminderMinutes: reminderMinutes,
      payload: '{"type":"schedule","id":"$scheduleId"}',
    );
  }
  
  /// Schedule notification for journal reminder
  Future<void> scheduleJournalReminder({
    required DateTime time,
  }) async {
    await scheduleDailyNotification(
      id: AppConstants.notificationIdJournal,
      title: 'Waktunya Journaling',
      body: 'Jangan lupa tulis jurnal hari ini!',
      time: time,
      payload: '{"type":"journal"}',
    );
  }
  
  /// Get reminder text based on minutes
  String _getReminderText(int minutes) {
    if (minutes < 60) {
      return '$minutes menit lagi';
    } else if (minutes < 1440) {
      final hours = (minutes / 60).floor();
      return '$hours jam lagi';
    } else {
      final days = (minutes / 1440).floor();
      return '$days hari lagi';
    }
  }
  
  /// Test notification (for debugging)
  Future<void> showTestNotification() async {
    await showNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification from MomJournal',
      payload: '{"type":"test"}',
    );
  }
}