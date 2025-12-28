import 'package:hive/hive.dart';

part 'journal_model.g.dart';

/// Enum untuk mood/suasana hati
@HiveType(typeId: 11)
enum Mood {
  @HiveField(0)
  veryHappy, // Sangat Senang

  @HiveField(1)
  happy, // Senang

  @HiveField(2)
  neutral, // Biasa saja

  @HiveField(3)
  sad, // Sedih

  @HiveField(4)
  verySad, // Sangat Sedih
}

/// Extension untuk mendapatkan emoji dan display name dari Mood
extension MoodExtension on Mood {
  String get emoji {
    switch (this) {
      case Mood.veryHappy:
        return '😄';
      case Mood.happy:
        return '🙂';
      case Mood.neutral:
        return '😐';
      case Mood.sad:
        return '😔';
      case Mood.verySad:
        return '😢';
    }
  }

  String get displayName {
    switch (this) {
      case Mood.veryHappy:
        return 'Sangat Senang';
      case Mood.happy:
        return 'Senang';
      case Mood.neutral:
        return 'Biasa Saja';
      case Mood.sad:
        return 'Sedih';
      case Mood.verySad:
        return 'Sangat Sedih';
    }
  }

  /// Numeric value untuk charting (1-5)
  int get numericValue {
    switch (this) {
      case Mood.veryHappy:
        return 5;
      case Mood.happy:
        return 4;
      case Mood.neutral:
        return 3;
      case Mood.sad:
        return 2;
      case Mood.verySad:
        return 1;
    }
  }

  /// Color code untuk UI (hex string)
  String get colorHex {
    switch (this) {
      case Mood.veryHappy:
        return '#27AE60'; // Green
      case Mood.happy:
        return '#F39C12'; // Orange
      case Mood.neutral:
        return '#95A5A6'; // Gray
      case Mood.sad:
        return '#3498DB'; // Blue
      case Mood.verySad:
        return '#9B59B6'; // Purple
    }
  }
}

/// Data model untuk Journal Entry
/// 
/// Menyimpan catatan harian ibu dengan mood tracking
/// untuk monitoring kesehatan mental
@HiveType(typeId: 2)
class JournalModel extends HiveObject {

  JournalModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.tags,
    this.isFavorite = false,
    this.isDeleted = false,  // 🆕 ADDED
    this.deletedAt,          // 🆕 ADDED
  });

  /// Factory constructor dari JSON (Firestore)
  factory JournalModel.fromJson(Map<String, dynamic> json) {
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

    return JournalModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: json['date'] is DateTime
          ? json['date'] as DateTime
          : DateTime.parse(json['date'] as String),
      mood: Mood.values.firstWhere(
        (e) => e.toString() == 'Mood.${json['mood']}',
        orElse: () => Mood.neutral,
      ),
      content: json['content'] as String,
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,  // 🆕 ADDED
      deletedAt: parseDateTime(json['deletedAt']),    // 🆕 ADDED
    );
  }

  /// ID unik untuk journal entry
  @HiveField(0)
  final String id;

  /// User ID pemilik journal
  @HiveField(1)
  final String userId;

  /// Tanggal journal (1 entry per hari)
  @HiveField(2)
  final DateTime date;

  /// Mood/suasana hati hari ini
  @HiveField(3)
  final Mood mood;

  /// Isi catatan/journal (max 500 karakter)
  @HiveField(4)
  final String content;

  /// Timestamp kapan journal dibuat
  @HiveField(5)
  final DateTime createdAt;

  /// Timestamp terakhir kali journal diupdate
  @HiveField(6)
  final DateTime updatedAt;

  /// Flag untuk sinkronisasi cloud
  @HiveField(7)
  final bool isSynced;

  /// Tags/labels untuk journal (optional, untuk future feature)
  @HiveField(8)
  final List<String>? tags;

  /// Apakah ini entry yang di-favorite
  @HiveField(9)
  final bool isFavorite;

  /// 🆕 Flag soft delete - apakah data sudah dihapus
  @HiveField(10)
  final bool isDeleted;

  /// 🆕 Timestamp kapan data dihapus
  @HiveField(11)
  final DateTime? deletedAt;

  /// Convert ke JSON untuk Firestore
  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mood': mood.toString().split('.').last,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'tags': tags,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,  // 🆕 ADDED
      'deletedAt': deletedAt?.toIso8601String(),  // 🆕 ADDED
    };

  /// Create copy with updated fields
  JournalModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    Mood? mood,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    List<String>? tags,
    bool? isFavorite,
    bool? isDeleted,      // 🆕 ADDED
    DateTime? deletedAt,  // 🆕 ADDED
  }) => JournalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,  // 🆕 ADDED
      deletedAt: deletedAt ?? this.deletedAt,  // 🆕 ADDED
    );

  /// Getter untuk preview content (first 100 chars)
  String get contentPreview {
    if (content.length <= 100) {
      return content;
    }
    return '${content.substring(0, 97)}...';
  }

  /// Getter untuk character count
  int get characterCount => content.length;

  /// Getter untuk cek apakah journal hari ini
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Getter untuk date string yang user-friendly
  String get dateString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final journalDate = DateTime(date.year, date.month, date.day);

    if (journalDate == today) {
      return 'Hari Ini';
    } else if (journalDate == yesterday) {
      return 'Kemarin';
    } else {
      // Format: "Senin, 5 Jan 2025"
      final weekday = _getWeekdayName(date.weekday);
      final month = _getMonthName(date.month);
      return '$weekday, ${date.day} $month ${date.year}';
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return weekdays[weekday - 1];
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
  String toString() => 'JournalModel(id: $id, date: $date, mood: $mood, '
        'contentLength: ${content.length}, isSynced: $isSynced, isDeleted: $isDeleted)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is JournalModel &&
        other.id == id &&
        other.userId == userId &&
        other.date == date &&
        other.mood == mood &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.isFavorite == isFavorite &&
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
        isFavorite.hashCode ^
        isDeleted.hashCode ^      // 🆕 ADDED
        deletedAt.hashCode;       // 🆕 ADDED
}