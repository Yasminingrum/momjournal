// ignore_for_file: lines_longer_than_80_chars

import 'package:hive/hive.dart';
import '../../domain/entities/schedule_entity.dart';

part 'schedule_model.g.dart';

/// Data model untuk Schedule/Agenda
/// 
/// Menyimpan informasi jadwal harian anak seperti
/// waktu makan, tidur, kontrol kesehatan, dll
@HiveType(typeId: 1)
class ScheduleModel extends HiveObject {

  ScheduleModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.category, 
    required this.scheduledTime, 
    required this.createdAt, 
    required this.updatedAt, 
    this.description,
    this.endTime,  // 🆕 For multi-day events
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 15,
    this.isCompleted = false,
    this.completedAt,
    this.completionNotes,
    this.isSynced = false,
    this.notificationId,
    this.isDeleted = false,
    this.deletedAt,
  });

  /// Factory constructor dari JSON (Firestore)
  /// 
  /// Handles null values safely to prevent type casting errors
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    // Helper function untuk safely parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is DateTime) {
        return value;
      }
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    return ScheduleModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Lainnya',  // 🔄 Changed to String
      scheduledTime: parseDateTime(json['scheduledTime']) ?? DateTime.now(),
      endTime: parseDateTime(json['endTime']),  // 🆕 Added
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: parseDateTime(json['completedAt']),
      completionNotes: json['completionNotes'] as String?,
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
      notificationId: json['notificationId'] as int?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: parseDateTime(json['deletedAt']),
    );
  }

  /// Factory constructor dari Entity
  factory ScheduleModel.fromEntity(ScheduleEntity entity) => ScheduleModel(
    id: entity.id,
    userId: entity.userId,
    title: entity.title,
    description: entity.notes,
    category: entity.category,
    scheduledTime: entity.dateTime,
    endTime: entity.endDateTime,  // 🆕 Added
    reminderEnabled: entity.hasReminder,
    reminderMinutesBefore: entity.reminderMinutes,
    isCompleted: entity.isCompleted,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    isSynced: entity.isSynced,
    isDeleted: entity.isDeleted,
    deletedAt: entity.deletedAt,
  );
  
  /// ID unik untuk schedule
  @HiveField(0)
  final String id;

  /// User ID pemilik schedule
  @HiveField(1)
  final String userId;

  /// Judul/nama schedule
  @HiveField(2)
  final String title;

  /// Deskripsi detail (optional)
  @HiveField(3)
  final String? description;

  /// Kategori schedule (custom string)
  @HiveField(4)
  final String category;  // 🔄 Changed from enum to String

  /// Waktu mulai schedule
  @HiveField(5)
  final DateTime scheduledTime;

  /// Apakah reminder enabled
  @HiveField(6)
  final bool reminderEnabled;

  /// Waktu reminder sebelum schedule (dalam menit)
  /// Contoh: 15 = 15 menit sebelum scheduledTime
  @HiveField(7)
  final int? reminderMinutesBefore;

  /// Apakah schedule sudah selesai/completed
  @HiveField(8)
  final bool isCompleted;

  /// Waktu kapan schedule di-complete
  @HiveField(9)
  final DateTime? completedAt;

  /// Catatan saat schedule di-complete
  @HiveField(10)
  final String? completionNotes;

  /// Timestamp kapan schedule dibuat
  @HiveField(11)
  final DateTime createdAt;

  /// Timestamp terakhir kali schedule diupdate
  @HiveField(12)
  final DateTime updatedAt;

  /// Flag untuk sinkronisasi cloud
  @HiveField(13)
  final bool isSynced;

  /// ID notification yang di-schedule (untuk cancellation)
  @HiveField(14)
  final int? notificationId;

  /// Flag soft delete - apakah data sudah dihapus
  @HiveField(15)
  final bool isDeleted;

  /// Timestamp kapan data dihapus
  @HiveField(16)
  final DateTime? deletedAt;

  /// 🆕 Waktu akhir schedule (untuk multi-day events)
  @HiveField(17, defaultValue: null)
  final DateTime? endTime;

  /// Convert ke Entity
  ScheduleEntity toEntity() => ScheduleEntity(
    id: id,
    userId: userId,
    title: title,
    notes: description,
    category: category,
    dateTime: scheduledTime,
    endDateTime: endTime,  // 🆕 Added
    hasReminder: reminderEnabled,
    reminderMinutes: reminderMinutesBefore ?? 15,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isSynced: isSynced,
    isDeleted: isDeleted,
    deletedAt: deletedAt,
  );

  /// Convert ke JSON untuk Firestore
  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'scheduledTime': scheduledTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),  // 🆕 Added
      'reminderEnabled': reminderEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'completionNotes': completionNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'notificationId': notificationId,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };

  /// Create copy with updated fields
  ScheduleModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    DateTime? scheduledTime,
    DateTime? endTime,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
    bool? isCompleted,
    DateTime? completedAt,
    String? completionNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    int? notificationId,
    bool? isDeleted,
    DateTime? deletedAt,
  }) => ScheduleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      endTime: endTime ?? this.endTime,  // 🆕 Added
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completionNotes: completionNotes ?? this.completionNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      notificationId: notificationId ?? this.notificationId,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );

  /// Getter untuk cek apakah schedule sudah lewat
  bool get isPast {
    final compareDate = endTime ?? scheduledTime;
    return compareDate.isBefore(DateTime.now());
  }

  /// Getter untuk cek apakah schedule hari ini
  bool get isToday {
    final now = DateTime.now();
    return scheduledTime.year == now.year &&
        scheduledTime.month == now.month &&
        scheduledTime.day == now.day;
  }

  /// Getter untuk cek apakah schedule upcoming (belum lewat & belum complete)
  bool get isUpcoming => !isPast && !isCompleted;

  /// 🆕 Check if this is multi-day event
  bool get isMultiDay {
    if (endTime == null) {
      return false;
    }
    return !(scheduledTime.year == endTime!.year &&
        scheduledTime.month == endTime!.month &&
        scheduledTime.day == endTime!.day);
  }

  @override
  String toString() => 'ScheduleModel(id: $id, title: $title, category: $category, '
        'scheduledTime: $scheduledTime, endTime: $endTime, isCompleted: $isCompleted, isDeleted: $isDeleted)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ScheduleModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.scheduledTime == scheduledTime &&
        other.endTime == endTime &&
        other.reminderEnabled == reminderEnabled &&
        other.reminderMinutesBefore == reminderMinutesBefore &&
        other.isCompleted == isCompleted &&
        other.completedAt == completedAt &&
        other.completionNotes == completionNotes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.notificationId == notificationId &&
        other.isDeleted == isDeleted &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        category.hashCode ^
        scheduledTime.hashCode ^
        endTime.hashCode ^
        reminderEnabled.hashCode ^
        reminderMinutesBefore.hashCode ^
        isCompleted.hashCode ^
        completedAt.hashCode ^
        completionNotes.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSynced.hashCode ^
        notificationId.hashCode ^
        isDeleted.hashCode ^
        deletedAt.hashCode;
}