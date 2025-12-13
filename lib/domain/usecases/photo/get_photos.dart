import '../../../data/repositories/photo_repository.dart';
import '../../entities/photo_entity.dart';

class GetPhotosUseCase {

  GetPhotosUseCase(this.repository);
  final PhotoRepository repository;

  /// Get all photos
  Future<List<PhotoEntity>> execute() async {
    try {
      final photos = await repository.getAllPhotos();
      print('✅ UseCase: Retrieved ${photos.length} photos');
      return photos;
    } catch (e) {
      print('❌ UseCase: Failed to get photos: $e');
      rethrow;
    }
  }

  /// Get photos with pagination
  Future<List<PhotoEntity>> executeWithPagination({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final allPhotos = await repository.getAllPhotos();
      
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      
      if (startIndex >= allPhotos.length) {
        return [];
      }
      
      final paginatedPhotos = allPhotos.sublist(
        startIndex,
        endIndex > allPhotos.length ? allPhotos.length : endIndex,
      );
      
      print('✅ UseCase: Retrieved ${paginatedPhotos.length} photos (page $page)');
      return paginatedPhotos;
    } catch (e) {
      print('❌ UseCase: Failed to get paginated photos: $e');
      rethrow;
    }
  }

  /// Get milestone photos only
  Future<List<PhotoEntity>> executeMilestonesOnly() async {
    try {
      final allPhotos = await repository.getAllPhotos();
      final milestones = allPhotos.where((p) => p.isMilestone).toList();
      
      print('✅ UseCase: Retrieved ${milestones.length} milestone photos');
      return milestones;
    } catch (e) {
      print('❌ UseCase: Failed to get milestone photos: $e');
      rethrow;
    }
  }

  /// Get photos by month
  Future<List<PhotoEntity>> executeByMonth(int year, int month) async {
    try {
      final allPhotos = await repository.getAllPhotos();
      
      final photosInMonth = allPhotos.where((photo) {
        final capturedDate = photo.createdAt;
        return capturedDate.year == year && capturedDate.month == month;
      }).toList();
      
      print('✅ UseCase: Retrieved ${photosInMonth.length} photos for $year-$month');
      return photosInMonth;
    } catch (e) {
      print('❌ UseCase: Failed to get photos by month: $e');
      rethrow;
    }
  }

  /// Get photos by date range
  Future<List<PhotoEntity>> executeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allPhotos = await repository.getAllPhotos();
      
      final photosInRange = allPhotos.where((photo) {
        final capturedDate = photo.createdAt;
        return capturedDate.isAfter(startDate) && 
               capturedDate.isBefore(endDate);
      }).toList();
      
      print('✅ UseCase: Retrieved ${photosInRange.length} photos for date range');
      return photosInRange;
    } catch (e) {
      print('❌ UseCase: Failed to get photos by date range: $e');
      rethrow;
    }
  }

  /// Get recent photos
  Future<List<PhotoEntity>> executeRecent({int limit = 10}) async {
    try {
      final photos = await repository.getAllPhotos();
      final recent = photos.take(limit).toList();
      
      print('✅ UseCase: Retrieved ${recent.length} recent photos');
      return recent;
    } catch (e) {
      print('❌ UseCase: Failed to get recent photos: $e');
      rethrow;
    }
  }
}