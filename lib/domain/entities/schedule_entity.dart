import 'package:hive/hive.dart';

part 'schedule_entity.g.dart';

@HiveType(typeId: 1)
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

@HiveType(typeId: 2)
class ScheduleEntity extends HiveObject {

  ScheduleEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.createdAt, 
    required this.updatedAt, 
    this.notes,
    this.hasReminder = false,
    this.reminderMinutes,
    this.isCompleted = false,
    this.isSynced = false,
  });

  factory ScheduleEntity.fromJson(Map<String, dynamic> json) => ScheduleEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      category: ScheduleCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ScheduleCategory.other,
      ),
      dateTime: DateTime.parse(json['dateTime'] as String),
      notes: json['notes'] as String?,
      hasReminder: json['hasReminder'] as bool? ?? false,
      reminderMinutes: json['reminderMinutes'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: true,
    );
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final ScheduleCategory category;
  
  @HiveField(4)
  final DateTime dateTime;
  
  @HiveField(5)
  final String? notes;
  
  @HiveField(6)
  final bool hasReminder;
  
  @HiveField(7)
  final int? reminderMinutes;
  
  @HiveField(8)
  final bool isCompleted;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;
  
  @HiveField(11)
  final bool isSynced;

  ScheduleEntity copyWith({
    String? id,
    String? userId,
    String? title,
    ScheduleCategory? category,
    DateTime? dateTime,
    String? notes,
    bool? hasReminder,
    int? reminderMinutes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) => ScheduleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'title': title,
      'category': category.name,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'hasReminder': hasReminder,
      'reminderMinutes': reminderMinutes,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
}