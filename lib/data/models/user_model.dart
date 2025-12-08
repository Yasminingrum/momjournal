import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Data model untuk informasi user
/// 
/// Menyimpan data pengguna aplikasi termasuk info autentikasi
/// dan profil anak yang terkait
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  /// ID unik user dari Firebase Auth
  @HiveField(0)
  final String uid;

  /// Email user dari Google Sign-In
  @HiveField(1)
  final String email;

  /// Display name dari Google account
  @HiveField(2)
  final String? displayName;

  /// Photo URL dari Google profile
  @HiveField(3)
  final String? photoUrl;

  /// Timestamp kapan user pertama kali dibuat
  @HiveField(4)
  final DateTime createdAt;

  /// Timestamp terakhir kali user login
  @HiveField(5)
  final DateTime lastLoginAt;

  /// Nama anak (setup saat onboarding)
  @HiveField(6)
  final String? childName;

  /// Tanggal lahir anak
  @HiveField(7)
  final DateTime? childBirthDate;

  /// Gender anak (optional)
  @HiveField(8)
  final String? childGender;

  /// Status apakah sudah selesai onboarding
  @HiveField(9)
  final bool hasCompletedOnboarding;

  /// Preferensi notifikasi enabled/disabled
  @HiveField(10)
  final bool notificationsEnabled;

  /// Quiet hours start time (format: HH:mm)
  @HiveField(11)
  final String? quietHoursStart;

  /// Quiet hours end time (format: HH:mm)
  @HiveField(12)
  final String? quietHoursEnd;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.childName,
    this.childBirthDate,
    this.childGender,
    this.hasCompletedOnboarding = false,
    this.notificationsEnabled = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '06:00',
  });

  /// Factory constructor untuk membuat UserModel dari JSON
  /// Digunakan saat fetching data dari Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] is DateTime
          ? json['lastLoginAt'] as DateTime
          : DateTime.parse(json['lastLoginAt'] as String),
      childName: json['childName'] as String?,
      childBirthDate: json['childBirthDate'] != null
          ? (json['childBirthDate'] is DateTime
              ? json['childBirthDate'] as DateTime
              : DateTime.parse(json['childBirthDate'] as String))
          : null,
      childGender: json['childGender'] as String?,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      quietHoursStart: json['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] as String? ?? '06:00',
    );
  }

  /// Convert UserModel ke JSON untuk disimpan di Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'childName': childName,
      'childBirthDate': childBirthDate?.toIso8601String(),
      'childGender': childGender,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'notificationsEnabled': notificationsEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? childName,
    DateTime? childBirthDate,
    String? childGender,
    bool? hasCompletedOnboarding,
    bool? notificationsEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      childName: childName ?? this.childName,
      childBirthDate: childBirthDate ?? this.childBirthDate,
      childGender: childGender ?? this.childGender,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, '
        'childName: $childName, hasCompletedOnboarding: $hasCompletedOnboarding)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.childName == childName &&
        other.childBirthDate == childBirthDate &&
        other.childGender == childGender &&
        other.hasCompletedOnboarding == hasCompletedOnboarding &&
        other.notificationsEnabled == notificationsEnabled &&
        other.quietHoursStart == quietHoursStart &&
        other.quietHoursEnd == quietHoursEnd;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoUrl.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode ^
        childName.hashCode ^
        childBirthDate.hashCode ^
        childGender.hashCode ^
        hasCompletedOnboarding.hashCode ^
        notificationsEnabled.hashCode ^
        quietHoursStart.hashCode ^
        quietHoursEnd.hashCode;
  }
}