import 'package:flutter_test/flutter_test.dart';
import 'package:momjournal/data/models/journal_model.dart';

void main() {
  group('JournalModel Tests', () {
    test('JournalModel should be created with all properties', () {
      // Arrange
      final now = DateTime.now();
      final journal = JournalModel(
        id: 'journal-123',
        date: now,
        mood: Mood.happy,
        content: 'Hari ini Fjola tersenyum untuk pertama kali!',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(journal.id, 'journal-123');
      expect(journal.date.day, now.day);
      expect(journal.mood, Mood.happy);
      expect(journal.content, contains('Fjola'));
      expect(journal.userId, 'user-123');
      expect(journal.isSynced, false); // Default value
      expect(journal.isFavorite, false); // Default value
    });

    test('JournalModel should be created with optional parameters', () {
      // Arrange
      final now = DateTime.now();
      final journal = JournalModel(
        id: 'journal-123',
        date: now,
        mood: Mood.happy,
        content: 'Test content',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
        isSynced: true,
        tags: ['happy', 'milestone'],
        isFavorite: true,
      );

      // Assert
      expect(journal.isSynced, true);
      expect(journal.tags, ['happy', 'milestone']);
      expect(journal.isFavorite, true);
    });

    test('toJson should convert model to JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final journal = JournalModel(
        id: 'journal-123',
        date: now,
        mood: Mood.neutral,
        content: 'Hari biasa saja',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final json = journal.toJson();

      // Assert
      expect(json['id'], 'journal-123');
      expect(json['mood'], 'neutral');
      expect(json['content'], 'Hari biasa saja');
      expect(json['userId'], 'user-123');
      expect(json['isSynced'], false);
      expect(json['isFavorite'], false);
      expect(json['date'], isA<String>());
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());
    });

    test('toJson should include optional fields when present', () {
      // Arrange
      final now = DateTime.now();
      final journal = JournalModel(
        id: 'journal-123',
        date: now,
        mood: Mood.happy,
        content: 'Test',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
        tags: ['test', 'happy'],
        isFavorite: true,
      );

      // Act
      final json = journal.toJson();

      // Assert
      expect(json['tags'], ['test', 'happy']);
      expect(json['isFavorite'], true);
    });

    test('fromJson should create model from JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'journal-123',
        'date': now.toIso8601String(),
        'mood': 'sad',
        'content': 'Hari yang berat',
        'userId': 'user-123',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Act
      final journal = JournalModel.fromJson(json);

      // Assert
      expect(journal.id, 'journal-123');
      expect(journal.mood, Mood.sad);
      expect(journal.content, 'Hari yang berat');
      expect(journal.userId, 'user-123');
      expect(journal.isSynced, false); // Default
      expect(journal.isFavorite, false); // Default
    });

    test('fromJson should handle optional fields', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'journal-123',
        'date': now.toIso8601String(),
        'mood': 'happy',
        'content': 'Test',
        'userId': 'user-123',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': true,
        'tags': ['test', 'happy'],
        'isFavorite': true,
      };

      // Act
      final journal = JournalModel.fromJson(json);

      // Assert
      expect(journal.isSynced, true);
      expect(journal.tags, ['test', 'happy']);
      expect(journal.isFavorite, true);
    });

    test('fromJson should handle DateTime objects directly', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'journal-123',
        'date': now,
        'mood': 'neutral',
        'content': 'Test',
        'userId': 'user-123',
        'createdAt': now,
        'updatedAt': now,
      };

      // Act
      final journal = JournalModel.fromJson(json);

      // Assert
      expect(journal.date, now);
      expect(journal.createdAt, now);
      expect(journal.updatedAt, now);
    });

    test('copyWith should create new instance with updated values', () {
      // Arrange
      final now = DateTime.now();
      final original = JournalModel(
        id: 'journal-123',
        date: now,
        mood: Mood.neutral,
        content: 'Original content',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updated = original.copyWith(
        mood: Mood.happy,
        content: 'Updated content',
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.mood, Mood.happy);
      expect(updated.content, 'Updated content');
      expect(updated.userId, original.userId);
      expect(updated.date, original.date);
    });

    test('copyWith should update all fields when provided', () {
      // Arrange
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final original = JournalModel(
        id: 'journal-123',
        date: now,
        mood: Mood.neutral,
        content: 'Original',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updated = original.copyWith(
        id: 'journal-456',
        date: tomorrow,
        mood: Mood.happy,
        content: 'Updated',
        userId: 'user-456',
        isSynced: true,
        tags: ['new'],
        isFavorite: true,
      );

      // Assert
      expect(updated.id, 'journal-456');
      expect(updated.date, tomorrow);
      expect(updated.mood, Mood.happy);
      expect(updated.content, 'Updated');
      expect(updated.userId, 'user-456');
      expect(updated.isSynced, true);
      expect(updated.tags, ['new']);
      expect(updated.isFavorite, true);
    });

    test('Mood enum should have correct values', () {
      // Assert
      expect(Mood.veryHappy.name, 'veryHappy');
      expect(Mood.happy.name, 'happy');
      expect(Mood.neutral.name, 'neutral');
      expect(Mood.sad.name, 'sad');
      expect(Mood.verySad.name, 'verySad');
    });

    test('Mood displayName should return correct Indonesian names', () {
      // Act & Assert
      expect(Mood.veryHappy.displayName, 'Sangat Senang');
      expect(Mood.happy.displayName, 'Senang');
      expect(Mood.neutral.displayName, 'Biasa Saja');
      expect(Mood.sad.displayName, 'Sedih');
      expect(Mood.verySad.displayName, 'Sangat Sedih');
    });

    test('Mood emoji should return correct emojis', () {
      // Act & Assert
      expect(Mood.veryHappy.emoji, 'ðŸ˜„');
      expect(Mood.happy.emoji, 'ðŸ™‚');
      expect(Mood.neutral.emoji, 'ðŸ˜');
      expect(Mood.sad.emoji, 'ðŸ˜"');
      expect(Mood.verySad.emoji, 'ðŸ˜¢');
    });

    test('Mood numericValue should return correct values', () {
      // Act & Assert
      expect(Mood.veryHappy.numericValue, 5);
      expect(Mood.happy.numericValue, 4);
      expect(Mood.neutral.numericValue, 3);
      expect(Mood.sad.numericValue, 2);
      expect(Mood.verySad.numericValue, 1);
    });

    test('Mood colorHex should return correct color codes', () {
      // Act & Assert
      expect(Mood.veryHappy.colorHex, '#27AE60');
      expect(Mood.happy.colorHex, '#F39C12');
      expect(Mood.neutral.colorHex, '#95A5A6');
      expect(Mood.sad.colorHex, '#3498DB');
      expect(Mood.verySad.colorHex, '#9B59B6');
    });

    test('contentPreview should truncate long content', () {
      // Arrange
      final longContent = 'A' * 200;
      final journal = JournalModel(
        id: 'journal-123',
        date: DateTime.now(),
        mood: Mood.neutral,
        content: longContent,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final preview = journal.contentPreview;

      // Assert
      expect(preview.length, 100); // 97 chars + '...'
      expect(preview, endsWith('...'));
    });

    test('contentPreview should not truncate short content', () {
      // Arrange
      const shortContent = 'Hari ini baik';
      final journal = JournalModel(
        id: 'journal-123',
        date: DateTime.now(),
        mood: Mood.happy,
        content: shortContent,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final preview = journal.contentPreview;

      // Assert
      expect(preview, shortContent);
      expect(preview, isNot(endsWith('...')));
    });

    test('characterCount should return correct count', () {
      // Arrange
      const content = 'Hello World';
      final journal = JournalModel(
        id: 'journal-123',
        date: DateTime.now(),
        mood: Mood.neutral,
        content: content,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final count = journal.characterCount;

      // Assert
      expect(count, 11);
    });

    test('isToday should return true for today date', () {
      // Arrange
      final journal = JournalModel(
        id: 'journal-123',
        date: DateTime.now(),
        mood: Mood.neutral,
        content: 'Today',
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(journal.isToday, true);
    });

    test('isToday should return false for past date', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final journal = JournalModel(
        id: 'journal-123',
        date: yesterday,
        mood: Mood.neutral,
        content: 'Yesterday',
        userId: 'user-123',
        createdAt: yesterday,
        updatedAt: yesterday,
      );

      // Act & Assert
      expect(journal.isToday, false);
    });

    test('dateString should return "Hari Ini" for today', () {
      // Arrange
      final journal = JournalModel(
        id: 'journal-123',
        date: DateTime.now(),
        mood: Mood.neutral,
        content: 'Today',
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final dateString = journal.dateString;

      // Assert
      expect(dateString, 'Hari Ini');
    });

    test('dateString should return "Kemarin" for yesterday', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final journal = JournalModel(
        id: 'journal-123',
        date: yesterday,
        mood: Mood.neutral,
        content: 'Yesterday',
        userId: 'user-123',
        createdAt: yesterday,
        updatedAt: yesterday,
      );

      // Act
      final dateString = journal.dateString;

      // Assert
      expect(dateString, 'Kemarin');
    });

    test('dateString should return formatted date for older dates', () {
      // Arrange
      final oldDate = DateTime(2024, 12, 16); // Monday
      final journal = JournalModel(
        id: 'journal-123',
        date: oldDate,
        mood: Mood.neutral,
        content: 'Old',
        userId: 'user-123',
        createdAt: oldDate,
        updatedAt: oldDate,
      );

      // Act
      final dateString = journal.dateString;

      // Assert
      expect(dateString, contains('16'));
      expect(dateString, contains('Des'));
      expect(dateString, contains('2024'));
    });

    test('toString should return formatted string', () {
      // Arrange
      final now = DateTime.now();
      final journal = JournalModel(
        id: 'journal-123',
        date: now,
        mood: Mood.happy,
        content: 'Test content',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final string = journal.toString();

      // Assert
      expect(string, contains('journal-123'));
      expect(string, contains('Mood.happy'));
      expect(string, contains('contentLength: 12'));
      expect(string, contains('isSynced: false'));
    });

    test('equality operator should work correctly with same ID', () {
      // Arrange
      final now = DateTime.now();
      final journal1 = JournalModel(
        id: 'same-id',
        date: now,
        mood: Mood.happy,
        content: 'Content 1',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      final journal2 = JournalModel(
        id: 'same-id',
        date: now,
        mood: Mood.happy,
        content: 'Content 1',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(journal1 == journal2, true);
      expect(journal1.hashCode, journal2.hashCode);
    });

    test('equality operator should return false for different content', () {
      // Arrange
      final now = DateTime.now();
      final journal1 = JournalModel(
        id: 'same-id',
        date: now,
        mood: Mood.happy,
        content: 'Content 1',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      final journal2 = JournalModel(
        id: 'same-id',
        date: now,
        mood: Mood.happy,
        content: 'Content 2', // Different content
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(journal1 == journal2, false);
    });

    test('equality operator should return false for different IDs', () {
      // Arrange
      final now = DateTime.now();
      final journal1 = JournalModel(
        id: 'id-1',
        date: now,
        mood: Mood.happy,
        content: 'Content',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      final journal2 = JournalModel(
        id: 'id-2',
        date: now,
        mood: Mood.happy,
        content: 'Content',
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(journal1 == journal2, false);
    });

    test('fromJson should handle invalid mood gracefully', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'journal-123',
        'date': now.toIso8601String(),
        'mood': 'invalid_mood',
        'content': 'Test',
        'userId': 'user-123',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Act
      final journal = JournalModel.fromJson(json);

      // Assert
      expect(journal.mood, Mood.neutral); // Should default to neutral
    });
  });
}