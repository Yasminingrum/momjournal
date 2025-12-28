import 'package:hive/hive.dart';

part 'photo_entity.g.dart';

@HiveType(typeId: 5)
class PhotoEntity extends HiveObject {

  PhotoEntity({
    required this.id,
    required this.userId,
    required this.dateTaken, 
    required this.createdAt, 
    required this.updatedAt, 
    this.localPath,
    this.cloudUrl,
    this.caption,
    this.category,           // 🆕 ADDED - Kategori foto
    this.isMilestone = false,
    this.isFavorite = false, // 🆕 ADDED - Status favorite
    this.isSynced = false,
    this.isUploaded = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory PhotoEntity.fromJson(Map<String, dynamic> json) {
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

    return PhotoEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      localPath: json['localPath'] as String?,
      cloudUrl: json['cloudUrl'] as String?,
      caption: json['caption'] as String?,
      category: json['category'] as String?,              // 🆕 ADDED
      isMilestone: json['isMilestone'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,   // 🆕 ADDED
      dateTaken: parseDateTime(json['dateTaken']) ?? DateTime.now(),
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
      isSynced: true,
      isUploaded: json['cloudUrl'] != null,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: parseDateTime(json['deletedAt']),
    );
  }

  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String? localPath;
  
  @HiveField(3)
  final String? cloudUrl;
  
  @HiveField(4)
  final String? caption;
  
  @HiveField(5)
  final bool isMilestone;
  
  @HiveField(6)
  final DateTime dateTaken;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime updatedAt;
  
  @HiveField(9)
  final bool isSynced;
  
  @HiveField(10)
  final bool isUploaded;

  /// Flag soft delete - apakah data sudah dihapus
  @HiveField(11)
  final bool isDeleted;

  /// Timestamp kapan data dihapus
  @HiveField(12)
  final DateTime? deletedAt;

  /// 🆕 Kategori/Album foto (contoh: "Ulang Tahun Pertama", "Liburan", "Milestone")
  @HiveField(13)
  final String? category;

  /// 🆕 Status favorite - apakah foto ini difavoritkan
  @HiveField(14)
  final bool isFavorite;

  /// Get download URL (prefer cloudUrl, fallback to localPath)
  String get downloadUrl => cloudUrl ?? localPath ?? '';
  
  /// Get captured date (prefer dateTaken)
  DateTime get capturedAt => dateTaken;

  PhotoEntity copyWith({
    String? id,
    String? userId,
    String? localPath,
    String? cloudUrl,
    String? caption,
    String? category,        // 🆕 ADDED
    bool? isMilestone,
    bool? isFavorite,        // 🆕 ADDED
    DateTime? dateTaken,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isUploaded,
    bool? isDeleted,
    DateTime? deletedAt,
  }) => PhotoEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      localPath: localPath ?? this.localPath,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      caption: caption ?? this.caption,
      category: category ?? this.category,              // 🆕 ADDED
      isMilestone: isMilestone ?? this.isMilestone,
      isFavorite: isFavorite ?? this.isFavorite,        // 🆕 ADDED
      dateTaken: dateTaken ?? this.dateTaken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isUploaded: isUploaded ?? this.isUploaded,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'localPath': localPath,
      'cloudUrl': cloudUrl,
      'caption': caption,
      'category': category,              // 🆕 ADDED
      'isMilestone': isMilestone,
      'isFavorite': isFavorite,          // 🆕 ADDED
      'dateTaken': dateTaken.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PhotoEntity &&
        other.id == id &&
        other.userId == userId &&
        other.localPath == localPath &&
        other.cloudUrl == cloudUrl &&
        other.caption == caption &&
        other.category == category &&            // 🆕 ADDED
        other.isMilestone == isMilestone &&
        other.isFavorite == isFavorite &&        // 🆕 ADDED
        other.dateTaken == dateTaken &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.isUploaded == isUploaded &&
        other.isDeleted == isDeleted &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => id.hashCode ^
        userId.hashCode ^
        localPath.hashCode ^
        cloudUrl.hashCode ^
        caption.hashCode ^
        category.hashCode ^          // 🆕 ADDED
        isMilestone.hashCode ^
        isFavorite.hashCode ^        // 🆕 ADDED
        dateTaken.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSynced.hashCode ^
        isUploaded.hashCode ^
        isDeleted.hashCode ^
        deletedAt.hashCode;

  @override
  String toString() => 'PhotoEntity(id: $id, caption: $caption, category: $category, isFavorite: $isFavorite, isDeleted: $isDeleted)';
}