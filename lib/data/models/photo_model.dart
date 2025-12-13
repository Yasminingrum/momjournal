// ignore_for_file: lines_longer_than_80_chars

import 'package:hive/hive.dart';

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
    required this.date, required this.createdAt, required this.updatedAt, this.caption,
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
  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      caption: json['caption'] as String?,
      date: json['date'] is DateTime
          ? json['date'] as DateTime
          : DateTime.parse(json['date'] as String),
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
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt'] as DateTime
          : DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      uploadStatus: json['uploadStatus'] as String? ?? 'completed',
      uploadProgress: json['uploadProgress'] as int?,
      uploadError: json['uploadError'] as String?,
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

  /// URL foto full size di Firebase Storage
  @HiveField(4)
  final String? imageUrl;

  /// URL thumbnail di Firebase Storage (compressed)
  @HiveField(5)
  final String? thumbnailUrl;

  /// Local file path (untuk offline mode)
  @HiveField(6)
  final String? localFilePath;

  /// Apakah foto ini milestone penting
  @HiveField(7)
  final bool isMilestone;

  /// Tags/labels untuk foto (optional)
  @HiveField(8)
  final List<String>? tags;

  /// Ukuran file dalam bytes
  @HiveField(9)
  final int? fileSizeBytes;

  /// Dimensi foto: width
  @HiveField(10)
  final int? imageWidth;

  /// Dimensi foto: height
  @HiveField(11)
  final int? imageHeight;

  /// Timestamp kapan photo entry dibuat
  @HiveField(12)
  final DateTime createdAt;

  /// Timestamp terakhir kali photo entry diupdate
  @HiveField(13)
  final DateTime updatedAt;

  /// Flag untuk sinkronisasi cloud
  @HiveField(14)
  final bool isSynced;

  /// Status upload: 'pending', 'uploading', 'completed', 'failed'
  @HiveField(15)
  final String uploadStatus;

  /// Progress upload (0-100)
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

  /// Getter untuk display URL (prioritas: imageUrl > thumbnailUrl > localFilePath)
  String? get displayUrl => imageUrl ?? thumbnailUrl ?? localFilePath;

  /// Getter untuk cek apakah photo sudah terupload
  bool get isUploaded => uploadStatus == 'completed' && imageUrl != null;

  /// Getter untuk cek apakah sedang uploading
  bool get isUploading => uploadStatus == 'uploading';

  /// Getter untuk cek apakah upload failed
  bool get isUploadFailed => uploadStatus == 'failed';

  /// Getter untuk file size yang readable (KB, MB)
  String get readableFileSize {
    if (fileSizeBytes == null) {
      return 'Unknown';
    }

    if (fileSizeBytes! < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes! < 1024 * 1024) {
      return '${(fileSizeBytes! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Getter untuk aspect ratio
  double? get aspectRatio {
    if (imageWidth == null || imageHeight == null || imageHeight == 0) {
      return null;
    }
    return imageWidth! / imageHeight!;
  }

  /// Getter untuk date string yang user-friendly
  String get dateString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final photoDate = DateTime(date.year, date.month, date.day);

    if (photoDate == today) {
      return 'Hari Ini';
    } else if (photoDate == yesterday) {
      return 'Kemarin';
    } else {
      // Format: "5 Jan 2025"
      final month = _getMonthName(date.month);
      return '${date.day} $month ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  @override
  String toString() => 'PhotoModel(id: $id, caption: $caption, date: $date, '
        'isMilestone: $isMilestone, uploadStatus: $uploadStatus, isSynced: $isSynced)';

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
        other.uploadStatus == uploadStatus;
  }

  @override
  int get hashCode => id.hashCode ^
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
        uploadStatus.hashCode;
}