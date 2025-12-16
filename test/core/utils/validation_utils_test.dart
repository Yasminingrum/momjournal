import 'package:flutter_test/flutter_test.dart';
import 'package:momjournal/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils Tests', () {
    group('Basic Validation', () {
      test('isNotEmpty should return true for non-empty string', () {
        // Act & Assert
        expect(ValidationUtils.isNotEmpty('Hello'), true);
        expect(ValidationUtils.isNotEmpty('  Text  '), true);
      });

      test('isNotEmpty should return false for empty or whitespace', () {
        // Act & Assert
        expect(ValidationUtils.isNotEmpty(''), false);
        expect(ValidationUtils.isNotEmpty('   '), false);
        expect(ValidationUtils.isNotEmpty(null), false);
      });

      test('isEmpty should return true for empty or null string', () {
        // Act & Assert
        expect(ValidationUtils.isEmpty(''), true);
        expect(ValidationUtils.isEmpty('   '), true);
        expect(ValidationUtils.isEmpty(null), true);
      });

      test('isEmpty should return false for non-empty string', () {
        // Act & Assert
        expect(ValidationUtils.isEmpty('Hello'), false);
      });
    });

    group('Length Validation', () {
      test('hasMinLength should validate minimum length correctly', () {
        // Act & Assert
        expect(ValidationUtils.hasMinLength('Hello', 3), true);
        expect(ValidationUtils.hasMinLength('Hi', 3), false);
        expect(ValidationUtils.hasMinLength(null, 3), false);
      });

      test('hasMaxLength should validate maximum length correctly', () {
        // Act & Assert
        expect(ValidationUtils.hasMaxLength('Hello', 10), true);
        expect(ValidationUtils.hasMaxLength('Very long text', 5), false);
        expect(ValidationUtils.hasMaxLength(null, 10), true);
      });

      test('hasLengthInRange should validate length range correctly', () {
        // Act & Assert
        expect(ValidationUtils.hasLengthInRange('Hello', 3, 10), true);
        expect(ValidationUtils.hasLengthInRange('Hi', 3, 10), false);
        expect(ValidationUtils.hasLengthInRange('Very long text', 3, 10), false);
      });
    });

    group('Email Validation', () {
      test('isValidEmail should return true for valid email', () {
        // Arrange
        const validEmails = [
          'test@example.com',
          'user.name@example.com',
          'user+tag@example.co.id',
          'test123@test-domain.com',
        ];

        // Act & Assert
        for (final email in validEmails) {
          expect(ValidationUtils.isValidEmail(email), true,
              reason: '$email should be valid',);
        }
      });

      test('isValidEmail should return false for invalid email', () {
        // Arrange
        const invalidEmails = [
          'test',
          'test@',
          '@example.com',
          'test@example',
          'test @example.com',
          'test@exam ple.com',
          '',
          null,
        ];

        // Act & Assert
        for (final email in invalidEmails) {
          expect(ValidationUtils.isValidEmail(email), false,
              reason: '$email should be invalid',);
        }
      });

      test('validateEmail should return error messages correctly', () {
        // Act
        final emptyError = ValidationUtils.validateEmail('');
        final invalidError = ValidationUtils.validateEmail('invalid');
        final validResult = ValidationUtils.validateEmail('test@example.com');

        // Assert
        expect(emptyError, 'Email wajib diisi');
        expect(invalidError, 'Format email tidak valid');
        expect(validResult, isNull);
      });
    });

    group('Phone Number Validation', () {
      test('isValidPhoneNumber should return true for valid Indonesian phone', () {
        // Arrange
        const validPhones = [
          '081234567890',
          '0812-3456-7890',
          '+6281234567890',
          '6281234567890',
          '021-12345678',
        ];

        // Act & Assert
        for (final phone in validPhones) {
          expect(ValidationUtils.isValidPhoneNumber(phone), true,
              reason: '$phone should be valid',);
        }
      });

      test('isValidPhoneNumber should return false for invalid phone', () {
        // Arrange
        const invalidPhones = [
          '123',
          'abc',
          '08123',
          '',
          null,
        ];

        // Act & Assert
        for (final phone in invalidPhones) {
          expect(ValidationUtils.isValidPhoneNumber(phone), false,
              reason: '$phone should be invalid',);
        }
      });

      test('validatePhone should return error messages correctly', () {
        // Act
        final emptyError = ValidationUtils.validatePhone('');
        final invalidError = ValidationUtils.validatePhone('123');
        final validResult = ValidationUtils.validatePhone('081234567890');

        // Assert
        expect(emptyError, 'Nomor telepon wajib diisi');
        expect(invalidError, 'Format nomor telepon tidak valid');
        expect(validResult, isNull);
      });
    });

    group('URL Validation', () {
      test('isValidUrl should return true for valid URLs', () {
        // Arrange
        const validUrls = [
          'https://example.com',
          'http://www.example.com',
          'https://example.com/path',
          'https://sub.example.com',
        ];

        // Act & Assert
        for (final url in validUrls) {
          expect(ValidationUtils.isValidUrl(url), true,
              reason: '$url should be valid',);
        }
      });

      test('isValidUrl should return false for invalid URLs', () {
        // Arrange
        const invalidUrls = [
          'example.com',
          'not a url',
          '',
          null,
        ];

        // Act & Assert
        for (final url in invalidUrls) {
          expect(ValidationUtils.isValidUrl(url), false,
              reason: '$url should be invalid',);
        }
      });
    });

    group('Date Validation', () {
      test('isNotFutureDate should return true for past and today dates', () {
        // Arrange
        final today = DateTime.now();
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        expect(ValidationUtils.isNotFutureDate(today), true);
        expect(ValidationUtils.isNotFutureDate(yesterday), true);
        expect(ValidationUtils.isNotFutureDate(null), false);
      });

      test('isNotFutureDate should return false for future date', () {
        // Arrange
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        // Act
        final result = ValidationUtils.isNotFutureDate(tomorrow);

        // Assert
        expect(result, false);
      });

      test('isNotPastDate should return true for future and today dates', () {
        // Arrange
        final today = DateTime.now();
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        // Act & Assert
        expect(ValidationUtils.isNotPastDate(today), true);
        expect(ValidationUtils.isNotPastDate(tomorrow), true);
        expect(ValidationUtils.isNotPastDate(null), false);
      });

      test('isNotPastDate should return false for past date', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act
        final result = ValidationUtils.isNotPastDate(yesterday);

        // Assert
        expect(result, false);
      });

      test('isDateInRange should validate date range correctly', () {
        // Arrange
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 12, 31);
        final inRange = DateTime(2024, 6, 15);
        final outRange = DateTime(2023, 12, 31);

        // Act & Assert
        expect(ValidationUtils.isDateInRange(inRange, start, end), true);
        expect(ValidationUtils.isDateInRange(start, start, end), true);
        expect(ValidationUtils.isDateInRange(end, start, end), true);
        expect(ValidationUtils.isDateInRange(outRange, start, end), false);
        expect(ValidationUtils.isDateInRange(null, start, end), false);
      });
    });

    group('Number Validation', () {
      test('isPositive should return true for positive numbers', () {
        // Act & Assert
        expect(ValidationUtils.isPositive(1), true);
        expect(ValidationUtils.isPositive(0.1), true);
        expect(ValidationUtils.isPositive(100), true);
      });

      test('isPositive should return false for non-positive numbers', () {
        // Act & Assert
        expect(ValidationUtils.isPositive(0), false);
        expect(ValidationUtils.isPositive(-1), false);
        expect(ValidationUtils.isPositive(null), false);
      });

      test('isNotNegative should return true for non-negative numbers', () {
        // Act & Assert
        expect(ValidationUtils.isNotNegative(0), true);
        expect(ValidationUtils.isNotNegative(1), true);
        expect(ValidationUtils.isNotNegative(100), true);
      });

      test('isNotNegative should return false for negative numbers', () {
        // Act & Assert
        expect(ValidationUtils.isNotNegative(-1), false);
        expect(ValidationUtils.isNotNegative(null), false);
      });

      test('isInRange should validate number range correctly', () {
        // Act & Assert
        expect(ValidationUtils.isInRange(5, 1, 10), true);
        expect(ValidationUtils.isInRange(1, 1, 10), true);
        expect(ValidationUtils.isInRange(10, 1, 10), true);
        expect(ValidationUtils.isInRange(0, 1, 10), false);
        expect(ValidationUtils.isInRange(11, 1, 10), false);
        expect(ValidationUtils.isInRange(null, 1, 10), false);
      });
    });

    group('String Type Validation', () {
      test('isAlphabetic should return true for alphabetic strings', () {
        // Act & Assert
        expect(ValidationUtils.isAlphabetic('Hello'), true);
        expect(ValidationUtils.isAlphabetic('Hello World'), true);
        expect(ValidationUtils.isAlphabetic('ABC'), true);
      });

      test('isAlphabetic should return false for non-alphabetic strings', () {
        // Act & Assert
        expect(ValidationUtils.isAlphabetic('Hello123'), false);
        expect(ValidationUtils.isAlphabetic('123'), false);
        expect(ValidationUtils.isAlphabetic(''), false);
        expect(ValidationUtils.isAlphabetic(null), false);
      });

      test('isNumeric should return true for numeric strings', () {
        // Act & Assert
        expect(ValidationUtils.isNumeric('123'), true);
        expect(ValidationUtils.isNumeric('0'), true);
      });

      test('isNumeric should return false for non-numeric strings', () {
        // Act & Assert
        expect(ValidationUtils.isNumeric('12.3'), false);
        expect(ValidationUtils.isNumeric('abc'), false);
        expect(ValidationUtils.isNumeric(''), false);
        expect(ValidationUtils.isNumeric(null), false);
      });

      test('isAlphanumeric should return true for alphanumeric strings', () {
        // Act & Assert
        expect(ValidationUtils.isAlphanumeric('Hello123'), true);
        expect(ValidationUtils.isAlphanumeric('Test 123'), true);
        expect(ValidationUtils.isAlphanumeric('ABC'), true);
      });

      test('isAlphanumeric should return false for non-alphanumeric strings', () {
        // Act & Assert
        expect(ValidationUtils.isAlphanumeric('Hello!'), false);
        expect(ValidationUtils.isAlphanumeric(''), false);
        expect(ValidationUtils.isAlphanumeric(null), false);
      });
    });

    group('Password Validation', () {
      test('isStrongPassword should return true for strong passwords', () {
        // Arrange
        const strongPasswords = [
          'Password123',
          'Test1234',
          'MyPass123',
        ];

        // Act & Assert
        for (final password in strongPasswords) {
          expect(ValidationUtils.isStrongPassword(password), true,
              reason: '$password should be strong',);
        }
      });

      test('isStrongPassword should return false for weak passwords', () {
        // Arrange
        const weakPasswords = [
          'pass',
          'password',
          'PASSWORD',
          '12345678',
          '',
          null,
        ];

        // Act & Assert
        for (final password in weakPasswords) {
          expect(ValidationUtils.isStrongPassword(password), false,
              reason: '$password should be weak',);
        }
      });

      test('validatePassword should return error messages correctly', () {
        // Act
        final emptyError = ValidationUtils.validatePassword('');
        final weakError = ValidationUtils.validatePassword('weak');
        final strongResult = ValidationUtils.validatePassword('Password123');

        // Assert
        expect(emptyError, 'Password wajib diisi');
        expect(weakError, contains('minimal 8 karakter'));
        expect(strongResult, isNull);
      });

      test('validatePasswordConfirmation should validate correctly', () {
        // Act
        final emptyError = ValidationUtils.validatePasswordConfirmation('Pass123', '');
        final mismatchError = ValidationUtils.validatePasswordConfirmation('Pass123', 'Pass456');
        final matchResult = ValidationUtils.validatePasswordConfirmation('Pass123', 'Pass123');

        // Assert
        expect(emptyError, 'Konfirmasi password wajib diisi');
        expect(mismatchError, 'Password tidak cocok');
        expect(matchResult, isNull);
      });
    });

    group('Field Validation with Error Messages', () {
      test('validateRequired should return error for empty field', () {
        // Act
        final error = ValidationUtils.validateRequired('');
        final errorWithField = ValidationUtils.validateRequired('', fieldName: 'Nama');
        final validResult = ValidationUtils.validateRequired('Value');

        // Assert
        expect(error, 'Field ini wajib diisi');
        expect(errorWithField, 'Nama wajib diisi');
        expect(validResult, isNull);
      });

      test('validateMinLength should return error for short text', () {
        // Act
        final emptyError = ValidationUtils.validateMinLength('', 5);
        final shortError = ValidationUtils.validateMinLength('Hi', 5);
        final shortErrorWithField = ValidationUtils.validateMinLength('Hi', 5, fieldName: 'Nama');
        final validResult = ValidationUtils.validateMinLength('Hello', 5);

        // Assert
        expect(emptyError, 'Field ini wajib diisi');
        expect(shortError, 'Minimal 5 karakter');
        expect(shortErrorWithField, 'Nama minimal 5 karakter');
        expect(validResult, isNull);
      });

      test('validateMaxLength should return error for long text', () {
        // Act
        final longError = ValidationUtils.validateMaxLength('Very long text', 5);
        final longErrorWithField = ValidationUtils.validateMaxLength('Very long text', 5, fieldName: 'Nama');
        final validResult = ValidationUtils.validateMaxLength('Short', 10);

        // Assert
        expect(longError, 'Maksimal 5 karakter');
        expect(longErrorWithField, 'Nama maksimal 5 karakter');
        expect(validResult, isNull);
      });

      test('validateLengthRange should validate length range correctly', () {
        // Act
        final emptyError = ValidationUtils.validateLengthRange('', 3, 10);
        final shortError = ValidationUtils.validateLengthRange('Hi', 3, 10);
        final longError = ValidationUtils.validateLengthRange('Very long text here', 3, 10);
        final validResult = ValidationUtils.validateLengthRange('Hello', 3, 10);

        // Assert
        expect(emptyError, 'Field ini wajib diisi');
        expect(shortError, 'Harus 3-10 karakter');
        expect(longError, 'Harus 3-10 karakter');
        expect(validResult, isNull);
      });
    });

    group('App-Specific Validation', () {
      test('validateChildName should validate child name correctly', () {
        // Act
        final emptyError = ValidationUtils.validateChildName('');
        final shortError = ValidationUtils.validateChildName('A');
        final longError = ValidationUtils.validateChildName('A' * 51);
        final validResult = ValidationUtils.validateChildName('Fjola');

        // Assert
        expect(emptyError, 'Nama anak wajib diisi');
        expect(shortError, 'Nama minimal 2 karakter');
        expect(longError, 'Nama maksimal 50 karakter');
        expect(validResult, isNull);
      });

      test('validateScheduleTitle should validate schedule title correctly', () {
        // Act
        final emptyError = ValidationUtils.validateScheduleTitle('');
        final shortError = ValidationUtils.validateScheduleTitle('AB');
        final longError = ValidationUtils.validateScheduleTitle('A' * 101);
        final validResult = ValidationUtils.validateScheduleTitle('Vaksinasi BCG');

        // Assert
        expect(emptyError, 'Judul jadwal wajib diisi');
        expect(shortError, 'Judul minimal 3 karakter');
        expect(longError, 'Judul maksimal 100 karakter');
        expect(validResult, isNull);
      });

      test('validateJournalEntry should validate journal entry correctly', () {
        // Act
        final emptyError = ValidationUtils.validateJournalEntry('');
        final shortError = ValidationUtils.validateJournalEntry('Short');
        final longError = ValidationUtils.validateJournalEntry('A' * 501);
        final validResult = ValidationUtils.validateJournalEntry('Hari ini Fjola mulai belajar merangkak!');

        // Assert
        expect(emptyError, 'Catatan jurnal wajib diisi');
        expect(shortError, 'Catatan minimal 10 karakter');
        expect(longError, 'Catatan maksimal 500 karakter');
        expect(validResult, isNull);
      });

      test('validatePhotoCaption should validate photo caption correctly', () {
        // Act
        final emptyResult = ValidationUtils.validatePhotoCaption('');
        final nullResult = ValidationUtils.validatePhotoCaption(null);
        final longError = ValidationUtils.validatePhotoCaption('A' * 201);
        final validResult = ValidationUtils.validatePhotoCaption('Fjola tersenyum');

        // Assert
        expect(emptyResult, isNull); // Caption is optional
        expect(nullResult, isNull);
        expect(longError, 'Keterangan maksimal 200 karakter');
        expect(validResult, isNull);
      });
    });

    group('Utility Functions', () {
      test('sanitize should clean up input strings', () {
        // Act
        final result1 = ValidationUtils.sanitize('  Hello   World  ');
        final result2 = ValidationUtils.sanitize('Text  with   spaces');
        final result3 = ValidationUtils.sanitize(null);

        // Assert
        expect(result1, 'Hello World');
        expect(result2, 'Text with spaces');
        expect(result3, '');
      });

      test('containsProfanity should detect profanity', () {
        // Act
        final clean = ValidationUtils.containsProfanity('Hello world');
        final profane = ValidationUtils.containsProfanity('badword1');
        final empty = ValidationUtils.containsProfanity('');
        final nullValue = ValidationUtils.containsProfanity(null);

        // Assert
        expect(clean, false);
        expect(profane, true);
        expect(empty, false);
        expect(nullValue, false);
      });
    });
  });
}