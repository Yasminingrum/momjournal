import '/data/repositories/category_repository.dart';
import '/domain/entities/category_entity.dart';

/// Use case untuk get categories
/// 
/// Location: lib/domain/usecases/category/get_categories.dart
class GetCategories {
  GetCategories(this.repository);

  final CategoryRepository repository;

  Future<List<CategoryEntity>> call(String userId) async => repository.getCategories(userId);
}