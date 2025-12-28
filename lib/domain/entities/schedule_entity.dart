/// Schedule Entity
/// Pure business logic object
/// 
/// Location: lib/domain/entities/schedule_entity.dart
library;

import 'package:hive/hive.dart';

part 'schedule_entity.g.dart';

/// Enum untuk kategori schedule
@HiveType(typeId: 11)
enum ScheduleCategory {
  @HiveField(0)
  feeding,
  
  @HiveField(1)
  sleep,
  
  @HiveField(2)
  health,
  
  @HiveField(3)
  milestone,
  
  @HiveField(4)
  other,
}

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
    this.hasReminder = true,
    this.reminderMinutes = 15,
    this.isCompleted = false,
    this.isSynced = false,
    this.isDeleted = false,  // 🆕 ADDED
    this.deletedAt,          // 🆕 ADDED
  });

  final String id;
  final String userId;
  final String title;
  final String? notes;
  final ScheduleCategory category;
  final DateTime dateTime;
  final bool hasReminder;
  final int reminderMinutes;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  
  /// 🆕 Soft delete fields
  final bool isDeleted;
  final DateTime? deletedAt;

  /// Check if schedule is in the past
  bool get isPast => dateTime.isBefore(DateTime.now());

  /// Check if schedule is today
  bool get isToday {
    final now = DateTime.now();
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

  /// Copy with method
  ScheduleEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? notes,
    ScheduleCategory? category,
    DateTime? dateTime,
    bool? hasReminder,
    int? reminderMinutes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,      // 🆕 ADDED
    DateTime? deletedAt,  // 🆕 ADDED
  }) => ScheduleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,  // 🆕 ADDED
      deletedAt: deletedAt ?? this.deletedAt,  // 🆕 ADDED
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
        other.hasReminder == hasReminder &&
        other.reminderMinutes == reminderMinutes &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.isDeleted == isDeleted &&        // 🆕 ADDED
        other.deletedAt == deletedAt;          // 🆕 ADDED
  }

  @override
  int get hashCode => id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        notes.hashCode ^
        category.hashCode ^
        dateTime.hashCode ^
        hasReminder.hashCode ^
        reminderMinutes.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSynced.hashCode ^
        isDeleted.hashCode ^      // 🆕 ADDED
        deletedAt.hashCode;       // 🆕 ADDED

  @override
  String toString() => 'ScheduleEntity(id: $id, title: $title, '
        'category: $category, dateTime: $dateTime, isDeleted: $isDeleted)';
}