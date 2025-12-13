import 'package:hive/hive.dart';

part 'user_entity.g.dart';

@HiveType(typeId: 0)
class UserEntity extends HiveObject {

  UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt, required this.updatedAt, this.photoUrl,
    this.childName,
    this.childDateOfBirth,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      childName: json['childName'] as String?,
      childDateOfBirth: json['childDateOfBirth'] != null
          ? DateTime.parse(json['childDateOfBirth'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String displayName;
  
  @HiveField(3)
  final String? photoUrl;
  
  @HiveField(4)
  final String? childName;
  
  @HiveField(5)
  final DateTime? childDateOfBirth;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? childName,
    DateTime? childDateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      childName: childName ?? this.childName,
      childDateOfBirth: childDateOfBirth ?? this.childDateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'childName': childName,
      'childDateOfBirth': childDateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
}