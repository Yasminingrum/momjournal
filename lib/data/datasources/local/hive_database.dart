import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../models/user_model.dart';
import '../../models/schedule_model.dart';
import '../../models/journal_model.dart';
import '../../models/photo_model.dart';
import '../../models/child_profile_model.dart';

/// Service untuk inisialisasi dan manajemen Hive database
/// 
/// Mengatur setup boxes, registrasi adapters, dan lifecycle management
class HiveDatabase {
  // Box names
  static const String userBoxName = 'users';
  static const String scheduleBoxName = 'schedules';
  static const String journalBoxName = 'journals';
  static const String photoBoxName = 'photos';
  static const String childProfileBoxName = 'child_profiles';
  static const String settingsBoxName = 'settings';

  // Singleton pattern
  static final HiveDatabase _instance = HiveDatabase._internal();
  factory HiveDatabase() => _instance;
  HiveDatabase._internal();

  bool _isInitialized = false;

  /// Initialize Hive dan register semua adapters
  /// 
  /// Harus dipanggil sebelum menggunakan Hive boxes
  /// Biasanya dipanggil di main() sebelum runApp()
  Future<void> init() async {
    if (_isInitialized) {
      print('Hive already initialized');
      return;
    }

    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();

      // Get application documents directory untuk custom path (optional)
      // Ini berguna untuk testing atau custom storage location
      final appDocDir = await getApplicationDocumentsDirectory();
      print('Hive storage path: ${appDocDir.path}');

      // Register all type adapters
      _registerAdapters();

      print('✓ Hive database initialized successfully');
      _isInitialized = true;
    } catch (e) {
      print('✗ Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Register semua Hive type adapters
  void _registerAdapters() {
    // Register model adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScheduleModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(JournalModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PhotoModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ChildProfileModelAdapter());
    }

    // Register enum adapters
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ScheduleCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(MoodAdapter());
    }

    print('✓ All Hive adapters registered');
  }

  /// Open all required boxes
  /// 
  /// Membuka semua boxes yang dibutuhkan aplikasi
  /// Dipanggil setelah init() dan sebelum menggunakan data
  Future<void> openBoxes() async {
    if (!_isInitialized) {
      throw Exception('Hive not initialized. Call init() first.');
    }

    try {
      // Open all boxes in parallel untuk performa lebih baik
      await Future.wait([
        _openBox<UserModel>(userBoxName),
        _openBox<ScheduleModel>(scheduleBoxName),
        _openBox<JournalModel>(journalBoxName),
        _openBox<PhotoModel>(photoBoxName),
        _openBox<ChildProfileModel>(childProfileBoxName),
        _openBox<dynamic>(settingsBoxName), // Settings bisa mixed types
      ]);

      print('✓ All Hive boxes opened successfully');
    } catch (e) {
      print('✗ Error opening Hive boxes: $e');
      rethrow;
    }
  }

  /// Helper method untuk membuka box dengan error handling
  Future<Box<T>> _openBox<T>(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        return await Hive.openBox<T>(boxName);
      }
      return Hive.box<T>(boxName);
    } catch (e) {
      print('✗ Error opening box $boxName: $e');
      rethrow;
    }
  }

  /// Get specific box by name
  /// 
  /// Throws error jika box belum dibuka
  Box<T> getBox<T>(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not open. Call openBoxes() first.');
    }
    return Hive.box<T>(boxName);
  }

  /// Get user box
  Box<UserModel> get userBox => getBox<UserModel>(userBoxName);

  /// Get schedule box
  Box<ScheduleModel> get scheduleBox => getBox<ScheduleModel>(scheduleBoxName);

  /// Get journal box
  Box<JournalModel> get journalBox => getBox<JournalModel>(journalBoxName);

  /// Get photo box
  Box<PhotoModel> get photoBox => getBox<PhotoModel>(photoBoxName);

  /// Get child profile box
  Box<ChildProfileModel> get childProfileBox =>
      getBox<ChildProfileModel>(childProfileBoxName);

  /// Get settings box
  Box<dynamic> get settingsBox => getBox<dynamic>(settingsBoxName);

  /// Close all boxes
  /// 
  /// Menutup semua boxes untuk cleanup
  /// Dipanggil saat aplikasi di-dispose atau restart
  Future<void> closeBoxes() async {
    try {
      await Hive.close();
      _isInitialized = false;
      print('✓ All Hive boxes closed');
    } catch (e) {
      print('✗ Error closing Hive boxes: $e');
      rethrow;
    }
  }

  /// Delete specific box
  /// 
  /// HATI-HATI: Ini akan menghapus semua data di box
  Future<void> deleteBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      print('✓ Box $boxName deleted');
    } catch (e) {
      print('✗ Error deleting box $boxName: $e');
      rethrow;
    }
  }

  /// Clear all data from all boxes
  /// 
  /// HATI-HATI: Ini akan menghapus SEMUA data aplikasi
  /// Berguna untuk logout atau reset aplikasi
  Future<void> clearAllData() async {
    try {
      await Future.wait([
        userBox.clear(),
        scheduleBox.clear(),
        journalBox.clear(),
        photoBox.clear(),
        childProfileBox.clear(),
        settingsBox.clear(),
      ]);
      print('✓ All data cleared from Hive');
    } catch (e) {
      print('✗ Error clearing data: $e');
      rethrow;
    }
  }

  /// Get total size of all boxes (untuk debugging)
  Future<int> getTotalBoxSize() async {
    try {
      int totalSize = 0;
      final appDocDir = await getApplicationDocumentsDirectory();
      final hiveDir = Directory(appDocDir.path);

      if (await hiveDir.exists()) {
        await for (final entity in hiveDir.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.hive')) {
            final stat = await entity.stat();
            totalSize += stat.size;
          }
        }
      }

      return totalSize;
    } catch (e) {
      print('✗ Error calculating box size: $e');
      return 0;
    }
  }

  /// Get readable size string (KB, MB, GB)
  Future<String> getReadableTotalSize() async {
    final bytes = await getTotalBoxSize();

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Compact all boxes untuk optimize storage
  /// 
  /// Mengurangi ukuran file dengan menghapus space yang tidak terpakai
  Future<void> compactAllBoxes() async {
    try {
      await Future.wait([
        userBox.compact(),
        scheduleBox.compact(),
        journalBox.compact(),
        photoBox.compact(),
        childProfileBox.compact(),
        settingsBox.compact(),
      ]);
      print('✓ All boxes compacted');
    } catch (e) {
      print('✗ Error compacting boxes: $e');
      rethrow;
    }
  }

  /// Check if Hive is initialized
  bool get isInitialized => _isInitialized;

  /// Debug info: Print semua box statistics
  Future<void> printBoxStats() async {
    print('\n=== Hive Box Statistics ===');
    print('User box: ${userBox.length} entries');
    print('Schedule box: ${scheduleBox.length} entries');
    print('Journal box: ${journalBox.length} entries');
    print('Photo box: ${photoBox.length} entries');
    print('Child Profile box: ${childProfileBox.length} entries');
    print('Settings box: ${settingsBox.length} entries');
    print('Total size: ${await getReadableTotalSize()}');
    print('==========================\n');
  }
}