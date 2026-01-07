library;

import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../../data/repositories/sync_repository.dart';

class SyncProvider with ChangeNotifier {

  SyncProvider({
    required SyncRepository repository,
  }) : _repository = repository;
  final SyncRepository _repository;

  // State
  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSyncTime;
  String? _errorMessage;
  SyncResult? _lastResult;
  bool _autoSyncEnabled = true;

  // Getters
  SyncStatus get status => _status;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;
  SyncResult? get lastResult => _lastResult;
  bool get isSyncing => _status == SyncStatus.syncing;
  bool get autoSyncEnabled => _autoSyncEnabled;

  String get lastSyncTimeFormatted {
    if (_lastSyncTime == null) {
      return 'Belum pernah sync';
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return '${difference.inDays} hari yang lalu';
    }
  }

  /// Perform full sync
  Future<bool> syncAll() async {
    if (_status == SyncStatus.syncing) {
      return false;
    }

    try {
      _setStatus(SyncStatus.syncing);
      _errorMessage = null;
      
      final result = await _repository.syncAll();
      
      _lastResult = result;
      _lastSyncTime = DateTime.now();

      if (result.hasErrors) {
        _errorMessage = result.errors.join(', ');
        _setStatus(SyncStatus.error);
        return false;
      } else {
        _setStatus(SyncStatus.success);
        
        // Auto-reset to idle after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (_status == SyncStatus.success) {
            _setStatus(SyncStatus.idle);
          }
        });
        
        return true;
      }
    } on SyncException catch (e) {
      _errorMessage = e.message;
      _setStatus(SyncStatus.error);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat sync';
      _setStatus(SyncStatus.error);
      return false;
    }
  }

  /// Sync only schedules
  Future<bool> syncSchedules() async {
    try {
      _setStatus(SyncStatus.syncing);
      await _repository.syncSchedules();
      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      
      Future.delayed(const Duration(seconds: 2), () {
        if (_status == SyncStatus.success) {
          _setStatus(SyncStatus.idle);
        }
      });
      
      return true;
    } catch (e) {
      _errorMessage = 'Gagal sync schedules';
      _setStatus(SyncStatus.error);
      return false;
    }
  }

  /// Sync only journals
  Future<bool> syncJournals() async {
    try {
      _setStatus(SyncStatus.syncing);
      await _repository.syncJournals();
      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      
      Future.delayed(const Duration(seconds: 2), () {
        if (_status == SyncStatus.success) {
          _setStatus(SyncStatus.idle);
        }
      });
      
      return true;
    } catch (e) {
      _errorMessage = 'Gagal sync journals';
      _setStatus(SyncStatus.error);
      return false;
    }
  }

  /// Sync only photos
  Future<bool> syncPhotos() async {
    try {
      _setStatus(SyncStatus.syncing);
      await _repository.syncPhotos();
      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      
      Future.delayed(const Duration(seconds: 2), () {
        if (_status == SyncStatus.success) {
          _setStatus(SyncStatus.idle);
        }
      });
      
      return true;
    } catch (e) {
      _errorMessage = 'Gagal sync photos';
      _setStatus(SyncStatus.error);
      return false;
    }
  }

  /// Delete photo from remote (Firebase)
  Future<void> deletePhotoRemote(String photoId) async {
    try {
      await _repository.deletePhotoRemote(photoId);
      debugPrint('✅ Photo deleted from remote: $photoId');
    } catch (e) {
      debugPrint('❌ Failed to delete photo from remote: $e');
      // Don't throw - deletion should succeed locally even if remote fails
    }
  }

  /// Toggle auto sync
  void toggleAutoSync({required bool enabled}) {
    _autoSyncEnabled = enabled;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    if (_status == SyncStatus.error) {
      _setStatus(SyncStatus.idle);
    }
  }

  /// Reset sync state
  void reset() {
    _status = SyncStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(SyncStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}