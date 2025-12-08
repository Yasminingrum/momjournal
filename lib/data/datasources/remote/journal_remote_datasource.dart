/// Journal Remote Datasource
/// 
/// Handles journal operations with Firestore
/// Location: lib/data/datasources/remote/journal_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/journal_entity.dart';
import '../../../core/errors/exceptions.dart';
import 'firebase_service.dart';

/// Interface untuk Journal Remote Datasource
abstract class JournalRemoteDatasource {
  Future<void> createJournal(JournalEntity journal);
  Future<List<JournalEntity>> getAllJournals();
  Future<List<JournalEntity>> getJournalsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> updateJournal(JournalEntity journal);
  Future<void> deleteJournal(String journalId);
  Stream<List<JournalEntity>> watchJournals();
}

class JournalRemoteDatasourceImpl implements JournalRemoteDatasource {
  final FirebaseService _firebaseService;

  JournalRemoteDatasourceImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService();

  CollectionReference? get _journalsCollection =>
      _firebaseService.journalsCollection;

  @override
  Future<void> createJournal(JournalEntity journal) async {
    try {
      if (_journalsCollection == null) {
        throw AuthException('User tidak login');
      }

      await _journalsCollection!
          .doc(journal.id)
          .set(_journalToFirestore(journal));

      print('✅ Journal created: ${journal.id}');
    } catch (e) {
      print('❌ Error creating journal: $e');
      throw DatabaseException('Gagal membuat jurnal: $e');
    }
  }

  @override
  Future<List<JournalEntity>> getAllJournals() async {
    try {
      if (_journalsCollection == null) {
        throw AuthException('User tidak login');
      }

      final snapshot = await _journalsCollection!
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map(_journalFromFirestore).toList();
    } catch (e) {
      throw DatabaseException('Gagal mengambil jurnal: $e');
    }
  }

  @override
  Future<List<JournalEntity>> getJournalsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (_journalsCollection == null) {
        throw AuthException('User tidak login');
      }

      final snapshot = await _journalsCollection!
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map(_journalFromFirestore).toList();
    } catch (e) {
      throw DatabaseException('Gagal mengambil jurnal: $e');
    }
  }

  @override
  Future<void> updateJournal(JournalEntity journal) async {
    try {
      if (_journalsCollection == null) {
        throw AuthException('User tidak login');
      }

      final data = _journalToFirestore(journal);
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _journalsCollection!.doc(journal.id).update(data);
      print('✅ Journal updated: ${journal.id}');
    } catch (e) {
      throw DatabaseException('Gagal memperbarui jurnal: $e');
    }
  }

  @override
  Future<void> deleteJournal(String journalId) async {
    try {
      if (_journalsCollection == null) {
        throw AuthException('User tidak login');
      }

      await _journalsCollection!.doc(journalId).delete();
      print('✅ Journal deleted: $journalId');
    } catch (e) {
      throw DatabaseException('Gagal menghapus jurnal: $e');
    }
  }

  @override
  Stream<List<JournalEntity>> watchJournals() {
    if (_journalsCollection == null) {
      return Stream.error(AuthException('User tidak login'));
    }

    return _journalsCollection!
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_journalFromFirestore).toList();
    });
  }

  Map<String, dynamic> _journalToFirestore(JournalEntity journal) {
    return {
      'id': journal.id,
      'content': journal.content,
      'mood': journal.mood.name,
      'date': Timestamp.fromDate(journal.date),
      'createdAt': Timestamp.fromDate(journal.createdAt),
      'updatedAt': Timestamp.fromDate(journal.updatedAt),
    };
  }

  JournalEntity _journalFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntity(
      id: data['id'],
      content: data['content'],
      mood: Mood.values.firstWhere((e) => e.name == data['mood']),
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}