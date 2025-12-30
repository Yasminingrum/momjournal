import 'package:hive/hive.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

/// Data model untuk Category
@HiveType(typeId: 12)
class CategoryModel extends HiveObject {
  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.isSynced = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  /// Factory constructor dari JSON (Firestore)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
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

    return CategoryModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? 'more_horiz',
      colorHex: json['colorHex'] as String? ?? '#95A5A6',
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: parseDateTime(json['deletedAt']),
    );
  }

  /// Factory constructor dari Entity
  factory CategoryModel.fromEntity(CategoryEntity entity) => CategoryModel(
        id: entity.id,
        userId: entity.userId,
        name: entity.name,
        icon: entity.icon,
        colorHex: entity.colorHex,
        isDefault: entity.isDefault,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        isSynced: entity.isSynced,
        isDeleted: entity.isDeleted,
        deletedAt: entity.deletedAt,
      );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final String colorHex;

  @HiveField(5)
  final bool isDefault;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final bool isSynced;

  @HiveField(9)
  final bool isDeleted;

  @HiveField(10)
  final DateTime? deletedAt;

  /// Convert ke Entity
  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        userId: userId,
        name: name,
        icon: icon,
        colorHex: colorHex,
        isDefault: isDefault,
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
        'name': name,
        'icon': icon,
        'colorHex': colorHex,
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isSynced': isSynced,
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? colorHex,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    DateTime? deletedAt,
  }) =>
      CategoryModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        colorHex: colorHex ?? this.colorHex,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, '
      'icon: $icon, colorHex: $colorHex, isDefault: $isDefault, isDeleted: $isDeleted)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CategoryModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.icon == icon &&
        other.colorHex == colorHex &&
        other.isDefault == isDefault &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.isDeleted == isDeleted &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      icon.hashCode ^
      colorHex.hashCode ^
      isDefault.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isSynced.hashCode ^
      isDeleted.hashCode ^
      deletedAt.hashCode;
}