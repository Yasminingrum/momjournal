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
  });

  factory JournalEntity.fromJson(Map<String, dynamic> json) => JournalEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: MoodType.values.firstWhere(
        (e) => e.name == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: true,
    );
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

  JournalEntity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MoodType? mood,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) => JournalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mood': mood.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
}