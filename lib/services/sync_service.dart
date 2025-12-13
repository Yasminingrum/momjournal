import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      debugPrint('📡 Connectivity restored: $result');
      // Connection available, trigger sync
      syncAll();
    } else {
      debugPrint('📡 Connection lost');
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
      debugPrint('⚠️ Sync already in progress');
      return;
    }

    try {
      _isSyncing = true;
      _syncError = null;
      notifyListeners();

      debugPrint('🔄 Starting full sync...');

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

      debugPrint('✅ Sync completed successfully');
    } catch (e) {
      _syncError = e.toString();
      debugPrint('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync schedules
  Future<void> _syncSchedules() async {
    try {
      final schedulesBox = await Hive.openBox<Map<dynamic, dynamic>>('schedules');
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
        final localScheduleRaw = schedulesBox.get(key);
        if (localScheduleRaw == null) {
          continue;
        }
        
        // Convert to Map<String, dynamic>
        final localSchedule = Map<String, dynamic>.from(localScheduleRaw);
        final scheduleId = localSchedule['id'] as String;
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
          await schedulesBox.put(doc.id, doc.data());
        }
      }

      debugPrint('✅ Schedules synced');
    } catch (e) {
      debugPrint('❌ Schedule sync failed: $e');
      _addToSyncQueue('schedules', null);
      rethrow;
    }
  }

  /// Upload schedule to cloud
  Future<void> _uploadSchedule(Map<String, dynamic> schedule) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('schedules')
        .doc(schedule['id'] as String)
        .set(schedule);
  }

  /// Resolve schedule sync conflict (last-write-wins)
  Future<void> _syncScheduleConflict(
    Map<String, dynamic> localSchedule,
    DocumentSnapshot cloudDoc,
  ) async {
    final cloudSchedule = cloudDoc.data() as Map<String, dynamic>;

    final localUpdated = DateTime.parse(localSchedule['updatedAt'] as String);
    final cloudUpdated = DateTime.parse(cloudSchedule['updatedAt'] as String);

    if (localUpdated.isAfter(cloudUpdated)) {
      // Local is newer, upload
      await _uploadSchedule(localSchedule);
    } else if (cloudUpdated.isAfter(localUpdated)) {
      // Cloud is newer, download
      final schedulesBox = 
          await Hive.openBox<Map<dynamic, dynamic>>('schedules');
      await schedulesBox.put(cloudSchedule['id'], cloudSchedule);
    }
    // If equal, no sync needed
  }

  /// Sync journals
  Future<void> _syncJournals() async {
    try {
      final journalsBox = await Hive.openBox<Map<dynamic, dynamic>>('journals');
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
        final localJournalRaw = journalsBox.get(key);
        if (localJournalRaw == null) {
          continue;
        }
        
        // Convert to Map<String, dynamic>
        final localJournal = Map<String, dynamic>.from(localJournalRaw);
        final journalId = localJournal['id'] as String;
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
          await journalsBox.put(doc.id, doc.data());
        }
      }

      debugPrint('✅ Journals synced');
    } catch (e) {
      debugPrint('❌ Journal sync failed: $e');
      _addToSyncQueue('journals', null);
      rethrow;
    }
  }

  /// Upload journal to cloud
  Future<void> _uploadJournal(Map<String, dynamic> journal) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journal['id'] as String)
        .set(journal);
  }

  /// Resolve journal sync conflict
  Future<void> _syncJournalConflict(
    Map<String, dynamic> localJournal,
    DocumentSnapshot cloudDoc,
  ) async {
    final cloudJournal = cloudDoc.data() as Map<String, dynamic>;

    final localUpdated = DateTime.parse(localJournal['updatedAt'] as String);
    final cloudUpdated = DateTime.parse(cloudJournal['updatedAt'] as String);

    if (localUpdated.isAfter(cloudUpdated)) {
      await _uploadJournal(localJournal);
    } else if (cloudUpdated.isAfter(localUpdated)) {
      final journalsBox = await Hive.openBox<Map<dynamic, dynamic>>('journals');
      await journalsBox.put(cloudJournal['id'], cloudJournal);
    }
  }

  /// Sync photos metadata
  Future<void> _syncPhotos() async {
    try {
      final photosBox = await Hive.openBox<Map<dynamic, dynamic>>('photos');
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
        final localPhotoRaw = photosBox.get(key);
        if (localPhotoRaw == null) {
          continue;
        }
        
        // Convert to Map<String, dynamic>
        final localPhoto = Map<String, dynamic>.from(localPhotoRaw);
        final photoId = localPhoto['id'] as String;
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
          await photosBox.put(doc.id, doc.data());
        }
      }

      debugPrint('✅ Photos synced');
    } catch (e) {
      debugPrint('❌ Photo sync failed: $e');
      _addToSyncQueue('photos', null);
      rethrow;
    }
  }

  /// Upload photo metadata to cloud
  Future<void> _uploadPhotoMetadata(Map<String, dynamic> photo) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('photos')
        .doc(photo['id'] as String)
        .set(photo);
  }

  /// Resolve photo sync conflict
  Future<void> _syncPhotoConflict(
    Map<String, dynamic> localPhoto,
    DocumentSnapshot cloudDoc,
  ) async {
    final cloudPhoto = cloudDoc.data() as Map<String, dynamic>;

    final localUpdated = DateTime.parse(localPhoto['updatedAt'] as String);
    final cloudUpdated = DateTime.parse(cloudPhoto['updatedAt'] as String);

    if (localUpdated.isAfter(cloudUpdated)) {
      await _uploadPhotoMetadata(localPhoto);
    } else if (cloudUpdated.isAfter(localUpdated)) {
      final photosBox = await Hive.openBox<Map<dynamic, dynamic>>('photos');
      await photosBox.put(cloudPhoto['id'], cloudPhoto);
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

    debugPrint('🔄 Processing sync queue: ${_syncQueue.length} items');

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
        debugPrint('❌ Queue item failed: ${item['collection']}');
        // Keep in queue for next retry
      }
    }

    // Remove successful items
    itemsToRemove.forEach(_syncQueue.remove);

    _pendingSyncCount = _syncQueue.length;
  }

  /// Force sync now (manual trigger)
  Future<void> forceSyncNow() async {
    debugPrint('🔄 Force sync triggered');
    await syncAll();
  }

  /// Clear sync queue
  void clearSyncQueue() {
    _syncQueue.clear();
    _pendingSyncCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }
}