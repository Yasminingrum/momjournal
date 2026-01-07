import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/category_repository.dart';
import '../../domain/entities/category_entity.dart';

/// Provider untuk Category state management
/// 
/// Location: lib/presentation/providers/category_provider.dart
class CategoryProvider extends ChangeNotifier {
  CategoryProvider({required this.repository});

  final CategoryRepository repository;
  final _uuid = const Uuid();

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// ✅ NEW: Get categories untuk Schedule (schedule + both)
  List<CategoryEntity> get scheduleCategories => _categories
      .where((c) => c.type == CategoryType.schedule || c.type == CategoryType.both)
      .toList();

  /// ✅ NEW: Get categories untuk Photo (photo + both)
  List<CategoryEntity> get photoCategories => _categories
      .where((c) => c.type == CategoryType.photo || c.type == CategoryType.both)
      .toList();

  /// Get categories as list of maps for UI
  List<Map<String, String>> get categoriesAsMaps => _categories.map((cat) => {
      'name': cat.name,
      'icon': cat.icon,
      'colorHex': cat.colorHex,
    },).toList();

  /// Load categories for user
  Future<void> loadCategories(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await repository.getCategories(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize default categories if needed
  Future<void> initializeDefaultCategories(String userId) async {
    try {
      final count = await repository.getCategoryCount(userId);
      
      if (count == 0) {
        await repository.initializeDefaultCategories(userId);
        await loadCategories(userId);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Create new category
  Future<bool> createCategory({
    required String userId,
    required String name,
    required String icon,
    required String colorHex,
  }) async {
    _error = null;

    try {
      final category = CategoryEntity(
        id: _uuid.v4(),
        userId: userId,
        name: name,
        icon: icon,
        colorHex: colorHex,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      final savedCategory = await repository.createCategory(category);
      _categories.add(savedCategory);
      _sortCategories();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update category
  Future<bool> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? colorHex,
  }) async {
    _error = null;

    try {
      final index = _categories.indexWhere((cat) => cat.id == id);
      if (index == -1) {
        _error = 'Category not found';
        notifyListeners();
        return false;
      }

      final oldCategory = _categories[index];
      final updatedCategory = oldCategory.copyWith(
        name: name,
        icon: icon,
        colorHex: colorHex,
        updatedAt: DateTime.now(),
      );

      final saved = await repository.updateCategory(updatedCategory);
      _categories[index] = saved;
      _sortCategories();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete category
  Future<bool> deleteCategory(String id) async {
    _error = null;

    try {
      await repository.deleteCategory(id);
      _categories.removeWhere((cat) => cat.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get category by name
  CategoryEntity? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Check if category name exists
  bool categoryExists(String name, {String? excludeId}) => _categories.any((cat) => 
      cat.name.toLowerCase() == name.toLowerCase() && 
      cat.id != excludeId,
    );

  /// Sync to remote
  Future<void> syncToRemote(String userId) async {
    try {
      await repository.syncToRemote(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Sync from remote
  Future<void> syncFromRemote(String userId) async {
    try {
      await repository.syncFromRemote(userId);
      await loadCategories(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear all (for logout)
  void clear() {
    _categories = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Helper methods

  void _sortCategories() {
    _categories.sort((a, b) {
      // Default categories first
      if (a.isDefault && !b.isDefault) {
        return -1;
      }
      if (!a.isDefault && b.isDefault) {
        return 1;
      }
      // Then sort by name
      return a.name.compareTo(b.name);
    });
  }
}