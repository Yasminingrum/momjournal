library;

/// Category type untuk membedakan kategori schedule, photo, atau keduanya
enum CategoryType {
  schedule,  // Hanya untuk jadwal
  photo,     // Hanya untuk foto
  both,      // Bisa digunakan untuk jadwal DAN foto
}

/// Extension untuk CategoryType
extension CategoryTypeExtension on CategoryType {
  String get value {
    switch (this) {
      case CategoryType.schedule:
        return 'schedule';
      case CategoryType.photo:
        return 'photo';
      case CategoryType.both:
        return 'both';
    }
  }
  
  static CategoryType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'schedule':
        return CategoryType.schedule;
      case 'photo':
        return CategoryType.photo;
      case 'both':
        return CategoryType.both;
      default:
        return CategoryType.both; // Default to both for backward compatibility
    }
  }
}

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
    this.type = CategoryType.both,  // ✅ NEW: Default to 'both' for backward compatibility
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
  final CategoryType type;  // ✅ NEW: Type of category
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
    CategoryType? type,  // ✅ NEW
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
      type: type ?? this.type,  // ✅ NEW
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
        other.type == type &&  // ✅ NEW
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
        type.hashCode ^  // ✅ NEW
        isDefault.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSynced.hashCode ^
        isDeleted.hashCode ^
        deletedAt.hashCode;

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name, '
        'icon: $icon, colorHex: $colorHex, type: $type, isDefault: $isDefault, isDeleted: $isDeleted)';  // ✅ UPDATED
}

/// Default categories untuk pertama kali
class DefaultCategories {
  // ✅ UPDATED: Kategorikan berdasarkan type
  
  /// Kategori untuk Schedule & Photo (shared)
  static const List<Map<String, dynamic>> both = [
    {
      'name': 'Pemberian Makan/Menyusui',
      'icon': 'restaurant',
      'colorHex': '#4A90E2',
      'type': 'both',
    },
    {
      'name': 'Tidur',
      'icon': 'bedtime',
      'colorHex': '#9B59B6',
      'type': 'both',
    },
    {
      'name': 'Kesehatan',
      'icon': 'medical_services',
      'colorHex': '#E74C3C',
      'type': 'both',
    },
    {
      'name': 'Bermain',
      'icon': 'toys',
      'colorHex': '#FFA726',
      'type': 'both',
    },
  ];
  
  /// Kategori khusus untuk Schedule
  static const List<Map<String, dynamic>> schedule = [
    {
      'name': 'Olahraga',
      'icon': 'sports',
      'colorHex': '#66BB6A',
      'type': 'schedule',
    },
    {
      'name': 'Lainnya',
      'icon': 'more_horiz',
      'colorHex': '#95A5A6',
      'type': 'schedule',
    },
  ];
  
  /// Kategori khusus untuk Photo
  static const List<Map<String, dynamic>> photo = [
    {
      'name': 'Ulang Tahun',
      'icon': 'cake',
      'colorHex': '#FF6B9D',
      'type': 'photo',
    },
    {
      'name': 'Liburan',
      'icon': 'beach_access',
      'colorHex': '#4FC3F7',
      'type': 'photo',
    },
    {
      'name': 'Keluarga',
      'icon': 'family_restroom',
      'colorHex': '#8D6E63',
      'type': 'photo',
    },
    {
      'name': 'Pencapaian',
      'icon': 'stars',
      'colorHex': '#FFD54F',
      'type': 'photo',
    },
    {
      'name': 'Keseharian',
      'icon': 'wb_sunny',
      'colorHex': '#FFCA28',
      'type': 'photo',
    },
  ];
  
  /// Semua default categories (backward compatibility)
  static List<Map<String, dynamic>> get all => [...both, ...schedule, ...photo];
  
  /// Legacy defaults (untuk backward compatibility dengan kode lama)
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