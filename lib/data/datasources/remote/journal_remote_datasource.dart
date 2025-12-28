import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/journal_entity.dart';
import 'firebase_service.dart';

/// Interface untuk Journal Remote Datasource (UPDATED with soft delete support)
abstract class JournalRemoteDatasource {
  Future<void> createJournal(JournalEntity journal);
  Future<List<JournalEntity>> getAllJournals();
  Future<List<JournalEntity>> getAllJournalsIncludingDeleted(); // 🆕 ADDED
  Future<List<JournalEntity>> getJournalsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> updateJournal(JournalEntity journal);
  Future<void> deleteJournal(String journalId);
  Stream<List<JournalEntity>> watchJournals();
}

class JournalRemoteDatasourceImpl implements JournalRemoteDatasource {

  JournalRemoteDatasourceImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService();
  final FirebaseService _firebaseService;

  CollectionReference? get _journalsCollection =>
      _firebaseService.journalsCollection;

  @override
  Future<void> createJournal(JournalEntity journal) async {
    try {
      if (_journalsCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      await _journalsCollection!
          .doc(journal.id)
          .set(_journalToFirestore(journal));
      
      debugPrint('✅ Journal created in Firestore: ${journal.id}');
    } catch (e) {
      debugPrint('❌ Error creating journal: $e');
      throw DatabaseException('Gagal membuat jurnal: $e');
    }
  }

  @override
  Future<List<JournalEntity>> getAllJournals() async {
    try {
      if (_journalsCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final snapshot = await _journalsCollection!
          .where('isDeleted', isEqualTo: false)  // 🆕 Filter deleted
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map(_journalFromFirestore).toList();
    } catch (e) {
      debugPrint('❌ Error getting journals: $e');
      throw DatabaseException('Gagal mengambil jurnal: $e');
    }
  }

  /// 🆕 Get ALL journals including deleted ones (for sync)
  @override
  Future<List<JournalEntity>> getAllJournalsIncludingDeleted() async {
    try {
      if (_journalsCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final snapshot = await _journalsCollection!
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map(_journalFromFirestore).toList();
    } catch (e) {
      debugPrint('❌ Error getting all journals including deleted: $e');
      throw DatabaseException('Gagal mengambil semua jurnal: $e');
    }
  }

  @override
  Future<List<JournalEntity>> getJournalsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (_journalsCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final snapshot = await _journalsCollection!
          .where('isDeleted', isEqualTo: false)  // 🆕 Filter deleted
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map(_journalFromFirestore).toList();
    } catch (e) {
      debugPrint('❌ Error getting journals by date range: $e');
      throw DatabaseException('Gagal mengambil jurnal: $e');
    }
  }

  @override
  Future<void> updateJournal(JournalEntity journal) async {
    try {
      if (_journalsCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      final data = _journalToFirestore(journal);
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _journalsCollection!.doc(journal.id).update(data);
      
      debugPrint('✅ Journal updated in Firestore: ${journal.id}');
    } catch (e) {
      debugPrint('❌ Error updating journal: $e');
      throw DatabaseException('Gagal memperbarui jurnal: $e');
    }
  }

  @override
  Future<void> deleteJournal(String journalId) async {
    try {
      if (_journalsCollection == null) {
        throw const AuthorizationException('User tidak login');
      }

      // 🆕 Soft delete - update instead of delete
      await _journalsCollection!.doc(journalId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Journal soft deleted in Firestore: $journalId');
    } catch (e) {
      debugPrint('❌ Error deleting journal: $e');
      throw DatabaseException('Gagal menghapus jurnal: $e');
    }
  }

  @override
  Stream<List<JournalEntity>> watchJournals() {
    if (_journalsCollection == null) {
      return Stream.error(const AuthorizationException('User tidak login'));
    }

    return _journalsCollection!
        .where('isDeleted', isEqualTo: false)  // 🆕 Filter deleted
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_journalFromFirestore).toList());
  }

  /// Convert JournalEntity to Firestore map (UPDATED with soft delete)
  Map<String, dynamic> _journalToFirestore(JournalEntity journal) => {
      'id': journal.id,
      'userId': journal.userId,
      'content': journal.content,
      'mood': journal.mood.name,
      'date': Timestamp.fromDate(journal.date),
      'createdAt': Timestamp.fromDate(journal.createdAt),
      'updatedAt': Timestamp.fromDate(journal.updatedAt),
      'isDeleted': journal.isDeleted,  // 🆕 ADDED
      'deletedAt': journal.deletedAt != null 
          ? Timestamp.fromDate(journal.deletedAt!) 
          : null,  // 🆕 ADDED
    };

  /// Convert Firestore document to JournalEntity (UPDATED with soft delete)
  JournalEntity _journalFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntity(
      id: data['id'] as String,
      userId: data['userId'] as String? ?? '',
      content: data['content'] as String,
      mood: MoodType.values.firstWhere(
        (e) => e.name == data['mood'],
        orElse: () => MoodType.neutral,
      ),
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,  // 🆕 ADDED with safe default
      deletedAt: data['deletedAt'] != null 
          ? (data['deletedAt'] as Timestamp).toDate() 
          : null,  // 🆕 ADDED
    );
  }
}