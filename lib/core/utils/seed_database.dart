import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

// Import models
import '../../data/models/category_model.dart';
import '../../data/models/journal_model.dart';
import '../../data/models/photo_model.dart';
import '../../data/models/schedule_model.dart';

// Import providers
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/category_provider.dart';
import '../../presentation/providers/journal_provider.dart';
import '../../presentation/providers/photo_provider.dart';
import '../../presentation/providers/schedule_provider.dart';

// Import seeder data
import 'data_seeder.dart';

/// Fungsi untuk seed semua data sekaligus
Future<void> seedAllData({String? userId}) async {
  if (kDebugMode) {
    debugPrint('🌱 Starting data seeding...');
  }
  
  // Update userId jika diperlukan
  if (userId != null) {
    // Buat copy dengan userId baru
    await seedCategories(userId: userId);
    await seedSchedules(userId: userId);
    await seedJournals(userId: userId);
    await seedPhotos(userId: userId);
  } else {
    // Gunakan default testUserId
    await seedCategories();
    await seedSchedules();
    await seedJournals();
    await seedPhotos();
  }
  
  if (kDebugMode) {
    DataSeeder.printSummary();
    debugPrint('✅ Data seeding completed!');
  }
}

/// Seed Categories ke Hive
Future<void> seedCategories({String? userId}) async {
  if (kDebugMode) {
    debugPrint('📁 Seeding categories...');
  }
  
  // Check apakah box sudah terbuka, jika belum buka dulu
  Box<CategoryModel> box;
  if (Hive.isBoxOpen('categories')) {
    box = Hive.box<CategoryModel>('categories');
  } else {
    box = await Hive.openBox<CategoryModel>('categories');
  }
  
  final categories = DataSeeder.seedCategories();
  
  for (final categoryData in categories) {
    // Update userId jika ada
    if (userId != null) {
      categoryData['userId'] = userId;
    }
    
    final category = CategoryModel.fromJson(categoryData);
    await box.put(category.id, category);
  }
  
  if (kDebugMode) {
    debugPrint('✓ ${categories.length} categories seeded');
  }
}

/// Seed Schedules ke Hive
Future<void> seedSchedules({String? userId}) async {
  if (kDebugMode) {
    debugPrint('📅 Seeding schedules...');
  }
  
  // Check apakah box sudah terbuka, jika belum buka dulu
  Box<ScheduleModel> box;
  if (Hive.isBoxOpen('schedules')) {
    box = Hive.box<ScheduleModel>('schedules');
  } else {
    box = await Hive.openBox<ScheduleModel>('schedules');
  }
  
  final schedules = DataSeeder.seedSchedules();
  
  for (final scheduleData in schedules) {
    // Update userId jika ada
    if (userId != null) {
      scheduleData['userId'] = userId;
    }
    
    final schedule = ScheduleModel.fromJson(scheduleData);
    await box.put(schedule.id, schedule);
  }
  
  if (kDebugMode) {
    debugPrint('✓ ${schedules.length} schedules seeded');
  }
}

/// Seed Journals ke Hive
Future<void> seedJournals({String? userId}) async {
  if (kDebugMode) {
    debugPrint('📖 Seeding journals...');
  }
  
  // Check apakah box sudah terbuka, jika belum buka dulu
  Box<JournalModel> box;
  if (Hive.isBoxOpen('journals')) {
    box = Hive.box<JournalModel>('journals');
  } else {
    box = await Hive.openBox<JournalModel>('journals');
  }
  
  final journals = DataSeeder.seedJournals();
  
  for (final journalData in journals) {
    // Update userId jika ada
    if (userId != null) {
      journalData['userId'] = userId;
    }
    
    // Convert ke JournalModel dulu, baru simpan
    final journalModel = JournalModel.fromJson(journalData);
    await box.put(journalModel.id, journalModel);
  }
  
  if (kDebugMode) {
    debugPrint('✓ ${journals.length} journals seeded');
  }
}

/// Seed Photos ke Hive
Future<void> seedPhotos({String? userId}) async {
  if (kDebugMode) {
    debugPrint('📷 Seeding photos...');
  }
  
  // Check apakah box sudah terbuka, jika belum buka dulu
  Box<PhotoModel> box;
  if (Hive.isBoxOpen('photos')) {
    box = Hive.box<PhotoModel>('photos');
  } else {
    box = await Hive.openBox<PhotoModel>('photos');
  }
  
  final photos = DataSeeder.seedPhotos();
  
  for (final photoData in photos) {
    // Update userId jika ada
    if (userId != null) {
      photoData['userId'] = userId;
    }
    
    // Convert ke PhotoModel dulu, baru simpan
    final photoModel = PhotoModel.fromJson(photoData);
    await box.put(photoModel.id, photoModel);
  }
  
  if (kDebugMode) {
    debugPrint('✓ ${photos.length} photos seeded');
  }
}

/// Clear semua data dari database (untuk reset)
Future<void> clearAllData() async {
  if (kDebugMode) {
    debugPrint('🗑️ Clearing all data...');
  }
  
  // Clear isi box tanpa delete box-nya
  // Ini lebih aman karena box masih bisa dipakai
  if (Hive.isBoxOpen('categories')) {
    await Hive.box<CategoryModel>('categories').clear();
  }
  
  if (Hive.isBoxOpen('schedules')) {
    await Hive.box<ScheduleModel>('schedules').clear();
  }
  
  if (Hive.isBoxOpen('journals')) {
    await Hive.box<JournalModel>('journals').clear();
  }
  
  if (Hive.isBoxOpen('photos')) {
    await Hive.box<PhotoModel>('photos').clear();
  }
  
  if (kDebugMode) {
    debugPrint('✅ All data cleared!');
  }
}

/// Widget tombol untuk seed data (bisa ditaruh di Settings)
class SeedDataButton extends StatelessWidget {
  const SeedDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.science, color: Colors.orange),
        title: const Text('Seed Test Data'),
        subtitle: const Text('Insert dummy data for testing'),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () async {
            // Tampilkan dialog konfirmasi
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Seed Test Data?'),
                content: const Text(
                  'This will insert dummy data into the database. '
                  'Are you sure?'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Seed Data'),
                  ),
                ],
              ),
            );
            
            if (confirmed == true && context.mounted) {
              // Tampilkan loading
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Get current user ID dari Provider
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final userId = authProvider.user?.uid;
                
                // Seed data
                await seedAllData(userId: userId);
                
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  
                  // Refresh providers dengan method yang benar
                  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                  final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
                  final journalProvider = Provider.of<JournalProvider>(context, listen: false);
                  final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
                  
                  // Force refresh data dengan userId
                  if (userId != null) {
                    await categoryProvider.loadCategories(userId);
                    await scheduleProvider.loadAllSchedules();
                    await journalProvider.loadAllJournals();
                    await photoProvider.loadPhotos();
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Test data seeded successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error seeding data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}

/// Widget tombol untuk clear data (bisa ditaruh di Settings)
class ClearDataButton extends StatelessWidget {
  const ClearDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text('Clear All Data'),
        subtitle: const Text('Delete all data from database'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: () async {
            // Tampilkan dialog konfirmasi
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear All Data?'),
                content: const Text(
                  'This will permanently delete all data from the database. '
                  'This action cannot be undone. Are you sure?'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete All'),
                  ),
                ],
              ),
            );
            
            if (confirmed == true && context.mounted) {
              // Tampilkan loading
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Clear data
                await clearAllData();
                
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  
                  // Refresh providers
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final userId = authProvider.user?.uid;
                  
                  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                  final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
                  final journalProvider = Provider.of<JournalProvider>(context, listen: false);
                  final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
                  
                  // Force refresh data (akan kosong)
                  if (userId != null) {
                    await categoryProvider.loadCategories(userId);
                    await scheduleProvider.loadAllSchedules();
                    await journalProvider.loadAllJournals();
                    await photoProvider.loadPhotos();
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ All data cleared successfully!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error clearing data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}