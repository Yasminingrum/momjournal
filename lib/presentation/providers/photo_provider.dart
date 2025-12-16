import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '/data/repositories/photo_repository.dart';
import '/domain/entities/photo_entity.dart';

/// ViewModel for Photo management
/// Manages photo state and business logic using Provider pattern
class PhotoProvider extends ChangeNotifier {
  PhotoProvider();

  final PhotoRepository _repository = PhotoRepository();
  final Uuid _uuid = const Uuid();

  List<PhotoEntity> _photos = [];
  List<PhotoEntity> _milestonePhotos = [];
  DateTime _selectedDate = DateTime.now();
  bool _showMilestonesOnly = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PhotoEntity> get photos => _photos;
  List<PhotoEntity> get milestonePhotos => _milestonePhotos;
  DateTime get selectedDate => _selectedDate;
  bool get showMilestonesOnly => _showMilestonesOnly;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorMessage => _error; // Alias untuk compatibility

  /// Initialize provider - for compatibility
  Future<void> init() async {
    await loadPhotos();
  }

  /// Load all photos
  Future<void> loadPhotos() async {
    try {
      _setLoading(true);
      _photos = await _repository.getAllPhotos();
      _milestonePhotos = await _repository.getMilestonePhotos();
      _clearError();
    } catch (e) {
      _setError('Failed to load photos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load photos for selected date
  Future<void> loadPhotosForDate(DateTime date) async {
    try {
      _setLoading(true);
      _selectedDate = date;
      _photos = await _repository.getPhotosByDate(date);
      _clearError();
    } catch (e) {
      _setError('Failed to load photos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load photos for a month
  Future<void> loadPhotosForMonth(int year, int month) async {
    try {
      _setLoading(true);
      _photos = await _repository.getPhotosByMonth(year, month);
      _clearError();
    } catch (e) {
      _setError('Failed to load photos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load photos by date range
  Future<void> loadPhotosByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _setLoading(true);
      _photos = await _repository.getPhotosByDateRange(startDate, endDate);
      _clearError();
    } catch (e) {
      _setError('Failed to load photos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle milestone filter
  Future<void> toggleMilestoneFilter() async {
    _showMilestonesOnly = !_showMilestonesOnly;
    notifyListeners();

    if (_showMilestonesOnly) {
      try {
        _setLoading(true);
        _photos = await _repository.getMilestonePhotos();
        _clearError();
      } catch (e) {
        _setError('Failed to load milestone photos: $e');
      } finally {
        _setLoading(false);
      }
    } else {
      await loadPhotos();
    }
  }

  /// Upload photo - simplified version
  Future<bool> uploadPhoto({
    required String imagePath,
    String? caption,
    bool isMilestone = false,
    String? userId,
  }) async => createPhoto(
      localPath: imagePath,
      dateTaken: DateTime.now(),
      caption: caption,
      isMilestone: isMilestone,
      userId: userId,
    );

  /// Get photo count
  Future<int> getPhotoCount() async {
    try {
      final allPhotos = await _repository.getAllPhotos();
      return allPhotos.length;
    } catch (e) {
      return 0;
    }
  }

  /// Create a new photo
  Future<bool> createPhoto({
    required String localPath,
    required DateTime dateTaken,
    String? caption,
    bool isMilestone = false,
    String? userId,
  }) async {
    try {
      _setLoading(true);

      final photo = PhotoEntity(
        id: _uuid.v4(),
        userId: userId ?? 'default_user',
        localPath: localPath,
        caption: caption,
        dateTaken: dateTaken,
        isMilestone: isMilestone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createPhoto(photo);
      await loadPhotos();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to create photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing photo
  Future<bool> updatePhoto(PhotoEntity photo) async {
    try {
      _setLoading(true);
      await _repository.updatePhoto(photo);
      await loadPhotos();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a photo
  Future<bool> deletePhoto(String id) async {
    try {
      _setLoading(true);
      await _repository.deletePhoto(id);
      await loadPhotos();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get recent photos
  Future<List<PhotoEntity>> getRecentPhotos(int count) async {
    try {
      return await _repository.getRecentPhotos(count);
    } catch (e) {
      _setError('Failed to get recent photos: $e');
      return [];
    }
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadPhotosForDate(date);
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear error - public method
  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}