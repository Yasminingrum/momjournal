library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/photo_entity.dart';
import 'firebase_service.dart';

/// Interface untuk Photo Remote Datasource (UPDATED with soft delete, favorite, and category support)
abstract class PhotoRemoteDatasource {
  Future<String> uploadPhoto(File photoFile, String photoId);
  Future<void> createPhotoMetadata(PhotoEntity photo);
  Future<List<PhotoEntity>> getAllPhotos();
  Future<List<PhotoEntity>> getAllPhotosIncludingDeleted();
  Future<List<PhotoEntity>> getFavoritePhotos();  // 🆕 ADDED
  Future<List<PhotoEntity>> getPhotosByCategory(String category);  // 🆕 ADDED
  Future<void> updatePhoto(PhotoEntity photo);
  Future<void> deletePhoto(String photoId, String downloadUrl);
  Stream<List<PhotoEntity>> watchPhotos();
}

class PhotoRemoteDatasourceImpl implements PhotoRemoteDatasource {

  PhotoRemoteDatasourceImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService();
  final FirebaseService _firebaseService;

  CollectionReference? get _photosCollection =>
      _firebaseService.photosCollection;
  
  Reference? get _userPhotosRef => _firebaseService.userPhotosRef;

  @override
  Future<String> uploadPhoto(File photoFile, String photoId) async {
    try {
      if (_userPhotosRef == null) {
        throw const AuthorizationException('User tidak login');
      }

      debugPrint('📤 Uploading photo: $photoId');

      final ref = _userPhotosRef!.child('$photoId.jpg');
      final uploadTask = ref.putFile(
        photoFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Photo uploaded: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error uploading photo: ${e.code}');
      throw StorageException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error uploading photo: $e');
      throw StorageException('Gagal mengunggah foto: $e');
    }
  }

  @override
  Future<void> createPhotoMetadata(PhotoEntity photo) async {
    try {
      if (_photosCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      await _photosCollection!
          .doc(photo.id)
          .set(_photoToFirestore(photo));

      debugPrint('✅ Photo metadata created: ${photo.id}');
    } catch (e) {
      debugPrint('❌ Error creating photo metadata: $e');
      throw DatabaseException('Gagal menyimpan metadata foto: $e');
    }
  }

  @override
  Future<List<PhotoEntity>> getAllPhotos() async {
    try {
      if (_photosCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final snapshot = await _photosCollection!
          .where('isDeleted', isEqualTo: false)  // Filter deleted
          .orderBy('dateTaken', descending: true)
          .get();

      return snapshot.docs
          .map(_photoFromFirestore)
          .where((photo) => photo != null)
          .cast<PhotoEntity>()
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting all photos: $e');
      throw DatabaseException('Gagal mengambil foto: $e');
    }
  }

  @override
  Future<List<PhotoEntity>> getAllPhotosIncludingDeleted() async {
    try {
      if (_photosCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final snapshot = await _photosCollection!
          .orderBy('dateTaken', descending: true)
          .get();

      return snapshot.docs
          .map(_photoFromFirestore)
          .where((photo) => photo != null)
          .cast<PhotoEntity>()
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting all photos including deleted: $e');
      throw DatabaseException('Gagal mengambil semua foto: $e');
    }
  }

  /// 🆕 Get favorite photos only
  @override
  Future<List<PhotoEntity>> getFavoritePhotos() async {
    try {
      if (_photosCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final snapshot = await _photosCollection!
          .where('isDeleted', isEqualTo: false)
          .where('isFavorite', isEqualTo: true)  // 🆕 Filter favorites
          .orderBy('dateTaken', descending: true)
          .get();

      return snapshot.docs
          .map(_photoFromFirestore)
          .where((photo) => photo != null)
          .cast<PhotoEntity>()
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting favorite photos: $e');
      throw DatabaseException('Gagal mengambil foto favorit: $e');
    }
  }

  /// 🆕 Get photos by category
  @override
  Future<List<PhotoEntity>> getPhotosByCategory(String category) async {
    try {
      if (_photosCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final snapshot = await _photosCollection!
          .where('isDeleted', isEqualTo: false)
          .where('category', isEqualTo: category)  // 🆕 Filter by category
          .orderBy('dateTaken', descending: true)
          .get();

      return snapshot.docs
          .map(_photoFromFirestore)
          .where((photo) => photo != null)
          .cast<PhotoEntity>()
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting photos by category: $e');
      throw DatabaseException('Gagal mengambil foto berdasarkan kategori: $e');
    }
  }

  @override
  Future<void> updatePhoto(PhotoEntity photo) async {
    try {
      if (_photosCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      await _photosCollection!.doc(photo.id).set(_photoToFirestore(photo), SetOptions(merge: true));

      debugPrint('✅ Photo updated: ${photo.id}');
    } catch (e) {
      debugPrint('❌ Error updating photo: $e');
      throw DatabaseException('Gagal mengupdate foto: $e');
    }
  }

  @override
  Future<void> deletePhoto(String photoId, String downloadUrl) async {
    try {
      if (_photosCollection == null || _userPhotosRef == null) {
        throw const AuthorizationException('User tidak login');
      }

      // Soft delete: update isDeleted flag instead of actual deletion
      await _photosCollection!.doc(photoId).update({
        'isDeleted': true,
        'deletedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      debugPrint('✅ Photo soft deleted: $photoId');
    } catch (e) {
      debugPrint('❌ Error deleting photo: $e');
      throw DatabaseException('Gagal menghapus foto: $e');
    }
  }

  @override
  Stream<List<PhotoEntity>> watchPhotos() {
    if (_photosCollection == null) {
      throw const AuthorizationException('User tidak login');
    }

    return _photosCollection!
        .where('isDeleted', isEqualTo: false)  // Filter deleted
        .orderBy('dateTaken', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(_photoFromFirestore)
            .where((photo) => photo != null)
            .cast<PhotoEntity>()
            .toList(),);
  }

  /// Convert PhotoEntity to Firestore Map (UPDATED with category and favorite)
  Map<String, dynamic> _photoToFirestore(PhotoEntity photo) => {
      'id': photo.id,
      'userId': photo.userId,
      'cloudUrl': photo.cloudUrl,
      'caption': photo.caption,
      'category': photo.category,        // 🆕 ADDED
      'isMilestone': photo.isMilestone,
      'isFavorite': photo.isFavorite,    // 🆕 ADDED
      'dateTaken': Timestamp.fromDate(photo.dateTaken),
      'createdAt': Timestamp.fromDate(photo.createdAt),
      'updatedAt': Timestamp.fromDate(photo.updatedAt),
      'isDeleted': photo.isDeleted,
      'deletedAt': photo.deletedAt != null 
          ? Timestamp.fromDate(photo.deletedAt!) 
          : null,
    };

  /// Convert Firestore document to PhotoEntity (UPDATED with category and favorite)
  /// 
  /// Returns null if document is invalid/corrupt to prevent crashes
  PhotoEntity? _photoFromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      
      // Return null if no data
      if (data == null) {
        debugPrint('⚠️ Skipping photo document ${doc.id}: no data');
        return null;
      }
      
      // Helper to safely get Timestamp and convert to DateTime
      DateTime? parseTimestamp(dynamic value) {
        if (value == null) {
          return null;
        }
        if (value is Timestamp) {
          return value.toDate();
        }
        if (value is DateTime) {
          return value;
        }
        return null;
      }
      
      // Validate required fields
      final id = data['id'] as String?;
      final userId = data['userId'] as String?;
      final cloudUrl = data['cloudUrl'] as String?;
      final dateTaken = parseTimestamp(data['dateTaken']);
      
      if (id == null || id.isEmpty) {
        debugPrint('⚠️ Skipping photo document ${doc.id}: missing id');
        return null;
      }
      
      if (userId == null || userId.isEmpty) {
        debugPrint('⚠️ Skipping photo document ${doc.id}: missing userId');
        return null;
      }
      
      if (cloudUrl == null || cloudUrl.isEmpty) {
        debugPrint('⚠️ Skipping photo document ${doc.id}: missing cloudUrl');
        return null;
      }
      
      if (dateTaken == null) {
        debugPrint('⚠️ Skipping photo document ${doc.id}: missing dateTaken');
        return null;
      }
      
      return PhotoEntity(
        id: id,
        userId: userId,
        cloudUrl: cloudUrl,
        caption: data['caption'] as String?,
        category: data['category'] as String?,        // 🆕 ADDED
        isMilestone: data['isMilestone'] as bool? ?? false,
        isFavorite: data['isFavorite'] as bool? ?? false,  // 🆕 ADDED
        dateTaken: dateTaken,
        createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
        updatedAt: parseTimestamp(data['updatedAt']) ?? DateTime.now(),
        localPath: null,  // Will be populated from local storage if available
        isUploaded: true, // If it's in Firestore, it's uploaded
        isSynced: true,   // If it's in Firestore, it's synced
        isDeleted: data['isDeleted'] as bool? ?? false,
        deletedAt: parseTimestamp(data['deletedAt']),
      );
    } catch (e) {
      debugPrint('⚠️ Error parsing photo document ${doc.id}: $e');
      return null;  // Return null instead of crashing
    }
  }
}