// ignore_for_file: lines_longer_than_80_chars

import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

/// Enum untuk kategori jadwal
@HiveType(typeId: 10)
enum ScheduleCategory {
  @HiveField(0)
  feeding, // Pemberian Makan/Menyusui

  @HiveField(1)
  sleeping, // Tidur

  @HiveField(2)
  health, // Kesehatan (vaksinasi, dokter)

  @HiveField(3)
  milestone, // Pencapaian perkembangan

  @HiveField(4)
  other, // Lainnya
}

/// Extension untuk mendapatkan display name dan emoji dari category
extension ScheduleCategoryExtension on ScheduleCategory {
  String get displayName {
    switch (this) {
      case ScheduleCategory.feeding:
        return 'Pemberian Makan';
      case ScheduleCategory.sleeping:
        return 'Tidur';
      case ScheduleCategory.health:
        return 'Kesehatan';
      case ScheduleCategory.milestone:
        return 'Pencapaian';
      case ScheduleCategory.other:
        return 'Lainnya';
    }
  }

  String get emoji {
    switch (this) {
      case ScheduleCategory.feeding:
        return '🍼';
      case ScheduleCategory.sleeping:
        return '😴';
      case ScheduleCategory.health:
        return '🥼';
      case ScheduleCategory.milestone:
        return '🎉';
      case ScheduleCategory.other:
        return '📌';
    }
  }

  /// Color code untuk UI (hex string)
  String get colorHex {
    switch (this) {
      case ScheduleCategory.feeding:
        return '#4A90E2'; // Blue
      case ScheduleCategory.sleeping:
        return '#9B59B6'; // Purple
      case ScheduleCategory.health:
        return '#E74C3C'; // Red
      case ScheduleCategory.milestone:
        return '#2ECC71'; // Green
      case ScheduleCategory.other:
        return '#95A5A6'; // Gray
    }
  }
}

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
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 15,
    this.isCompleted = false,
    this.completedAt,
    this.completionNotes,
    this.isSynced = false,
    this.notificationId,
    this.isDeleted = false,  // 🆕 ADDED
    this.deletedAt,          // 🆕 ADDED
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
      category: ScheduleCategory.values.firstWhere(
        (e) => e.toString() == 'ScheduleCategory.${json['category']}',
        orElse: () => ScheduleCategory.other,
      ),
      scheduledTime: parseDateTime(json['scheduledTime']) ?? DateTime.now(),
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: parseDateTime(json['completedAt']),
      completionNotes: json['completionNotes'] as String?,
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
      notificationId: json['notificationId'] as int?,
      isDeleted: json['isDeleted'] as bool? ?? false,  // 🆕 ADDED
      deletedAt: parseDateTime(json['deletedAt']),    // 🆕 ADDED
    );
  }
  
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

  /// Kategori schedule
  @HiveField(4)
  final ScheduleCategory category;

  /// Waktu schedule
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

  /// 🆕 Flag soft delete - apakah data sudah dihapus
  @HiveField(15)
  final bool isDeleted;

  /// 🆕 Timestamp kapan data dihapus
  @HiveField(16)
  final DateTime? deletedAt;

  /// Convert ke JSON untuk Firestore
  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'scheduledTime': scheduledTime.toIso8601String(),
      'reminderEnabled': reminderEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'completionNotes': completionNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'notificationId': notificationId,
      'isDeleted': isDeleted,  // 🆕 ADDED
      'deletedAt': deletedAt?.toIso8601String(),  // 🆕 ADDED
    };

  /// Create copy with updated fields
  ScheduleModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    ScheduleCategory? category,
    DateTime? scheduledTime,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
    bool? isCompleted,
    DateTime? completedAt,
    String? completionNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    int? notificationId,
    bool? isDeleted,      // 🆕 ADDED
    DateTime? deletedAt,  // 🆕 ADDED
  }) => ScheduleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
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
      isDeleted: isDeleted ?? this.isDeleted,  // 🆕 ADDED
      deletedAt: deletedAt ?? this.deletedAt,  // 🆕 ADDED
    );

  /// Getter untuk cek apakah schedule sudah lewat
  bool get isPast => scheduledTime.isBefore(DateTime.now());

  /// Getter untuk cek apakah schedule hari ini
  bool get isToday {
    final now = DateTime.now();
    return scheduledTime.year == now.year &&
        scheduledTime.month == now.month &&
        scheduledTime.day == now.day;
  }

  /// Getter untuk cek apakah schedule upcoming (belum lewat & belum complete)
  bool get isUpcoming => !isPast && !isCompleted;

  @override
  String toString() => 'ScheduleModel(id: $id, title: $title, category: $category, '
        'scheduledTime: $scheduledTime, isCompleted: $isCompleted, isDeleted: $isDeleted)';

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
        other.reminderEnabled == reminderEnabled &&
        other.reminderMinutesBefore == reminderMinutesBefore &&
        other.isCompleted == isCompleted &&
        other.completedAt == completedAt &&
        other.completionNotes == completionNotes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.notificationId == notificationId &&
        other.isDeleted == isDeleted &&        // 🆕 ADDED
        other.deletedAt == deletedAt;          // 🆕 ADDED
  }

  @override
  int get hashCode => id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        category.hashCode ^
        scheduledTime.hashCode ^
        reminderEnabled.hashCode ^
        reminderMinutesBefore.hashCode ^
        isCompleted.hashCode ^
        completedAt.hashCode ^
        completionNotes.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSynced.hashCode ^
        notificationId.hashCode ^
        isDeleted.hashCode ^      // 🆕 ADDED
        deletedAt.hashCode;       // 🆕 ADDED
}