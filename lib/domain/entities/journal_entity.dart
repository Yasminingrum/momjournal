import 'package:hive/hive.dart';

part 'journal_entity.g.dart';

@HiveType(typeId: 3)
enum MoodType {
  @HiveField(0)
  veryHappy,
  @HiveField(1)
  happy,
  @HiveField(2)
  neutral,
  @HiveField(3)
  sad,
  @HiveField(4)
  verySad,
}

@HiveType(typeId: 4)
class JournalEntity extends HiveObject {

  JournalEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,  // 🆕 ADDED
    this.deletedAt,          // 🆕 ADDED
  });

  factory JournalEntity.fromJson(Map<String, dynamic> json) {
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

    return JournalEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: MoodType.values.firstWhere(
        (e) => e.name == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      content: json['content'] as String,
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
      isSynced: true,
      isDeleted: json['isDeleted'] as bool? ?? false,  // 🆕 ADDED
      deletedAt: parseDateTime(json['deletedAt']),    // 🆕 ADDED
    );
  }

  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final DateTime date;
  
  @HiveField(3)
  final MoodType mood;
  
  @HiveField(4)
  final String content;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime updatedAt;
  
  @HiveField(7)
  final bool isSynced;

  /// 🆕 Flag soft delete - apakah data sudah dihapus
  @HiveField(8)
  final bool isDeleted;

  /// 🆕 Timestamp kapan data dihapus
  @HiveField(9)
  final DateTime? deletedAt;

  JournalEntity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MoodType? mood,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,      // 🆕 ADDED
    DateTime? deletedAt,  // 🆕 ADDED
  }) => JournalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,  // 🆕 ADDED
      deletedAt: deletedAt ?? this.deletedAt,  // 🆕 ADDED
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mood': mood.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,  // 🆕 ADDED
      'deletedAt': deletedAt?.toIso8601String(),  // 🆕 ADDED
    };

  // Helper method to get mood emoji
  String get moodEmoji {
    switch (mood) {
      case MoodType.veryHappy:
        return '😄';
      case MoodType.happy:
        return '🙂';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '☹️';
      case MoodType.verySad:
        return '😢';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is JournalEntity &&
        other.id == id &&
        other.userId == userId &&
        other.date == date &&
        other.mood == mood &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.isDeleted == isDeleted &&        // 🆕 ADDED
        other.deletedAt == deletedAt;          // 🆕 ADDED
  }

  @override
  int get hashCode => id.hashCode ^
        userId.hashCode ^
        date.hashCode ^
        mood.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSynced.hashCode ^
        isDeleted.hashCode ^      // 🆕 ADDED
        deletedAt.hashCode;       // 🆕 ADDED

  @override
  String toString() => 'JournalEntity(id: $id, date: $date, mood: $mood, isDeleted: $isDeleted)';
}