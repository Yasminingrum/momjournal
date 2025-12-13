import 'package:hive/hive.dart';

part 'child_profile_model.g.dart';

/// Data model untuk Child Profile
/// 
/// Menyimpan informasi profil anak yang disetup saat onboarding
@HiveType(typeId: 4)
class ChildProfileModel extends HiveObject {

  ChildProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.birthDate,
    this.gender,
    this.photoUrl,
    this.localPhotoPath,
    this.birthWeightGrams,
    this.birthHeightCm,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  /// Factory constructor dari JSON (Firestore)
  factory ChildProfileModel.fromJson(Map<String, dynamic> json) {
    return ChildProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      birthDate: json['birthDate'] is DateTime
          ? json['birthDate'] as DateTime
          : DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String?,
      photoUrl: json['photoUrl'] as String?,
      localPhotoPath: json['localPhotoPath'] as String?,
      birthWeightGrams: json['birthWeightGrams'] as int?,
      birthHeightCm: json['birthHeightCm'] as int?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt'] as DateTime
          : DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
  /// ID unik untuk child profile
  @HiveField(0)
  final String id;

  /// User ID parent
  @HiveField(1)
  final String userId;

  /// Nama anak
  @HiveField(2)
  final String name;

  /// Tanggal lahir anak
  @HiveField(3)
  final DateTime birthDate;

  /// Gender anak: 'boy', 'girl', 'other', atau null
  @HiveField(4)
  final String? gender;

  /// URL foto profil anak di Firebase Storage
  @HiveField(5)
  final String? photoUrl;

  /// Local file path foto profil (untuk offline)
  @HiveField(6)
  final String? localPhotoPath;

  /// Berat badan saat lahir (dalam gram)
  @HiveField(7)
  final int? birthWeightGrams;

  /// Tinggi badan saat lahir (dalam cm)
  @HiveField(8)
  final int? birthHeightCm;

  /// Catatan tambahan tentang anak
  @HiveField(9)
  final String? notes;

  /// Timestamp kapan profile dibuat
  @HiveField(10)
  final DateTime createdAt;

  /// Timestamp terakhir kali profile diupdate
  @HiveField(11)
  final DateTime updatedAt;

  /// Flag untuk sinkronisasi cloud
  @HiveField(12)
  final bool isSynced;

  /// Convert ke JSON untuk Firestore
  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'photoUrl': photoUrl,
      'localPhotoPath': localPhotoPath,
      'birthWeightGrams': birthWeightGrams,
      'birthHeightCm': birthHeightCm,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };

  /// Create copy with updated fields
  ChildProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
    String? localPhotoPath,
    int? birthWeightGrams,
    int? birthHeightCm,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) => ChildProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      birthWeightGrams: birthWeightGrams ?? this.birthWeightGrams,
      birthHeightCm: birthHeightCm ?? this.birthHeightCm,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );

  /// Getter untuk usia anak dalam hari
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(birthDate).inDays;
  }

  /// Getter untuk usia anak dalam bulan
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12;
    months += now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    return months;
  }

  /// Getter untuk usia anak dalam tahun
  int get ageInYears {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  /// Getter untuk string usia yang user-friendly
  String get ageString {
    final years = ageInYears;
    final months = ageInMonths % 12;
    final days = ageInDays;

    if (years > 0) {
      if (months > 0) {
        return '$years tahun $months bulan';
      }
      return '$years tahun';
    } else if (months > 0) {
      return '$months bulan';
    } else if (days > 0) {
      return '$days hari';
    } else {
      return 'Baru lahir';
    }
  }

  /// Getter untuk display photo (prioritas: photoUrl > localPhotoPath)
  String? get displayPhotoUrl => photoUrl ?? localPhotoPath;

  /// Getter untuk gender display string
  String get genderDisplay {
    switch (gender?.toLowerCase()) {
      case 'boy':
        return 'Laki-laki';
      case 'girl':
        return 'Perempuan';
      case 'other':
        return 'Lainnya';
      default:
        return 'Tidak disebutkan';
    }
  }

  /// Getter untuk birth weight yang readable (kg)
  String get readableBirthWeight {
    if (birthWeightGrams == null) return 'Tidak ada data';
    final kg = birthWeightGrams! / 1000;
    return '${kg.toStringAsFixed(2)} kg';
  }

  /// Getter untuk birth height yang readable (cm)
  String get readableBirthHeight {
    if (birthHeightCm == null) return 'Tidak ada data';
    return '$birthHeightCm cm';
  }

  @override
  String toString() => 'ChildProfileModel(id: $id, name: $name, birthDate: $birthDate, '
        'gender: $gender, ageInMonths: $ageInMonths)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChildProfileModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.birthDate == birthDate &&
        other.gender == gender &&
        other.photoUrl == photoUrl &&
        other.localPhotoPath == localPhotoPath &&
        other.birthWeightGrams == birthWeightGrams &&
        other.birthHeightCm == birthHeightCm &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode => id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        birthDate.hashCode ^
        gender.hashCode ^
        photoUrl.hashCode ^
        localPhotoPath.hashCode ^
        birthWeightGrams.hashCode ^
        birthHeightCm.hashCode ^
        notes.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSynced.hashCode;
}