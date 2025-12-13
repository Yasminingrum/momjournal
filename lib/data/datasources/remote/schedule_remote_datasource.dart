import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseService _firebaseService;

  ScheduleRemoteDatasourceImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService();

  CollectionReference? get _schedulesCollection =>
      _firebaseService.schedulesCollection;

  @override
  Future<void> createSchedule(ScheduleEntity schedule) async {
    try {
      if (_schedulesCollection == null) {
        throw AuthorizationException('User tidak login');
      }

      final scheduleData = _scheduleToFirestore(schedule);
      
      await _schedulesCollection!
          .doc(schedule.id)
          .set(scheduleData);

      print('✅ Schedule created in Firestore: ${schedule.id}');
    } on FirebaseException catch (e) {
      print('❌ Firebase error creating schedule: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      print('❌ Error creating schedule: $e');
      if (e is AuthorizationException) rethrow;
      throw DatabaseException('Gagal membuat jadwal: $e');
    }
  }

  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    try {
      if (_schedulesCollection == null) {
        throw AuthorizationException('User tidak login');
      }

      final QuerySnapshot snapshot = await _schedulesCollection!
          .orderBy('dateTime', descending: true)
          .get();

      final schedules = snapshot.docs
          .map((doc) => _scheduleFromFirestore(doc))
          .toList();

      print('✅ Fetched ${schedules.length} schedules from Firestore');
      return schedules;
    } on FirebaseException catch (e) {
      print('❌ Firebase error getting schedules: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      print('❌ Error getting schedules: $e');
      if (e is AuthorizationException) rethrow;
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
        throw AuthorizationException('User tidak login');
      }

      final QuerySnapshot snapshot = await _schedulesCollection!
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('dateTime')
          .get();

      final schedules = snapshot.docs
          .map((doc) => _scheduleFromFirestore(doc))
          .toList();

      print('✅ Fetched ${schedules.length} schedules for date range');
      return schedules;
    } on FirebaseException catch (e) {
      print('❌ Firebase error getting schedules by date: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      print('❌ Error getting schedules by date: $e');
      if (e is AuthorizationException) rethrow;
      throw DatabaseException('Gagal mengambil jadwal: $e');
    }
  }

  @override
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    try {
      if (_schedulesCollection == null) {
        throw AuthorizationException('User tidak login');
      }

      final scheduleData = _scheduleToFirestore(schedule);
      scheduleData['updatedAt'] = FieldValue.serverTimestamp();

      await _schedulesCollection!
          .doc(schedule.id)
          .update(scheduleData);

      print('✅ Schedule updated in Firestore: ${schedule.id}');
    } on FirebaseException catch (e) {
      print('❌ Firebase error updating schedule: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      print('❌ Error updating schedule: $e');
      if (e is AuthorizationException) rethrow;
      throw DatabaseException('Gagal memperbarui jadwal: $e');
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      if (_schedulesCollection == null) {
        throw AuthorizationException('User tidak login');
      }

      await _schedulesCollection!.doc(scheduleId).delete();

      print('✅ Schedule deleted from Firestore: $scheduleId');
    } on FirebaseException catch (e) {
      print('❌ Firebase error deleting schedule: ${e.code}');
      throw DatabaseException(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      if (e is AuthorizationException) rethrow;
      throw DatabaseException('Gagal menghapus jadwal: $e');
    }
  }

  @override
  Stream<List<ScheduleEntity>> watchSchedules() {
    if (_schedulesCollection == null) {
      return Stream.error(AuthorizationException ('User tidak login'));
    }

    return _schedulesCollection!
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => _scheduleFromFirestore(doc))
          .toList();
    }).handleError((error) {
      print('❌ Error in schedules stream: $error');
      if (error is FirebaseException) {
        throw DatabaseException(FirebaseErrorHandler.getErrorMessage(error));
      }
      throw DatabaseException('Gagal memantau jadwal: $error');
    });
  }

  /// Convert ScheduleEntity to Firestore map
  Map<String, dynamic> _scheduleToFirestore(ScheduleEntity schedule) {
    return {
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
  }

  /// Convert Firestore document to ScheduleEntity
  ScheduleEntity _scheduleFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ScheduleEntity(
      id: data['id'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      notes: data['notes'] as String?,
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      category: ScheduleCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => ScheduleCategory.other,
      ),
      hasReminder: data['hasReminder'] as bool? ?? false,
      reminderMinutes: data['reminderMinutes'] as int? ?? 15,
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}