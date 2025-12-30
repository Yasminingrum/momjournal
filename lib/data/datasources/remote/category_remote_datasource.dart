import 'package:cloud_firestore/cloud_firestore.dart';

import '/data/models/category_model.dart';
import '/domain/entities/category_entity.dart';

/// Remote data source untuk Category menggunakan Firebase Firestore
/// 
/// Location: lib/data/datasources/remote/category_remote_datasource.dart
class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._firestore);
  
  final FirebaseFirestore _firestore;

  /// Collection reference
  CollectionReference get _categoriesCollection => 
      _firestore.collection('categories');

  /// Get all categories for user
  Future<List<CategoryEntity>> getCategories(String userId) async {
    try {
      final querySnapshot = await _categoriesCollection
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromJson(
                doc.data() as Map<String, dynamic>,
              ).toEntity(),)
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories from Firebase: $e');
    }
  }

  /// Get category by ID
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      final docSnapshot = await _categoriesCollection.doc(id).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      final model = CategoryModel.fromJson(data);
      
      if (model.isDeleted) {
        return null;
      }
      
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get category by id from Firebase: $e');
    }
  }

  /// Create category
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _categoriesCollection.doc(category.id).set(model.toJson());
      return category;
    } catch (e) {
      throw Exception('Failed to create category in Firebase: $e');
    }
  }

  /// Update category
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel.fromEntity(
        category.copyWith(updatedAt: DateTime.now()),
      );
      
      await _categoriesCollection.doc(category.id).update(model.toJson());
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to update category in Firebase: $e');
    }
  }

  /// Delete category (soft delete)
  Future<void> deleteCategory(String id) async {
    try {
      await _categoriesCollection.doc(id).update({
        'isDeleted': true,
        'deletedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to delete category in Firebase: $e');
    }
  }

  /// Sync categories to Firebase (batch upload)
  Future<void> syncCategories(List<CategoryEntity> categories) async {
    try {
      final batch = _firestore.batch();

      for (final category in categories) {
        final model = CategoryModel.fromEntity(category);
        final docRef = _categoriesCollection.doc(category.id);
        batch.set(docRef, model.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to sync categories to Firebase: $e');
    }
  }

  /// Get categories updated after a certain timestamp (for sync)
  Future<List<CategoryEntity>> getCategoriesUpdatedAfter(
    String userId,
    DateTime timestamp,
  ) async {
    try {
      final querySnapshot = await _categoriesCollection
          .where('userId', isEqualTo: userId)
          .where('updatedAt', isGreaterThan: timestamp.toIso8601String())
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromJson(
                doc.data() as Map<String, dynamic>,
              ).toEntity(),)
          .toList();
    } catch (e) {
      throw Exception('Failed to get updated categories from Firebase: $e');
    }
  }

  /// Bulk upsert categories (create or update)
  Future<void> bulkUpsertCategories(List<CategoryEntity> categories) async {
    try {
      final batch = _firestore.batch();

      for (final category in categories) {
        final model = CategoryModel.fromEntity(category);
        final docRef = _categoriesCollection.doc(category.id);
        batch.set(docRef, model.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk upsert categories: $e');
    }
  }

  /// Delete all categories for user (for cleanup/testing)
  Future<void> deleteAllUserCategories(String userId) async {
    try {
      final querySnapshot = await _categoriesCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all user categories: $e');
    }
  }

  /// Listen to category changes (real-time)
  Stream<List<CategoryEntity>> watchCategories(String userId) => _categoriesCollection
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ).toEntity(),)
            .toList(),);
}