import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '/data/models/category_model.dart';
import '/domain/entities/category_entity.dart';

/// Local data source untuk Category menggunakan Hive
/// 
/// Location: lib/data/datasources/local/category_local_datasource.dart
class CategoryLocalDataSource {
  CategoryLocalDataSource(this._hiveBox);
  
  final Box<CategoryModel> _hiveBox;

  /// Get all categories (non-deleted)
  Future<List<CategoryEntity>> getCategories(String userId) async {
    try {
      final categories = _hiveBox.values
          .where((cat) => cat.userId == userId && !cat.isDeleted)
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) {
          if (a.isDefault && !b.isDefault) {
            return -1;
          }
          if (!a.isDefault && b.isDefault) {
            return 1;
          }
          return a.name.compareTo(b.name);
        });
      
      return categories;
    } catch (e) {
      throw Exception('Failed to get categories from local: $e');
    }
  }

  /// Get category by ID
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      final model = _hiveBox.get(id);
      if (model == null || model.isDeleted) {
        return null;
      }
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get category by id: $e');
    }
  }

  /// Get category by name
  Future<CategoryEntity?> getCategoryByName(String userId, String name) async {
    try {
      final model = _hiveBox.values.firstWhere(
        (cat) => cat.userId == userId && cat.name == name && !cat.isDeleted,
        orElse: () => throw StateError('Not found'),
      );
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  /// Create category
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _hiveBox.put(category.id, model);
      return category;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update category
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    try {
      final existingModel = _hiveBox.get(category.id);
      if (existingModel == null) {
        throw Exception('Category not found');
      }

      final updatedModel = CategoryModel.fromEntity(
        category.copyWith(
          updatedAt: DateTime.now(),
          isSynced: false, // Mark as not synced
        ),
      );
      
      await _hiveBox.put(category.id, updatedModel);
      return updatedModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete category (soft delete)
  Future<void> deleteCategory(String id) async {
    try {
      final model = _hiveBox.get(id);
      if (model == null) {
        throw Exception('Category not found');
      }

      // Don't delete default categories
      if (model.isDefault) {
        throw Exception('Cannot delete default category');
      }

      final deletedModel = model.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
        isSynced: false,
      );

      await _hiveBox.put(id, deletedModel);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Initialize default categories if not exists
  Future<void> initializeDefaultCategories(String userId) async {
    try {
      // Check if default categories already exist
      final existingDefaults = _hiveBox.values
          .where((cat) => cat.userId == userId && cat.isDefault)
          .toList();

      if (existingDefaults.isNotEmpty) {
        return; // Already initialized
      }

      // UPDATED: Use new DefaultCategories.all instead of defaults
      final defaults = DefaultCategories.all;
      final now = DateTime.now();

      for (var i = 0; i < defaults.length; i++) {
        final defaultCat = defaults[i];
        final id = 'default_category_${userId}_$i';
        
        final category = CategoryModel(
          id: id,
          userId: userId,
          name: defaultCat['name'] as String,
          icon: defaultCat['icon'] as String,
          colorHex: defaultCat['colorHex'] as String,
          type: defaultCat['type'] as String? ?? 'both',  // NEW FIELD
          isDefault: true,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
        );

        await _hiveBox.put(id, category);
      }
    } catch (e) {
      throw Exception('Failed to initialize default categories: $e');
    }
  }

  /// Get unsynced categories (for sync to Firebase)
  Future<List<CategoryEntity>> getUnsyncedCategories(String userId) async {
    try {
      return _hiveBox.values
          .where((cat) => cat.userId == userId && !cat.isSynced)
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get unsynced categories: $e');
    }
  }

  /// Mark category as synced
  Future<void> markAsSynced(String id) async {
    try {
      final model = _hiveBox.get(id);
      if (model != null) {
        final syncedModel = model.copyWith(isSynced: true);
        await _hiveBox.put(id, syncedModel);
      }
    } catch (e) {
      throw Exception('Failed to mark category as synced: $e');
    }
  }

  /// Bulk save categories (from Firebase) - MERGE, don't overwrite
  Future<void> bulkSaveCategories(List<CategoryEntity> categories) async {
    try {
      for (final category in categories) {
        final model = CategoryModel.fromEntity(category);
        
        // FIX: Check existing before overwriting
        final existing = _hiveBox.get(category.id);
        
        if (existing != null) {
          // NEVER overwrite default categories
          if (existing.isDefault) {
            debugPrint('Skipping default category: ${existing.name}');
            continue;  // Protect default categories
          }
          
          // Existing category found, compare timestamps
          if (category.updatedAt.isAfter(existing.updatedAt)) {
            // Remote is newer, update
            await _hiveBox.put(category.id, model);
            debugPrint('Updated category from remote: ${category.name}');
          } else {
            debugPrint('Keeping local category (newer): ${existing.name}');
          }
        } else {
          // New category from remote, add it
          await _hiveBox.put(category.id, model);
          debugPrint('Added new category from remote: ${category.name}');
        }
      }
    } catch (e) {
      throw Exception('Failed to bulk save categories: $e');
    }
  }

  /// Clear all categories (for testing or logout)
  Future<void> clearAllCategories() async {
    try {
      await _hiveBox.clear();
    } catch (e) {
      throw Exception('Failed to clear categories: $e');
    }
  }

  /// Get count of categories
  Future<int> getCategoryCount(String userId) async {
    try {
      return _hiveBox.values
          .where((cat) => cat.userId == userId && !cat.isDeleted)
          .length;
    } catch (e) {
      return 0;
    }
  }
}