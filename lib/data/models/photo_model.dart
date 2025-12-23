// ignore_for_file: lines_longer_than_80_chars

import 'package:hive/hive.dart';
import '/domain/entities/photo_entity.dart';

part 'photo_model.g.dart';

/// Data model untuk Photo/Gallery
/// 
/// Menyimpan metadata foto yang diupload ke cloud storage
/// termasuk thumbnail, caption, dan milestone flag
@HiveType(typeId: 3)
class PhotoModel extends HiveObject {

  PhotoModel({
    required this.id,
    required this.userId,
    required this.date, 
    required this.createdAt, 
    required this.updatedAt, 
    this.caption,
    this.imageUrl,
    this.thumbnailUrl,
    this.localFilePath,
    this.isMilestone = false,
    this.tags,
    this.fileSizeBytes,
    this.imageWidth,
    this.imageHeight,
    this.isSynced = false,
    this.uploadStatus = 'pending',
    this.uploadProgress,
    this.uploadError,
  });

  /// Factory constructor dari JSON (Firestore)
  /// 
  /// Handles null values safely to prevent type casting errors
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    // Helper function untuk safely parse DateTime
    DateTime? _parseDateTime(dynamic value) {
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
    
    return PhotoModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      caption: json['caption'] as String?,
      date: _parseDateTime(json['date']) ?? DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      localFilePath: json['localFilePath'] as String?,
      isMilestone: json['isMilestone'] as bool? ?? false,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      imageWidth: json['imageWidth'] as int?,
      imageHeight: json['imageHeight'] as int?,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
      uploadStatus: json['uploadStatus'] as String? ?? 'completed',
      uploadProgress: json['uploadProgress'] as int?,
      uploadError: json['uploadError'] as String?,
    );
  }

  /// Factory constructor dari PhotoEntity
  factory PhotoModel.fromEntity(PhotoEntity entity) => PhotoModel(
      id: entity.id,
      userId: entity.userId,
      caption: entity.caption,
      date: entity.dateTaken,
      imageUrl: entity.cloudUrl,
      thumbnailUrl: null,
      localFilePath: entity.localPath,
      isMilestone: entity.isMilestone,
      tags: null,
      fileSizeBytes: null,
      imageWidth: null,
      imageHeight: null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
      uploadStatus: entity.isUploaded ? 'completed' : 'pending',
      uploadProgress: null,
      uploadError: null,
    );

  /// ID unik untuk photo
  @HiveField(0)
  final String id;

  /// User ID pemilik photo
  @HiveField(1)
  final String userId;

  /// Caption/deskripsi foto
  @HiveField(2)
  final String? caption;

  /// Tanggal kapan foto diambil/diupload
  @HiveField(3)
  final DateTime date;

  /// URL foto di Firebase Storage (full resolution)
  @HiveField(4)
  final String? imageUrl;

  /// URL thumbnail foto (untuk preview di gallery)
  @HiveField(5)
  final String? thumbnailUrl;

  /// Local file path (untuk offline access)
  @HiveField(6)
  final String? localFilePath;

  /// Flag apakah foto ini adalah milestone
  @HiveField(7)
  final bool isMilestone;

  /// Tags untuk search dan filter
  @HiveField(8)
  final List<String>? tags;

  /// Ukuran file dalam bytes
  @HiveField(9)
  final int? fileSizeBytes;

  /// Dimensi foto - width
  @HiveField(10)
  final int? imageWidth;

  /// Dimensi foto - height
  @HiveField(11)
  final int? imageHeight;

  /// Timestamp kapan photo dibuat
  @HiveField(12)
  final DateTime createdAt;

  /// Timestamp terakhir kali photo diupdate
  @HiveField(13)
  final DateTime updatedAt;

  /// Flag untuk sinkronisasi cloud
  @HiveField(14)
  final bool isSynced;

  /// Status upload: 'pending', 'uploading', 'completed', 'failed'
  @HiveField(15)
  final String uploadStatus;

  /// Progress upload dalam persen (0-100)
  @HiveField(16)
  final int? uploadProgress;

  /// Error message jika upload failed
  @HiveField(17)
  final String? uploadError;

  /// Convert ke JSON untuk Firestore
  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'caption': caption,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'localFilePath': localFilePath,
      'isMilestone': isMilestone,
      'tags': tags,
      'fileSizeBytes': fileSizeBytes,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'uploadStatus': uploadStatus,
      'uploadProgress': uploadProgress,
      'uploadError': uploadError,
    };

  /// Convert ke PhotoEntity untuk domain layer
  PhotoEntity toEntity() => PhotoEntity(
      id: id,
      userId: userId,
      caption: caption,
      dateTaken: date,
      localPath: localFilePath,
      cloudUrl: imageUrl,
      isMilestone: isMilestone,
      isUploaded: uploadStatus == 'completed',
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );

  /// Create copy with updated fields
  PhotoModel copyWith({
    String? id,
    String? userId,
    String? caption,
    DateTime? date,
    String? imageUrl,
    String? thumbnailUrl,
    String? localFilePath,
    bool? isMilestone,
    List<String>? tags,
    int? fileSizeBytes,
    int? imageWidth,
    int? imageHeight,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? uploadStatus,
    int? uploadProgress,
    String? uploadError,
  }) => PhotoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      isMilestone: isMilestone ?? this.isMilestone,
      tags: tags ?? this.tags,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadError: uploadError ?? this.uploadError,
    );

  /// Getter untuk mengecek apakah foto sudah diupload ke cloud
  bool get isUploaded => uploadStatus == 'completed' && imageUrl != null;

  /// Getter untuk mengecek apakah sedang proses upload
  bool get isUploading => uploadStatus == 'uploading';

  /// Getter untuk mengecek apakah upload gagal
  bool get hasUploadFailed => uploadStatus == 'failed';

  /// Getter untuk readable file size
  String get readableFileSize {
    if (fileSizeBytes == null) {
      return 'Unknown';
    }

    final bytes = fileSizeBytes!;
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  String toString() =>
      'PhotoModel(id: $id, caption: $caption, date: $date, uploadStatus: $uploadStatus)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PhotoModel &&
        other.id == id &&
        other.userId == userId &&
        other.caption == caption &&
        other.date == date &&
        other.imageUrl == imageUrl &&
        other.thumbnailUrl == thumbnailUrl &&
        other.localFilePath == localFilePath &&
        other.isMilestone == isMilestone &&
        other.fileSizeBytes == fileSizeBytes &&
        other.imageWidth == imageWidth &&
        other.imageHeight == imageHeight &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.uploadStatus == uploadStatus &&
        other.uploadProgress == uploadProgress &&
        other.uploadError == uploadError;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      caption.hashCode ^
      date.hashCode ^
      imageUrl.hashCode ^
      thumbnailUrl.hashCode ^
      localFilePath.hashCode ^
      isMilestone.hashCode ^
      fileSizeBytes.hashCode ^
      imageWidth.hashCode ^
      imageHeight.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isSynced.hashCode ^
      uploadStatus.hashCode ^
      uploadProgress.hashCode ^
      uploadError.hashCode;
}