// ignore_for_file: lines_longer_than_80_chars

class AppConstants {
  // App Info
  static const String appName = 'MomJournal';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Journey, Your Story';
  
  // API & Firebase
  static const String firebaseProjectId = 'momjournal-app';
  
  // Local Storage
  static const String hiveBoxSchedules = 'schedules';
  static const String hiveBoxJournals = 'journals';
  static const String hiveBoxPhotos = 'photos';
  static const String hiveBoxUser = 'user';
  static const String hiveBoxSettings = 'settings';
  
  // Limits
  static const int maxJournalCharacters = 500;
  static const int maxCaptionCharacters = 200;
  static const int photosPerPage = 20;
  
  // Notification IDs
  static const String notificationChannelId = 'momjournal_reminders';
  static const String notificationChannelName = 'Schedule Reminders';
  static const String notificationChannelDescription = 'Notifications for scheduled activities';
  
  // Notification ID base values
  static const int notificationIdSchedule = 1000000;
  static const int notificationIdJournal = 2000000;
  
  // Reminder Time Options (in minutes)
  static const List<int> reminderOptions = [5, 15, 30, 60];
  
  // Quiet Hours
  static const int quietHoursStart = 22; // 10 PM
  static const int quietHoursEnd = 6;    // 6 AM
  
  // Default Quiet Hours (for notification service)
  static const int defaultQuietHourStart = 22; // 10 PM
  static const int defaultQuietHourEnd = 6;    // 6 AM
  
  // Sync Settings
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxRetryAttempts = 3;
  
  // Cache Settings
  static const Duration cacheExpiry = Duration(days: 7);
  static const int maxCacheSize = 100; // MB
  
  // Cache management constants
  static const int cacheMaxAge = 7; // days
  static const int cacheSizeLimit = 104857600; // 100 MB in bytes
}