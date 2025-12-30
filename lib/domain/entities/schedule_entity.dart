library;

/// Domain entity untuk Schedule
/// Represents the business logic for a schedule/agenda
class ScheduleEntity {
  const ScheduleEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.endDateTime,
    this.hasReminder = true,
    this.reminderMinutes = 15,
    this.isCompleted = false,
    this.isSynced = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? notes;
  final String category;
  final DateTime dateTime;
  final DateTime? endDateTime;
  final bool hasReminder;
  final int reminderMinutes;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  
  /// Soft delete fields
  final bool isDeleted;
  final DateTime? deletedAt;

  /// Check if schedule is multi-day event
  bool get isMultiDay => endDateTime != null && 
      !_isSameDay(dateTime, endDateTime!);

  /// Get duration in days (for multi-day events)
  int get durationInDays {
    if (endDateTime == null) {
      return 1;
    }
    return endDateTime!.difference(dateTime).inDays + 1;
  }

  /// Check if schedule is in the past
  bool get isPast {
    final compareDate = endDateTime ?? dateTime;
    return compareDate.isBefore(DateTime.now());
  }

  /// Check if schedule is today
  bool get isToday {
    final now = DateTime.now();
    // For multi-day: check if today is within range
    if (isMultiDay) {
      final today = DateTime(now.year, now.month, now.day);
      final start = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final end = DateTime(endDateTime!.year, endDateTime!.month, endDateTime!.day);
      return !today.isBefore(start) && !today.isAfter(end);
    }
    // For single day: check exact date
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if schedule is upcoming
  bool get isUpcoming => !isPast && !isCompleted && !isDeleted;

  /// Get reminder time
  DateTime get reminderTime => dateTime.subtract(
    Duration(minutes: reminderMinutes),
  );

  /// Helper to check if two dates are same day
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Copy with method
  ScheduleEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? notes,
    String? category,
    DateTime? dateTime,
    DateTime? endDateTime,
    bool? hasReminder,
    int? reminderMinutes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    DateTime? deletedAt,
  }) => ScheduleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ScheduleEntity &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.notes == notes &&
        other.category == category &&
        other.dateTime == dateTime &&
        other.endDateTime == endDateTime &&
        other.hasReminder == hasReminder &&
        other.reminderMinutes == reminderMinutes &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.isDeleted == isDeleted &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        notes.hashCode ^
        category.hashCode ^
        dateTime.hashCode ^
        endDateTime.hashCode ^
        hasReminder.hashCode ^
        reminderMinutes.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSynced.hashCode ^
        isDeleted.hashCode ^
        deletedAt.hashCode;

  @override
  String toString() => 'ScheduleEntity(id: $id, title: $title, '
        'category: $category, dateTime: $dateTime, endDateTime: $endDateTime, isDeleted: $isDeleted)';
}