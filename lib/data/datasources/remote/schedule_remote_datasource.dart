// ignore_for_file: lines_longer_than_80_chars

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/schedule_entity.dart';
import 'firebase_service.dart';

/// Interface untuk Schedule Remote Datasource
abstract class ScheduleRemoteDatasource {
  /// Create schedule di Firestore
  Future<void> createSchedule(ScheduleEntity schedule);
  
  /// Get all schedules untuk user
  Future<List<ScheduleEntity>> getAllSchedules();
  
  /// Get schedules by date range
  Future<List<ScheduleEntity>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Update schedule
  Future<void> updateSchedule(ScheduleEntity schedule);
  
  /// Delete schedule
  Future<void> deleteSchedule(String scheduleId);
  
  /// Stream schedules (real-time updates)
  Stream<List<ScheduleEntity>> watchSchedules();
}

/// Implementation dari Schedule Remote Datasource
class ScheduleRemoteDatasourceImpl implements ScheduleRemoteDatasource {

  ScheduleRemoteDatasourceImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService();
  final FirebaseService _firebaseService;

  CollectionReference? get _schedulesCollection =>
      _firebaseService.schedulesCollection;

  @override
  Future<void> createSchedule(ScheduleEntity schedule) async {
    try {
      if (_schedulesCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final scheduleData = _scheduleToFirestore(schedule);
      
      await _schedulesCollection!
          .doc(schedule.id)
          .set(scheduleData);

      debugPrint('✅ Schedule created in Firestore: ${schedule.id}');
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error creating schedule: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error creating schedule: $e');
      if (e is AuthorizationException) {
        rethrow;
      }
      throw DatabaseException('Gagal membuat jadwal: $e');
    }
  }

  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    try {
      if (_schedulesCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final QuerySnapshot snapshot = await _schedulesCollection!
          .orderBy('dateTime', descending: true)
          .get();

      final schedules = snapshot.docs
          .map(_scheduleFromFirestore)
          .where((schedule) => schedule != null)  // Filter out nulls
          .cast<ScheduleEntity>()
          .toList();

      debugPrint('✅ Fetched ${schedules.length} schedules from Firestore');
      return schedules;
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error getting schedules: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error getting schedules: $e');
      if (e is AuthorizationException) {
        rethrow;
      }
      throw DatabaseException('Gagal mengambil jadwal: $e');
    }
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (_schedulesCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final QuerySnapshot snapshot = await _schedulesCollection!
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('dateTime')
          .get();

      final schedules = snapshot.docs
          .map(_scheduleFromFirestore)
          .where((schedule) => schedule != null)
          .cast<ScheduleEntity>()
          .toList();

      debugPrint('✅ Fetched ${schedules.length} schedules for date range');
      return schedules;
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error getting schedules by date: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error getting schedules by date: $e');
      if (e is AuthorizationException) {
        rethrow;
      }
      throw DatabaseException('Gagal mengambil jadwal: $e');
    }
  }

  @override
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    try {
      if (_schedulesCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final scheduleData = _scheduleToFirestore(schedule);
      scheduleData['updatedAt'] = FieldValue.serverTimestamp();

      await _schedulesCollection!
          .doc(schedule.id)
          .update(scheduleData);

      debugPrint('✅ Schedule updated in Firestore: ${schedule.id}');
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error updating schedule: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error updating schedule: $e');
      if (e is AuthorizationException) {
        rethrow;
      }
      throw DatabaseException('Gagal memperbarui jadwal: $e');
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      if (_schedulesCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      await _schedulesCollection!.doc(scheduleId).delete();

      debugPrint('✅ Schedule deleted from Firestore: $scheduleId');
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error deleting schedule: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error deleting schedule: $e');
      if (e is AuthorizationException) {
        rethrow;
      }
      throw DatabaseException('Gagal menghapus jadwal: $e');
    }
  }

  @override
  Stream<List<ScheduleEntity>> watchSchedules() {
    if (_schedulesCollection == null) {
      return Stream.error(const AuthorizationException ('User tidak login'));
    }

    return _schedulesCollection!
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
          .map(_scheduleFromFirestore)
          .where((schedule) => schedule != null)
          .cast<ScheduleEntity>()
          .toList(),).handleError((Object error) {
      debugPrint('❌ Error in schedules stream: $error');
      if (error is FirebaseException) {
        throw DatabaseException(FirebaseErrorHandler.getErrorMessage(error));
      }
      throw DatabaseException('Gagal memantau jadwal: $error');
    });
  }

  /// Convert ScheduleEntity to Firestore map
  Map<String, dynamic> _scheduleToFirestore(ScheduleEntity schedule) => {
      'id': schedule.id,
      'title': schedule.title,
      'notes': schedule.notes,
      'dateTime': Timestamp.fromDate(schedule.dateTime),
      'category': schedule.category.name,
      'hasReminder': schedule.hasReminder,
      'reminderMinutes': schedule.reminderMinutes,
      'isCompleted': schedule.isCompleted,
      'createdAt': Timestamp.fromDate(schedule.createdAt),
      'updatedAt': Timestamp.fromDate(schedule.updatedAt),
    };

  /// Convert Firestore document to ScheduleEntity
  /// 
  /// Returns null if document is invalid/corrupt to prevent crashes
  ScheduleEntity? _scheduleFromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      
      // Return null if no data
      if (data == null) {
        debugPrint('⚠️ Skipping document ${doc.id}: no data');
        return null;
      }
      
      // Helper to safely get Timestamp and convert to DateTime
      DateTime? parseTimestamp(dynamic value) {
        if (value == null) {
          return null;
        }
        if (value is Timestamp) {
          return value.toDate();
        }
        if (value is DateTime) {
          return value;
        }
        return null;
      }
      
      // Validate required fields
      final id = data['id'] as String?;
      final title = data['title'] as String?;
      final dateTime = parseTimestamp(data['dateTime']);
      
      if (id == null || id.isEmpty) {
        debugPrint('⚠️ Skipping document ${doc.id}: missing id');
        return null;
      }
      
      if (title == null || title.isEmpty) {
        debugPrint('⚠️ Skipping document ${doc.id}: missing title');
        return null;
      }
      
      if (dateTime == null) {
        debugPrint('⚠️ Skipping document ${doc.id}: missing dateTime');
        return null;
      }
      
      return ScheduleEntity(
        id: id,
        userId: data['userId'] as String? ?? '',
        title: title,
        notes: data['notes'] as String?,
        dateTime: dateTime,
        category: ScheduleCategory.values.firstWhere(
          (e) => e.name == data['category'],
          orElse: () => ScheduleCategory.other,
        ),
        hasReminder: data['hasReminder'] as bool? ?? false,
        reminderMinutes: data['reminderMinutes'] as int? ?? 15,
        isCompleted: data['isCompleted'] as bool? ?? false,
        createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
        updatedAt: parseTimestamp(data['updatedAt']) ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('⚠️ Error parsing document ${doc.id}: $e');
      return null;  // Return null instead of crashing
    }
  }
}