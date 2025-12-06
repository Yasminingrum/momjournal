import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/photo_repository.dart';
import '../domain/entities/photo_entity.dart';

/// ViewModel for Photo management
/// Manages photo state and business logic using Provider pattern
class PhotoProvider extends ChangeNotifier {
  final PhotoRepository _repository = PhotoRepository();
  final Uuid _uuid = const Uuid();

  List<PhotoEntity> _photos = [];
  List<PhotoEntity> _milestonePhotos = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;
  int _currentPage = 0;
  static const int _pageSize = 20;

  // Getters
  List<PhotoEntity> get photos => _photos;
  List<PhotoEntity> get milestonePhotos => _milestonePhotos;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  /// Initialize provider
  Future<void> init() async {
    await _repository.init();
    await loadPhotos();
    await loadMilestonePhotos();
  }

  /// Load all photos (with pagination)
  Future<void> loadPhotos({bool refresh = false}) async {
    try {
      _setLoading(true);
      
      if (refresh) {
        _currentPage = 0;
      }
      
      final newPhotos = await _repository.getPhotosPaginated(_currentPage, _pageSize);
      
      if (refresh) {
        _photos = newPhotos;
      } else {
        _photos.addAll(newPhotos);
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to load photos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more photos (pagination)
  Future<void> loadMorePhotos() async {
    _currentPage++;
    await loadPhotos();
  }

  /// Load milestone photos only
  Future<void> loadMilestonePhotos() async {
    try {
      _milestonePhotos = await _repository.getMilestonePhotos();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load milestone photos: $e');
    }
  }

  /// Create a new photo entry
  Future<bool> createPhoto({
    required String localPath,
    String? caption,
    bool isMilestone = false,
    DateTime? dateTaken,
    String? userId,
  }) async {
    try {
      _setLoading(true);
      
      final photo = PhotoEntity(
        id: _uuid.v4(),
        userId: userId ?? 'default_user',
        localPath: localPath,
        caption: caption,
        isMilestone: isMilestone,
        dateTaken: dateTaken ?? DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createPhoto(photo);
      await loadPhotos(refresh: true);
      
      if (isMilestone) {
        await loadMilestonePhotos();
      }
      
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
      await loadPhotos(refresh: true);
      
      if (photo.isMilestone) {
        await loadMilestonePhotos();
      }
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update cloud URL after upload
  Future<bool> updateCloudUrl(String id, String cloudUrl) async {
    try {
      await _repository.updateCloudUrl(id, cloudUrl);
      await loadPhotos(refresh: true);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update cloud URL: $e');
      return false;
    }
  }

  /// Delete a photo
  Future<bool> deletePhoto(String id) async {
    try {
      _setLoading(true);
      await _repository.deletePhoto(id);
      await loadPhotos(refresh: true);
      await loadMilestonePhotos();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get photo by ID
  Future<PhotoEntity?> getPhotoById(String id) async {
    try {
      return await _repository.getPhotoById(id);
    } catch (e) {
      _setError('Failed to get photo: $e');
      return null;
    }
  }

  /// Get photo count
  Future<int> getPhotoCount() async {
    try {
      return await _repository.getPhotoCount();
    } catch (e) {
      _setError('Failed to get photo count: $e');
      return 0;
    }
  }

  /// Get milestone count
  Future<int> getMilestoneCount() async {
    try {
      return await _repository.getMilestoneCount();
    } catch (e) {
      _setError('Failed to get milestone count: $e');
      return 0;
    }
  }

  /// Simulate upload progress (for demo purposes)
  /// In production, this would track actual Firebase Storage upload
  Future<void> simulateUpload() async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      _uploadProgress = i / 100;
      notifyListeners();
    }

    _isUploading = false;
    notifyListeners();
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

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}