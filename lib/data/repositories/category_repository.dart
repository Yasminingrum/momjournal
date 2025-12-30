import '../../domain/entities/category_entity.dart';
import '../datasources/local/category_local_datasource.dart';
import '../datasources/remote/category_remote_datasource.dart';

/// Repository untuk Category
/// Implements offline-first pattern dengan sync ke Firebase
/// 
/// Location: lib/data/repositories/category_repository.dart
class CategoryRepository {
  CategoryRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final CategoryLocalDataSource localDataSource;
  final CategoryRemoteDataSource remoteDataSource;

  /// Get all categories (offline-first)
  Future<List<CategoryEntity>> getCategories(String userId) async {
    try {
      // Always get from local first (offline-first)
      final localCategories = await localDataSource.getCategories(userId);
      
      // Try to sync from remote in background
      _syncFromRemote(userId);
      
      return localCategories;
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  /// Get category by ID
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      return await localDataSource.getCategoryById(id);
    } catch (e) {
      throw Exception('Failed to get category by id: $e');
    }
  }

  /// Get category by name
  Future<CategoryEntity?> getCategoryByName(
    String userId,
    String name,
  ) async {
    try {
      return await localDataSource.getCategoryByName(userId, name);
    } catch (e) {
      throw Exception('Failed to get category by name: $e');
    }
  }

  /// Create category
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    try {
      // Save to local first
      final savedCategory = await localDataSource.createCategory(category);
      
      // Try to sync to remote in background
      _syncCategoryToRemote(savedCategory);
      
      return savedCategory;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update category
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    try {
      // Update local first
      final updatedCategory = await localDataSource.updateCategory(category);
      
      // Try to sync to remote in background
      _syncCategoryToRemote(updatedCategory);
      
      return updatedCategory;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete category
  Future<void> deleteCategory(String id) async {
    try {
      // Soft delete in local
      await localDataSource.deleteCategory(id);
      
      // Try to sync deletion to remote in background
      await remoteDataSource.deleteCategory(id).catchError((_) {
        // Ignore remote errors, will sync later
      });
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Initialize default categories
  Future<void> initializeDefaultCategories(String userId) async {
    try {
      await localDataSource.initializeDefaultCategories(userId);
      
      // ✅ FIX: IMMEDIATELY sync defaults to Firebase
      final defaults = await localDataSource.getCategories(userId);
      
      // Upload to Firebase synchronously
      try {
        await remoteDataSource.syncCategories(defaults);
        print('✅ Default categories synced to Firebase');
        
        // Mark all as synced
        for (final category in defaults) {
          await localDataSource.markAsSynced(category.id);
        }
      } catch (syncError) {
        print('⚠️ Failed to sync defaults to Firebase: $syncError');
        // Continue anyway, will sync later
      }
    } catch (e) {
      throw Exception('Failed to initialize default categories: $e');
    }
  }

  /// Sync all unsynced categories to Firebase
  Future<void> syncToRemote(String userId) async {
    try {
      final unsyncedCategories = 
          await localDataSource.getUnsyncedCategories(userId);
      
      if (unsyncedCategories.isEmpty) {
        return;
      }

      // Upload to Firebase
      await remoteDataSource.syncCategories(unsyncedCategories);
      
      // Mark as synced in local
      for (final category in unsyncedCategories) {
        await localDataSource.markAsSynced(category.id);
      }
    } catch (e) {
      throw Exception('Failed to sync to remote: $e');
    }
  }

  /// Sync from Firebase to local
  Future<void> syncFromRemote(String userId) async {
    try {
      final remoteCategories = await remoteDataSource.getCategories(userId);
      await localDataSource.bulkSaveCategories(remoteCategories);
    } catch (e) {
      throw Exception('Failed to sync from remote: $e');
    }
  }

  /// Get category count
  Future<int> getCategoryCount(String userId) async {
    try {
      return await localDataSource.getCategoryCount(userId);
    } catch (e) {
      return 0;
    }
  }

  /// Watch categories (real-time stream)
  Stream<List<CategoryEntity>> watchCategories(String userId) {
    try {
      return remoteDataSource.watchCategories(userId);
    } catch (e) {
      // If remote fails, return empty stream
      return Stream.value([]);
    }
  }

  // Private helper methods for background sync

  void _syncFromRemote(String userId) {
    remoteDataSource.getCategories(userId).then(localDataSource.bulkSaveCategories).catchError((_) {
      // Ignore errors, offline-first approach
    });
  }

  void _syncCategoryToRemote(CategoryEntity category) {
    remoteDataSource
        .createCategory(category)
        .then((_) => localDataSource.markAsSynced(category.id))
        .catchError((_) {
      // Will sync later
    });
  }

  void _syncCategoriesToRemote(List<CategoryEntity> categories) {
    remoteDataSource.syncCategories(categories).then((_) {
      for (final category in categories) {
        localDataSource.markAsSynced(category.id);
      }
    }).catchError((_) {
      // Will sync later
    });
  }
}