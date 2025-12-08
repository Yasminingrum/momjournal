/// Sync Repository
/// 
/// Repository untuk sync data antara local dan remote
/// Location: lib/data/repositories/sync_repository.dart

import '../datasources/local/schedule_local_datasource.dart';
import '../datasources/local/journal_local_datasource.dart';
import '../datasources/local/photo_local_datasource.dart';
import '../datasources/remote/schedule_remote_datasource.dart';
import '../datasources/remote/journal_remote_datasource.dart';
import '../datasources/remote/photo_remote_datasource.dart';
import '../../core/errors/exceptions.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncResult {
  final int schedulessynced;
  final int journalsSynced;
  final int photosSynced;
  final List<String> errors;

  SyncResult({
    required this.schedulessynced,
    required this.journalsSynced,
    required this.photosSynced,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  int get totalSynced => schedulessynced + journalsSynced + photosSynced;
}

abstract class SyncRepository {
  Future<SyncResult> syncAll();
  Future<void> syncSchedules();
  Future<void> syncJournals();
  Future<void> syncPhotos();
}

class SyncRepositoryImpl implements SyncRepository {
  final ScheduleLocalDatasource scheduleLocal;
  final ScheduleRemoteDatasource scheduleRemote;
  final JournalLocalDatasource journalLocal;
  final JournalRemoteDatasource journalRemote;
  final PhotoLocalDatasource photoLocal;
  final PhotoRemoteDatasource photoRemote;

  SyncRepositoryImpl({
    required this.scheduleLocal,
    required this.scheduleRemote,
    required this.journalLocal,
    required this.journalRemote,
    required this.photoLocal,
    required this.photoRemote,
  });

  @override
  Future<SyncResult> syncAll() async {
    print('🔄 Starting full sync...');
    
    int schedulesCount = 0;
    int journalsCount = 0;
    int photosCount = 0;
    final List<String> errors = [];

    // Sync schedules
    try {
      await syncSchedules();
      final schedules = await scheduleLocal.getAllSchedules();
      schedulesCount = schedules.length;
    } catch (e) {
      errors.add('Schedules: $e');
      print('❌ Schedule sync failed: $e');
    }

    // Sync journals
    try {
      await syncJournals();
      final journals = await journalLocal.getAllJournals();
      journalsCount = journals.length;
    } catch (e) {
      errors.add('Journals: $e');
      print('❌ Journal sync failed: $e');
    }

    // Sync photos
    try {
      await syncPhotos();
      final photos = await photoLocal.getAllPhotos();
      photosCount = photos.length;
    } catch (e) {
      errors.add('Photos: $e');
      print('❌ Photo sync failed: $e');
    }

    final result = SyncResult(
      schedulessynced: schedulesCount,
      journalsSynced: journalsCount,
      photosSynced: photosCount,
      errors: errors,
    );

    if (errors.isEmpty) {
      print('✅ Full sync completed: ${result.totalSynced} items');
    } else {
      print('⚠️ Sync completed with errors: ${errors.length} errors');
    }

    return result;
  }

  @override
  Future<void> syncSchedules() async {
    try {
      print('🔄 Syncing schedules...');
      
      // Get remote schedules
      final remoteSchedules = await scheduleRemote.getAllSchedules();
      
      // Get local schedules
      final localSchedules = await scheduleLocal.getAllSchedules();
      
      // Create maps for easier lookup
      final remoteMap = {for (var s in remoteSchedules) s.id: s};
      final localMap = {for (var s in localSchedules) s.id: s};
      
      // Sync remote -> local (download)
      for (var remote in remoteSchedules) {
        final local = localMap[remote.id];
        
        if (local == null) {
          // New from remote, add to local
          await scheduleLocal.createSchedule(remote);
        } else if (remote.updatedAt.isAfter(local.updatedAt)) {
          // Remote is newer, update local
          await scheduleLocal.updateSchedule(remote);
        }
      }
      
      // Sync local -> remote (upload)
      for (var local in localSchedules) {
        final remote = remoteMap[local.id];
        
        if (remote == null) {
          // New from local, add to remote
          await scheduleRemote.createSchedule(local);
        } else if (local.updatedAt.isAfter(remote.updatedAt)) {
          // Local is newer, update remote
          await scheduleRemote.updateSchedule(local);
        }
      }
      
      print('✅ Schedules synced successfully');
    } catch (e) {
      print('❌ Schedule sync failed: $e');
      throw SyncException('Gagal sync schedules: $e');
    }
  }

  @override
  Future<void> syncJournals() async {
    try {
      print('🔄 Syncing journals...');
      
      final remoteJournals = await journalRemote.getAllJournals();
      final localJournals = await journalLocal.getAllJournals();
      
      final remoteMap = {for (var j in remoteJournals) j.id: j};
      final localMap = {for (var j in localJournals) j.id: j};
      
      // Sync remote -> local
      for (var remote in remoteJournals) {
        final local = localMap[remote.id];
        
        if (local == null) {
          await journalLocal.createJournal(remote);
        } else if (remote.updatedAt.isAfter(local.updatedAt)) {
          await journalLocal.updateJournal(remote);
        }
      }
      
      // Sync local -> remote
      for (var local in localJournals) {
        final remote = remoteMap[local.id];
        
        if (remote == null) {
          await journalRemote.createJournal(local);
        } else if (local.updatedAt.isAfter(remote.updatedAt)) {
          await journalRemote.updateJournal(local);
        }
      }
      
      print('✅ Journals synced successfully');
    } catch (e) {
      print('❌ Journal sync failed: $e');
      throw SyncException('Gagal sync journals: $e');
    }
  }

  @override
  Future<void> syncPhotos() async {
    try {
      print('🔄 Syncing photos...');
      
      final remotePhotos = await photoRemote.getAllPhotos();
      final localPhotos = await photoLocal.getAllPhotos();
      
      final remoteMap = {for (var p in remotePhotos) p.id: p};
      final localMap = {for (var p in localPhotos) p.id: p};
      
      // Sync remote -> local (metadata only)
      for (var remote in remotePhotos) {
        final local = localMap[remote.id];
        
        if (local == null) {
          await photoLocal.createPhoto(remote);
        } else if (remote.updatedAt.isAfter(local.updatedAt)) {
          await photoLocal.updatePhoto(remote);
        }
      }
      
      // Sync local -> remote (metadata only, actual upload happens separately)
      for (var local in localPhotos) {
        final remote = remoteMap[local.id];
        
        if (remote == null && local.downloadUrl.isNotEmpty) {
          await photoRemote.createPhotoMetadata(local);
        } else if (remote != null && local.updatedAt.isAfter(remote.updatedAt)) {
          await photoRemote.updatePhoto(local);
        }
      }
      
      print('✅ Photos synced successfully');
    } catch (e) {
      print('❌ Photo sync failed: $e');
      throw SyncException('Gagal sync photos: $e');
    }
  }
}