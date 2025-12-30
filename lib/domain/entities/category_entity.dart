library;

/// Domain entity untuk Category
/// Represents the business logic for a schedule category
class CategoryEntity {
  const CategoryEntity({
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

  final String id;
  final String userId;
  final String name;
  final String icon;  // Icon name from Material Icons
  final String colorHex;  // Color in hex format (e.g., "#FF5733")
  final bool isDefault;  // True for default categories
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted;
  final DateTime? deletedAt;

  /// Copy with method
  CategoryEntity copyWith({
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
  }) => CategoryEntity(
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
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CategoryEntity &&
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
  int get hashCode => id.hashCode ^
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

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name, '
        'icon: $icon, colorHex: $colorHex, isDefault: $isDefault, isDeleted: $isDeleted)';
}

/// Default categories untuk pertama kali
class DefaultCategories {
  static const List<Map<String, String>> defaults = [
    {
      'name': 'Pemberian Makan/Menyusui',
      'icon': 'restaurant',
      'colorHex': '#4A90E2',
    },
    {
      'name': 'Tidur',
      'icon': 'bedtime',
      'colorHex': '#9B59B6',
    },
    {
      'name': 'Kesehatan',
      'icon': 'medical_services',
      'colorHex': '#E74C3C',
    },
    {
      'name': 'Pencapaian',
      'icon': 'stars',
      'colorHex': '#2ECC71',
    },
    {
      'name': 'Lainnya',
      'icon': 'more_horiz',
      'colorHex': '#95A5A6',
    },
  ];
}