/// Photo Remote Datasource
/// 
/// Handles photo operations with Firebase Storage and Firestore
/// Location: lib/data/datasources/remote/photo_remote_datasource.dart
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/photo_entity.dart';
import 'firebase_service.dart';

/// Interface untuk Photo Remote Datasource
abstract class PhotoRemoteDatasource {
  Future<String> uploadPhoto(File photoFile, String photoId);
  Future<void> createPhotoMetadata(PhotoEntity photo);
  Future<List<PhotoEntity>> getAllPhotos();
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
          .orderBy('dateTaken', descending: true)
          .get();

      return snapshot.docs.map(_photoFromFirestore).toList();
    } catch (e) {
      throw DatabaseException('Gagal mengambil foto: $e');
    }
  }

  @override
  Future<void> updatePhoto(PhotoEntity photo) async {
    try {
      if (_photosCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final data = _photoToFirestore(photo);
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _photosCollection!.doc(photo.id).update(data);
      debugPrint('✅ Photo updated: ${photo.id}');
    } catch (e) {
      throw DatabaseException('Gagal memperbarui foto: $e');
    }
  }

  @override
  Future<void> deletePhoto(String photoId, String downloadUrl) async {
    try {
      if (_photosCollection == null || _userPhotosRef == null) {
        throw const AuthorizationException('User tidak login');
      }

      // Delete from Storage
      final ref = _firebaseService.storage.refFromURL(downloadUrl);
      await ref.delete();
      debugPrint('✅ Photo deleted from Storage');

      // Delete metadata
      await _photosCollection!.doc(photoId).delete();
      debugPrint('✅ Photo metadata deleted: $photoId');
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // File already deleted, just remove metadata
        await _photosCollection!.doc(photoId).delete();
      } else {
        throw StorageException(FirebaseErrorHandler.getErrorMessage(e));
      }
    } catch (e) {
      throw StorageException('Gagal menghapus foto: $e');
    }
  }

  @override
  Stream<List<PhotoEntity>> watchPhotos() {
    if (_photosCollection == null) {
      return Stream.error(const AuthorizationException('User tidak login'));
    }

    return _photosCollection!
        .orderBy('dateTaken', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_photoFromFirestore).toList());
  }

  Map<String, dynamic> _photoToFirestore(PhotoEntity photo) => {
      'id': photo.id,
      'userId': photo.userId,
      'cloudUrl': photo.cloudUrl,
      'caption': photo.caption,
      'isMilestone': photo.isMilestone,
      'dateTaken': Timestamp.fromDate(photo.dateTaken),
      'createdAt': Timestamp.fromDate(photo.createdAt),
      'updatedAt': Timestamp.fromDate(photo.updatedAt),
    };

  PhotoEntity _photoFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoEntity(
      id: data['id'] as String,
      userId: data['userId'] as String,
      cloudUrl: data['cloudUrl'] as String,
      caption: data['caption'] as String? ?? '',
      isMilestone: data['isMilestone'] as bool,
      dateTaken: (data['dateTaken'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}