import 'package:hive/hive.dart';

part 'photo_entity.g.dart';

@HiveType(typeId: 5)
class PhotoEntity extends HiveObject {

  PhotoEntity({
    required this.id,
    required this.userId,
    required this.dateTaken, required this.createdAt, required this.updatedAt, this.localPath,
    this.cloudUrl,
    this.caption,
    this.isMilestone = false,
    this.isSynced = false,
    this.isUploaded = false,
  });

  factory PhotoEntity.fromJson(Map<String, dynamic> json) => PhotoEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      localPath: json['localPath'] as String?,
      cloudUrl: json['cloudUrl'] as String?,
      caption: json['caption'] as String?,
      isMilestone: json['isMilestone'] as bool? ?? false,
      dateTaken: DateTime.parse(json['dateTaken'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: true,
      isUploaded: json['cloudUrl'] != null,
    );
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
    bool? isMilestone,
    DateTime? dateTaken,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isUploaded,
  }) => PhotoEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      localPath: localPath ?? this.localPath,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      caption: caption ?? this.caption,
      isMilestone: isMilestone ?? this.isMilestone,
      dateTaken: dateTaken ?? this.dateTaken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isUploaded: isUploaded ?? this.isUploaded,
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'localPath': localPath,
      'cloudUrl': cloudUrl,
      'caption': caption,
      'isMilestone': isMilestone,
      'dateTaken': dateTaken.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
}