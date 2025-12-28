import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/journal_model.dart';
import '../data/models/photo_model.dart';
import '../data/models/schedule_model.dart';

/// SyncService
/// Handles automatic background synchronization between local Hive database
/// and Firebase Cloud Firestore. Implements offline-first architecture with
/// automatic conflict resolution.
///
/// Features:
/// - Auto-sync when connection becomes available
/// - Sync queue for failed operations
/// - Conflict resolution (last-write-wins)
/// - Background sync timer
/// - Sync status notifications
class SyncService extends ChangeNotifier {

  SyncService({required String userId}) : _userId = userId {
    _initialize();
  }
  // Connectivity monitoring
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Sync state
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _pendingSyncCount = 0;
  String? _syncError;

  // Firestore references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId;

  // Sync timer for periodic background sync
  Timer? _syncTimer;
  static const Duration _syncInterval = Duration(minutes: 5);

  // Sync queue for failed operations
  final List<Map<String, dynamic>> _syncQueue = [];

  // Getters
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncCount => _pendingSyncCount;
  String? get syncError => _syncError;
  bool get hasPendingSync => _pendingSyncCount > 0;

  /// Initialize sync service
  void _initialize() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );

    // Start periodic sync timer
    _startSyncTimer();

    // Perform initial sync check
    _checkAndSync();
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      debugPrint('ðŸ“¡ Connectivity restored: $result');
      // Connection available, trigger sync
      syncAll();
    } else {
      debugPrint('ðŸ“¡ Connection lost');
    }
  }

  /// Start periodic sync timer
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      _checkAndSync();
    });
  }

  /// Check connectivity and sync if available
  Future<void> _checkAndSync() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await syncAll();
    }
  }

  /// Sync all data (schedules, journals, photos)
  Future<void> syncAll() async {
    if (_isSyncing) {
      debugPrint('âš ï¸ Sync already in progress');
      return;
    }

    try {
      _isSyncing = true;
      _syncError = null;
      notifyListeners();

      debugPrint('ðŸ”„ Starting full sync...');

      // Process sync queue first
      await _processSyncQueue();

      // Sync schedules
      await _syncSchedules();

      // Sync journals
      await _syncJournals();

      // Sync photos metadata (actual files handled separately)
      await _syncPhotos();

      _lastSyncTime = DateTime.now();
      _pendingSyncCount = 0;

      debugPrint('âœ… Sync completed successfully');
    } catch (e) {
      _syncError = e.toString();
      debugPrint('âŒ Sync failed: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync schedules
  Future<void> _syncSchedules() async {
    try {
      // Get the already-opened box (opened by HiveDatabase)
      final schedulesBox = Hive.box<ScheduleModel>('schedules');
      final cloudSchedules = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('schedules')
          .get();

      // Create map of cloud schedules for quick lookup
      final cloudScheduleMap = <String, DocumentSnapshot>{};
      for (final doc in cloudSchedules.docs) {
        cloudScheduleMap[doc.id] = doc;
      }

      // Sync local to cloud
      for (final key in schedulesBox.keys) {
        final localSchedule = schedulesBox.get(key);
        if (localSchedule == null) {
          continue;
        }
        
        final scheduleId = localSchedule.id;
        final cloudDoc = cloudScheduleMap[scheduleId];

        if (cloudDoc == null) {
          // Not in cloud, upload
          await _uploadSchedule(localSchedule);
        } else {
          // Exists in cloud, check if needs update
          await _syncScheduleConflict(localSchedule, cloudDoc);
        }
      }

      // Sync cloud to local (download new schedules)
      for (final doc in cloudSchedules.docs) {
        if (!schedulesBox.containsKey(doc.id)) {
          final cloudData = doc.data();
          final scheduleModel = ScheduleModel.fromJson(cloudData);
          await schedulesBox.put(doc.id, scheduleModel);
        }
      }

      debugPrint('âœ… Schedules synced');
    } catch (e) {
      debugPrint('âŒ Schedule sync failed: $e');
      _addToSyncQueue('schedules', null);
      rethrow;
    }
  }

  /// Upload schedule to cloud
  Future<void> _uploadSchedule(ScheduleModel schedule) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('schedules')
        .doc(schedule.id)
        .set(schedule.toJson());
  }

  /// Resolve schedule sync conflict (last-write-wins)
  Future<void> _syncScheduleConflict(
    ScheduleModel localSchedule,
    DocumentSnapshot cloudDoc,
  ) async {
    final cloudData = cloudDoc.data() as Map<String, dynamic>;
    final cloudSchedule = ScheduleModel.fromJson(cloudData);

    if (localSchedule.updatedAt.isAfter(cloudSchedule.updatedAt)) {
      // Local is newer, upload
      await _uploadSchedule(localSchedule);
    } else if (cloudSchedule.updatedAt.isAfter(localSchedule.updatedAt)) {
      // Cloud is newer, download
      final schedulesBox = Hive.box<ScheduleModel>('schedules');
      await schedulesBox.put(cloudSchedule.id, cloudSchedule);
    }
    // If equal, no sync needed
  }

  /// Sync journals
  Future<void> _syncJournals() async {
    try {
      // Get the already-opened box (opened by HiveDatabase)
      final journalsBox = Hive.box<JournalModel>('journals');
      final cloudJournals = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('journals')
          .get();

      // Create map of cloud journals
      final cloudJournalMap = <String, DocumentSnapshot>{};
      for (final doc in cloudJournals.docs) {
        cloudJournalMap[doc.id] = doc;
      }

      // Sync local to cloud
      for (final key in journalsBox.keys) {
        final localJournal = journalsBox.get(key);
        if (localJournal == null) {
          continue;
        }
        
        final journalId = localJournal.id;
        final cloudDoc = cloudJournalMap[journalId];

        if (cloudDoc == null) {
          // Not in cloud, upload
          await _uploadJournal(localJournal);
        } else {
          // Exists in cloud, check if needs update
          await _syncJournalConflict(localJournal, cloudDoc);
        }
      }

      // Sync cloud to local
      for (final doc in cloudJournals.docs) {
        if (!journalsBox.containsKey(doc.id)) {
          final cloudData = doc.data();
          final journalModel = JournalModel.fromJson(cloudData);
          await journalsBox.put(doc.id, journalModel);
        }
      }

      debugPrint('âœ… Journals synced');
    } catch (e) {
      debugPrint('âŒ Journal sync failed: $e');
      _addToSyncQueue('journals', null);
      rethrow;
    }
  }

  /// Upload journal to cloud
  Future<void> _uploadJournal(JournalModel journal) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journal.id)
        .set(journal.toJson());
  }

  /// Resolve journal sync conflict
  Future<void> _syncJournalConflict(
    JournalModel localJournal,
    DocumentSnapshot cloudDoc,
  ) async {
    final cloudData = cloudDoc.data() as Map<String, dynamic>;
    final cloudJournal = JournalModel.fromJson(cloudData);

    if (localJournal.updatedAt.isAfter(cloudJournal.updatedAt)) {
      await _uploadJournal(localJournal);
    } else if (cloudJournal.updatedAt.isAfter(localJournal.updatedAt)) {
      final journalsBox = Hive.box<JournalModel>('journals');
      await journalsBox.put(cloudJournal.id, cloudJournal);
    }
  }

  /// Sync photos metadata
  Future<void> _syncPhotos() async {
    try {
      // Get the already-opened box (opened by HiveDatabase)
      final photosBox = Hive.box<PhotoModel>('photos');
      final cloudPhotos = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('photos')
          .get();

      // Create map of cloud photos
      final cloudPhotoMap = <String, DocumentSnapshot>{};
      for (final doc in cloudPhotos.docs) {
        cloudPhotoMap[doc.id] = doc;
      }

      // Sync local to cloud
      for (final key in photosBox.keys) {
        final localPhoto = photosBox.get(key);
        if (localPhoto == null) {
          continue;
        }
        
        final photoId = localPhoto.id;
        final cloudDoc = cloudPhotoMap[photoId];

        if (cloudDoc == null) {
          // Not in cloud, upload metadata
          await _uploadPhotoMetadata(localPhoto);
        } else {
          // Exists in cloud, check if needs update
          await _syncPhotoConflict(localPhoto, cloudDoc);
        }
      }

      // Sync cloud to local
      for (final doc in cloudPhotos.docs) {
        if (!photosBox.containsKey(doc.id)) {
          final cloudData = doc.data();
          final photoModel = PhotoModel.fromJson(cloudData);
          await photosBox.put(doc.id, photoModel);
        }
      }

      debugPrint('âœ… Photos synced');
    } catch (e) {
      debugPrint('âŒ Photo sync failed: $e');
      _addToSyncQueue('photos', null);
      rethrow;
    }
  }

  /// Upload photo metadata to cloud
  Future<void> _uploadPhotoMetadata(PhotoModel photo) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('photos')
        .doc(photo.id)
        .set(photo.toJson());
  }

  /// Resolve photo sync conflict
  Future<void> _syncPhotoConflict(
    PhotoModel localPhoto,
    DocumentSnapshot cloudDoc,
  ) async {
    final cloudData = cloudDoc.data() as Map<String, dynamic>;
    final cloudPhoto = PhotoModel.fromJson(cloudData);

    if (localPhoto.updatedAt.isAfter(cloudPhoto.updatedAt)) {
      await _uploadPhotoMetadata(localPhoto);
    } else if (cloudPhoto.updatedAt.isAfter(localPhoto.updatedAt)) {
      final photosBox = Hive.box<PhotoModel>('photos');
      await photosBox.put(cloudPhoto.id, cloudPhoto);
    }
  }

  /// Add failed operation to sync queue
  void _addToSyncQueue(String collection, String? documentId) {
    _syncQueue.add({
      'collection': collection,
      'documentId': documentId,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _pendingSyncCount = _syncQueue.length;
    notifyListeners();
  }

  /// Process sync queue (retry failed operations)
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty) {
      return;
    }

    debugPrint('ðŸ”„ Processing sync queue: ${_syncQueue.length} items');

    final itemsToRemove = <Map<String, dynamic>>[];

    for (final item in _syncQueue) {
      try {
        // Retry sync based on collection type
        switch (item['collection']) {
          case 'schedules':
            await _syncSchedules();
            break;
          case 'journals':
            await _syncJournals();
            break;
          case 'photos':
            await _syncPhotos();
            break;
        }
        // Success, mark for removal
        itemsToRemove.add(item);
      } catch (e) {
        debugPrint('âŒ Queue item failed: ${item['collection']}');
        // Keep in queue for next retry
      }
    }

    // Remove successful items
    itemsToRemove.forEach(_syncQueue.remove);

    _pendingSyncCount = _syncQueue.length;
  }

  /// Force sync now (manual trigger)
  Future<void> forceSyncNow() async {
    debugPrint('ðŸ”„ Force sync triggered');
    await syncAll();
  }

  /// Clear sync queue
  void clearSyncQueue() {
    _syncQueue.clear();
    _pendingSyncCount = 0;
    notifyListeners();
  }

  /// Delete schedule from remote (Firebase)
  Future<void> deleteScheduleRemote(String scheduleId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('schedules')
          .doc(scheduleId)
          .delete();
      debugPrint('✅ Schedule deleted from remote: $scheduleId');
    } catch (e) {
      debugPrint('❌ Failed to delete schedule from remote: $e');
      // Don't rethrow - deletion should succeed locally even if remote fails
    }
  }

  /// Delete journal from remote (Firebase)
  Future<void> deleteJournalRemote(String journalId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('journals')
          .doc(journalId)
          .delete();
      debugPrint('✅ Journal deleted from remote: $journalId');
    } catch (e) {
      debugPrint('❌ Failed to delete journal from remote: $e');
    }
  }

  /// Delete photo metadata from remote (Firebase)
  Future<void> deletePhotoRemote(String photoId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('photos')
          .doc(photoId)
          .delete();
      debugPrint('✅ Photo deleted from remote: $photoId');
    } catch (e) {
      debugPrint('❌ Failed to delete photo from remote: $e');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }
}