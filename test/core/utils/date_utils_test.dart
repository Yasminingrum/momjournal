import 'package:flutter_test/flutter_test.dart';
import 'package:momjournal/core/utils/date_utils.dart';

void main() {
  group('DateUtils Tests', () {
    test('formatDisplay should format date correctly', () {
      // Arrange
      final date = DateTime(2024, 12, 16);
      
      // Act
      final result = DateUtils.formatDisplay(date);
      
      // Assert
      expect(result, '16 Desember 2024');
    });

    test('formatShort should format date correctly', () {
      // Arrange
      final date = DateTime(2024, 12, 16);
      
      // Act
      final result = DateUtils.formatShort(date);
      
      // Assert
      expect(result, '16/12/2024');
    });

    test('formatTime should format time correctly', () {
      // Arrange
      final time = DateTime(2024, 12, 16, 14, 30);
      
      // Act
      final result = DateUtils.formatTime(time);
      
      // Assert
      expect(result, '14:30');
    });

    test('formatDateTime should format date and time correctly', () {
      // Arrange
      final dateTime = DateTime(2024, 12, 16, 14, 30);
      
      // Act
      final result = DateUtils.formatDateTime(dateTime);
      
      // Assert
      expect(result, '16/12/2024 14:30');
    });

    test('isToday should return true for today date', () {
      // Arrange
      final today = DateTime.now();
      
      // Act
      final result = DateUtils.isToday(today);
      
      // Assert
      expect(result, true);
    });

    test('isToday should return false for past date', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      
      // Act
      final result = DateUtils.isToday(yesterday);
      
      // Assert
      expect(result, false);
    });

    test('isYesterday should return true for yesterday date', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      
      // Act
      final result = DateUtils.isYesterday(yesterday);
      
      // Assert
      expect(result, true);
    });

    test('isTomorrow should return true for tomorrow date', () {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      
      // Act
      final result = DateUtils.isTomorrow(tomorrow);
      
      // Assert
      expect(result, true);
    });

    test('isSameDay should return true for same day', () {
      // Arrange
      final date1 = DateTime(2024, 12, 16, 10, 0);
      final date2 = DateTime(2024, 12, 16, 15, 30);
      
      // Act
      final result = DateUtils.isSameDay(date1, date2);
      
      // Assert
      expect(result, true);
    });

    test('isSameDay should return false for different days', () {
      // Arrange
      final date1 = DateTime(2024, 12, 16);
      final date2 = DateTime(2024, 12, 17);
      
      // Act
      final result = DateUtils.isSameDay(date1, date2);
      
      // Assert
      expect(result, false);
    });

    test('getRelativeDateString should return "Hari ini" for today', () {
      // Arrange
      final today = DateTime.now();
      
      // Act
      final result = DateUtils.getRelativeDateString(today);
      
      // Assert
      expect(result, 'Hari ini');
    });

    test('getRelativeDateString should return "Kemarin" for yesterday', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      
      // Act
      final result = DateUtils.getRelativeDateString(yesterday);
      
      // Assert
      expect(result, 'Kemarin');
    });

    test('getRelativeDateString should return "Besok" for tomorrow', () {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      
      // Act
      final result = DateUtils.getRelativeDateString(tomorrow);
      
      // Assert
      expect(result, 'Besok');
    });

    test('startOfDay should return midnight time', () {
      // Arrange
      final date = DateTime(2024, 12, 16, 14, 30, 45);
      
      // Act
      final result = DateUtils.startOfDay(date);
      
      // Assert
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.day, 16);
    });

    test('endOfDay should return end of day time', () {
      // Arrange
      final date = DateTime(2024, 12, 16, 10, 30);
      
      // Act
      final result = DateUtils.endOfDay(date);
      
      // Assert
      expect(result.hour, 23);
      expect(result.minute, 59);
      expect(result.second, 59);
      expect(result.day, 16);
    });

    test('isPast should return true for past date', () {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      
      // Act
      final result = DateUtils.isPast(pastDate);
      
      // Assert
      expect(result, true);
    });

    test('isFuture should return true for future date', () {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 1));
      
      // Act
      final result = DateUtils.isFuture(futureDate);
      
      // Assert
      expect(result, true);
    });

    test('getAgeInMonths should calculate correct age', () {
      // Arrange
      final birthDate = DateTime.now().subtract(const Duration(days: 90));
      
      // Act
      final result = DateUtils.getAgeInMonths(birthDate);
      
      // Assert
      expect(result, greaterThanOrEqualTo(2));
      expect(result, lessThanOrEqualTo(4));
    });

    test('getAgeInYears should calculate correct age', () {
      // Arrange
      final birthDate = DateTime.now().subtract(const Duration(days: 400));
      
      // Act
      final result = DateUtils.getAgeInYears(birthDate);
      
      // Assert
      expect(result, greaterThanOrEqualTo(1));
    });

    test('startOfMonth should return first day of month', () {
      // Arrange
      final date = DateTime(2024, 12, 16);
      
      // Act
      final result = DateUtils.startOfMonth(date);
      
      // Assert
      expect(result.day, 1);
      expect(result.month, 12);
      expect(result.year, 2024);
    });

    test('endOfMonth should return last day of month', () {
      // Arrange
      final date = DateTime(2024, 12, 16);
      
      // Act
      final result = DateUtils.endOfMonth(date);
      
      // Assert
      expect(result.day, 31);
      expect(result.month, 12);
      expect(result.year, 2024);
    });

    test('daysInMonth should return correct number of days', () {
      // Arrange
      final decemberDate = DateTime(2024, 12, 1);
      final februaryDate = DateTime(2024, 2, 1);
      
      // Act
      final decemberDays = DateUtils.daysInMonth(decemberDate);
      final februaryDays = DateUtils.daysInMonth(februaryDate);
      
      // Assert
      expect(decemberDays, 31);
      expect(februaryDays, 29); // 2024 is leap year
    });

    test('getTimeDifference should return readable time difference', () {
      // Arrange
      final from = DateTime(2024, 12, 16, 10, 0);
      final to = DateTime(2024, 12, 16, 12, 30);
      
      // Act
      final result = DateUtils.getTimeDifference(from, to);
      
      // Assert
      expect(result, '2 jam');
    });

    test('getGreeting should return correct greeting based on time', () {
      // Act
      final result = DateUtils.getGreeting();
      
      // Assert
      expect(result, isA<String>());
      expect(result, isIn(['Selamat Pagi', 'Selamat Siang', 'Selamat Sore', 'Selamat Malam']));
    });

    test('parseDate should parse valid date string', () {
      // Arrange
      const dateString = '2024-12-16';
      
      // Act
      final result = DateUtils.parseDate(dateString);
      
      // Assert
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 12);
      expect(result.day, 16);
    });

    test('parseDate should return null for invalid date string', () {
      // Arrange
      const invalidString = 'invalid-date';
      
      // Act
      final result = DateUtils.parseDate(invalidString);
      
      // Assert
      expect(result, isNull);
    });

    test('getDatesBetween should return list of dates', () {
      // Arrange
      final start = DateTime(2024, 12, 1);
      final end = DateTime(2024, 12, 5);
      
      // Act
      final result = DateUtils.getDatesBetween(start, end);
      
      // Assert
      expect(result.length, 5);
      expect(result.first.day, 1);
      expect(result.last.day, 5);
    });

    test('combineDateTime should combine date and time correctly', () {
      // Arrange
      final date = DateTime(2024, 12, 16);
      final time = DateTime(2024, 1, 1, 14, 30);
      
      // Act
      final result = DateUtils.combineDateTime(date, time);
      
      // Assert
      expect(result.year, 2024);
      expect(result.month, 12);
      expect(result.day, 16);
      expect(result.hour, 14);
      expect(result.minute, 30);
    });

    test('isThisWeek should return true for dates in current week', () {
      // Arrange
      final today = DateTime.now();
      
      // Act
      final result = DateUtils.isThisWeek(today);
      
      // Assert
      expect(result, true);
    });

    test('isThisMonth should return true for dates in current month', () {
      // Arrange
      final today = DateTime.now();
      
      // Act
      final result = DateUtils.isThisMonth(today);
      
      // Assert
      expect(result, true);
    });

    test('getAgeString should return formatted age string', () {
      // Arrange
      final birthDate = DateTime.now().subtract(const Duration(days: 450));
      
      // Act
      final result = DateUtils.getAgeString(birthDate);
      
      // Assert
      expect(result, isA<String>());
      expect(result, contains('tahun'));
    });

    test('getRelativeTimeString should return relative time', () {
      // Arrange
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      
      // Act
      final result = DateUtils.getRelativeTimeString(fiveMinutesAgo);
      
      // Assert
      expect(result, '5 menit yang lalu');
    });

    test('startOfWeek should return Monday of current week', () {
      // Arrange
      final date = DateTime(2024, 12, 18); // Wednesday
      
      // Act
      final result = DateUtils.startOfWeek(date);
      
      // Assert
      expect(result.weekday, DateTime.monday);
    });

    test('endOfWeek should return Sunday of current week', () {
      // Arrange
      final date = DateTime(2024, 12, 18); // Wednesday
      
      // Act
      final result = DateUtils.endOfWeek(date);
      
      // Assert
      expect(result.weekday, DateTime.sunday);
    });
  });
}