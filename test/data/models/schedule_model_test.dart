import 'package:flutter_test/flutter_test.dart';
import 'package:momjournal/data/models/schedule_model.dart';

void main() {
  group('ScheduleModel Tests', () {
    test('ScheduleModel should be created with all properties', () {
      // Arrange
      final now = DateTime.now();
      final schedule = ScheduleModel(
        id: 'test-id-123',
        title: 'Vaksinasi BCG',
        description: 'Vaksinasi BCG pertama',
        scheduledTime: now,
        category: ScheduleCategory.health,
        reminderEnabled: true,
        reminderMinutesBefore: 30,
        isCompleted: false,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(schedule.id, 'test-id-123');
      expect(schedule.title, 'Vaksinasi BCG');
      expect(schedule.description, 'Vaksinasi BCG pertama');
      expect(schedule.scheduledTime, now);
      expect(schedule.category, ScheduleCategory.health);
      expect(schedule.reminderEnabled, true);
      expect(schedule.reminderMinutesBefore, 30);
      expect(schedule.isCompleted, false);
      expect(schedule.userId, 'user-123');
      expect(schedule.isSynced, false); // Default value
    });

    test('ScheduleModel should be created with optional parameters', () {
      // Arrange
      final now = DateTime.now();
      final schedule = ScheduleModel(
        id: 'test-id-123',
        title: 'Test',
        scheduledTime: now,
        category: ScheduleCategory.health,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
        completedAt: now,
        completionNotes: 'Done well',
        notificationId: 12345,
      );

      // Assert
      expect(schedule.completedAt, now);
      expect(schedule.completionNotes, 'Done well');
      expect(schedule.notificationId, 12345);
    });

    test('toJson should convert model to JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final schedule = ScheduleModel(
        id: 'test-id-123',
        title: 'Makan Siang',
        description: 'Bubur sayur',
        scheduledTime: now,
        category: ScheduleCategory.feeding,
        reminderEnabled: true,
        reminderMinutesBefore: 15,
        isCompleted: false,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final json = schedule.toJson();

      // Assert
      expect(json['id'], 'test-id-123');
      expect(json['title'], 'Makan Siang');
      expect(json['description'], 'Bubur sayur');
      expect(json['category'], 'feeding');
      expect(json['reminderEnabled'], true);
      expect(json['reminderMinutesBefore'], 15);
      expect(json['isCompleted'], false);
      expect(json['userId'], 'user-123');
      expect(json['isSynced'], false);
      expect(json['scheduledTime'], isA<String>());
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());
    });

    test('toJson should include optional fields when present', () {
      // Arrange
      final now = DateTime.now();
      final schedule = ScheduleModel(
        id: 'test-id-123',
        title: 'Test',
        scheduledTime: now,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
        completedAt: now,
        completionNotes: 'Completed successfully',
        notificationId: 999,
      );

      // Act
      final json = schedule.toJson();

      // Assert
      expect(json['completedAt'], isA<String>());
      expect(json['completionNotes'], 'Completed successfully');
      expect(json['notificationId'], 999);
    });

    test('fromJson should create model from JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'test-id-123',
        'title': 'Tidur Siang',
        'description': 'Tidur siang 2 jam',
        'scheduledTime': now.toIso8601String(),
        'category': 'sleeping',
        'reminderEnabled': false,
        'reminderMinutesBefore': 0,
        'isCompleted': true,
        'userId': 'user-123',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Act
      final schedule = ScheduleModel.fromJson(json);

      // Assert
      expect(schedule.id, 'test-id-123');
      expect(schedule.title, 'Tidur Siang');
      expect(schedule.description, 'Tidur siang 2 jam');
      expect(schedule.category, ScheduleCategory.sleeping);
      expect(schedule.reminderEnabled, false);
      expect(schedule.isCompleted, true);
      expect(schedule.isSynced, false); // Default
    });

    test('fromJson should handle optional fields', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'test-id-123',
        'title': 'Test',
        'scheduledTime': now.toIso8601String(),
        'category': 'health',
        'userId': 'user-123',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'completedAt': now.toIso8601String(),
        'completionNotes': 'Done',
        'notificationId': 123,
        'isSynced': true,
      };

      // Act
      final schedule = ScheduleModel.fromJson(json);

      // Assert
      expect(schedule.completedAt, isNotNull);
      expect(schedule.completionNotes, 'Done');
      expect(schedule.notificationId, 123);
      expect(schedule.isSynced, true);
    });

    test('fromJson should handle DateTime objects directly', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'test-id-123',
        'title': 'Test',
        'scheduledTime': now,
        'category': 'other',
        'userId': 'user-123',
        'createdAt': now,
        'updatedAt': now,
        'completedAt': now,
      };

      // Act
      final schedule = ScheduleModel.fromJson(json);

      // Assert
      expect(schedule.scheduledTime, now);
      expect(schedule.createdAt, now);
      expect(schedule.updatedAt, now);
      expect(schedule.completedAt, now);
    });

    test('copyWith should create new instance with updated values', () {
      // Arrange
      final now = DateTime.now();
      final original = ScheduleModel(
        id: 'test-id-123',
        title: 'Original Title',
        description: 'Original Description',
        scheduledTime: now,
        category: ScheduleCategory.feeding,
        reminderEnabled: false,
        reminderMinutesBefore: 0,
        isCompleted: false,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updated = original.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.title, 'Updated Title');
      expect(updated.description, original.description);
      expect(updated.isCompleted, true);
      expect(updated.category, original.category);
    });

    test('copyWith should update all fields when provided', () {
      // Arrange
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final original = ScheduleModel(
        id: 'test-id-123',
        title: 'Original',
        scheduledTime: now,
        category: ScheduleCategory.feeding,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updated = original.copyWith(
        id: 'test-id-456',
        title: 'Updated',
        description: 'New description',
        scheduledTime: tomorrow,
        category: ScheduleCategory.health,
        reminderEnabled: false,
        reminderMinutesBefore: 60,
        isCompleted: true,
        completedAt: tomorrow,
        completionNotes: 'Done',
        isSynced: true,
        notificationId: 999,
      );

      // Assert
      expect(updated.id, 'test-id-456');
      expect(updated.title, 'Updated');
      expect(updated.description, 'New description');
      expect(updated.scheduledTime, tomorrow);
      expect(updated.category, ScheduleCategory.health);
      expect(updated.reminderEnabled, false);
      expect(updated.reminderMinutesBefore, 60);
      expect(updated.isCompleted, true);
      expect(updated.completedAt, tomorrow);
      expect(updated.completionNotes, 'Done');
      expect(updated.isSynced, true);
      expect(updated.notificationId, 999);
    });

    test('ScheduleCategory should have correct string values', () {
      // Assert
      expect(ScheduleCategory.feeding.name, 'feeding');
      expect(ScheduleCategory.sleeping.name, 'sleeping');
      expect(ScheduleCategory.health.name, 'health');
      expect(ScheduleCategory.milestone.name, 'milestone');
      expect(ScheduleCategory.other.name, 'other');
    });

    test('ScheduleCategory displayName should return correct Indonesian names', () {
      // Act & Assert
      expect(ScheduleCategory.feeding.displayName, 'Pemberian Makan');
      expect(ScheduleCategory.sleeping.displayName, 'Tidur');
      expect(ScheduleCategory.health.displayName, 'Kesehatan');
      expect(ScheduleCategory.milestone.displayName, 'Pencapaian');
      expect(ScheduleCategory.other.displayName, 'Lainnya');
    });

    test('ScheduleCategory emoji should return correct emojis', () {
      // Act & Assert
      expect(ScheduleCategory.feeding.emoji, 'ðŸ¼');
      expect(ScheduleCategory.sleeping.emoji, 'ðŸ˜´');
      expect(ScheduleCategory.health.emoji, 'ðŸ¥');
      expect(ScheduleCategory.milestone.emoji, 'ðŸŽ‰');
      expect(ScheduleCategory.other.emoji, 'ðŸ"Œ');
    });

    test('ScheduleCategory colorHex should return correct color codes', () {
      // Act & Assert
      expect(ScheduleCategory.feeding.colorHex, '#4A90E2');
      expect(ScheduleCategory.sleeping.colorHex, '#9B59B6');
      expect(ScheduleCategory.health.colorHex, '#E74C3C');
      expect(ScheduleCategory.milestone.colorHex, '#2ECC71');
      expect(ScheduleCategory.other.colorHex, '#95A5A6');
    });

    test('isPast should return true for past schedules', () {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));
      final schedule = ScheduleModel(
        id: 'test-id',
        title: 'Past Schedule',
        scheduledTime: pastDate,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final isPast = schedule.isPast;

      // Assert
      expect(isPast, true);
    });

    test('isPast should return false for future schedules', () {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(hours: 1));
      final schedule = ScheduleModel(
        id: 'test-id',
        title: 'Future Schedule',
        scheduledTime: futureDate,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final isPast = schedule.isPast;

      // Assert
      expect(isPast, false);
    });

    test('isToday should return true for today schedules', () {
      // Arrange
      final today = DateTime.now();
      final schedule = ScheduleModel(
        id: 'test-id',
        title: 'Today Schedule',
        scheduledTime: today,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final isToday = schedule.isToday;

      // Assert
      expect(isToday, true);
    });

    test('isToday should return false for past dates', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final schedule = ScheduleModel(
        id: 'test-id',
        title: 'Yesterday Schedule',
        scheduledTime: yesterday,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final isToday = schedule.isToday;

      // Assert
      expect(isToday, false);
    });

    test('isUpcoming should return true for future incomplete schedules', () {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(hours: 1));
      final schedule = ScheduleModel(
        id: 'test-id',
        title: 'Future Schedule',
        scheduledTime: futureDate,
        category: ScheduleCategory.other,
        isCompleted: false,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final isUpcoming = schedule.isUpcoming;

      // Assert
      expect(isUpcoming, true);
    });

    test('isUpcoming should return false for completed schedules', () {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(hours: 1));
      final schedule = ScheduleModel(
        id: 'test-id',
        title: 'Completed Schedule',
        scheduledTime: futureDate,
        category: ScheduleCategory.other,
        isCompleted: true,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final isUpcoming = schedule.isUpcoming;

      // Assert
      expect(isUpcoming, false);
    });

    test('isUpcoming should return false for past schedules', () {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));
      final schedule = ScheduleModel(
        id: 'test-id',
        title: 'Past Schedule',
        scheduledTime: pastDate,
        category: ScheduleCategory.other,
        isCompleted: false,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final isUpcoming = schedule.isUpcoming;

      // Assert
      expect(isUpcoming, false);
    });

    test('toString should return formatted string', () {
      // Arrange
      final now = DateTime.now();
      final schedule = ScheduleModel(
        id: 'test-id-123',
        title: 'Test Schedule',
        scheduledTime: now,
        category: ScheduleCategory.health,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final string = schedule.toString();

      // Assert
      expect(string, contains('test-id-123'));
      expect(string, contains('Test Schedule'));
      expect(string, contains('ScheduleCategory.health'));
      expect(string, contains('isCompleted: false'));
    });

    test('equality operator should work correctly with same values', () {
      // Arrange
      final now = DateTime.now();
      final schedule1 = ScheduleModel(
        id: 'same-id',
        title: 'Test',
        scheduledTime: now,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      final schedule2 = ScheduleModel(
        id: 'same-id',
        title: 'Test',
        scheduledTime: now,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(schedule1 == schedule2, true);
      expect(schedule1.hashCode, schedule2.hashCode);
    });

    test('equality operator should return false for different values', () {
      // Arrange
      final now = DateTime.now();
      final schedule1 = ScheduleModel(
        id: 'same-id',
        title: 'Test',
        scheduledTime: now,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      final schedule2 = ScheduleModel(
        id: 'same-id',
        title: 'Different Title',
        scheduledTime: now,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(schedule1 == schedule2, false);
    });

    test('equality operator should return false for different IDs', () {
      // Arrange
      final now = DateTime.now();
      final schedule1 = ScheduleModel(
        id: 'id-1',
        title: 'Test',
        scheduledTime: now,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      final schedule2 = ScheduleModel(
        id: 'id-2',
        title: 'Test',
        scheduledTime: now,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(schedule1 == schedule2, false);
    });

    test('fromJson should handle invalid category gracefully', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'test-id-123',
        'title': 'Test',
        'scheduledTime': now.toIso8601String(),
        'category': 'invalid_category',
        'userId': 'user-123',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Act
      final schedule = ScheduleModel.fromJson(json);

      // Assert
      expect(schedule.category, ScheduleCategory.other); // Should default to other
    });

    test('default values should be set correctly', () {
      // Arrange
      final now = DateTime.now();
      final schedule = ScheduleModel(
        id: 'test-id',
        title: 'Test',
        scheduledTime: now,
        category: ScheduleCategory.other,
        userId: 'user-123',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(schedule.reminderEnabled, true); // Default
      expect(schedule.reminderMinutesBefore, 15); // Default
      expect(schedule.isCompleted, false); // Default
      expect(schedule.isSynced, false); // Default
    });
  });
}