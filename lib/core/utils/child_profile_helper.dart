// ignore_for_file: lines_longer_than_80_chars

library;

import 'package:flutter/material.dart';

import '../../data/datasources/local/hive_database.dart';

/// Helper class untuk mengakses dan menampilkan informasi child profile
/// 
/// Menyediakan utility functions yang reusable di seluruh aplikasi
class ChildProfileHelper {
  ChildProfileHelper._();

  /// Get child name dari Hive UserModel
  /// Returns 'Si Kecil' jika belum diisi
  /// Get child name dari Hive UserModel
  /// Returns 'Si Kecil' jika belum diisi
  static String getChildName(String? userId) {
    debugPrint('🔍 getChildName called for userId: $userId');
    
    if (userId == null) {
      debugPrint('⚠️ userId is null, returning default');
      return 'Si Kecil';
    }
    
    try {
      final hiveDb = HiveDatabase();
      final user = hiveDb.userBox.get(userId);
      final name = user?.childName ?? 'Si Kecil';
      
      debugPrint('📦 Retrieved from Hive: "$name" (raw: ${user?.childName})');
      return name;
    } catch (e) {
      debugPrint('❌ Error getting child name: $e');
      return 'Si Kecil';
    }
  }

  /// Get child birth date dari Hive UserModel
  static DateTime? getChildBirthDate(String? userId) {
    if (userId == null) {
      return null;
    }
    
    try {
      final hiveDb = HiveDatabase();
      final user = hiveDb.userBox.get(userId);
      return user?.childBirthDate;
    } catch (e) {
      debugPrint('Error getting child birth date: $e');
      return null;
    }
  }

  /// Get child gender dari Hive UserModel
  static String? getChildGender(String? userId) {
    if (userId == null) {
      return null;
    }
    
    try {
      final hiveDb = HiveDatabase();
      final user = hiveDb.userBox.get(userId);
      return user?.childGender;
    } catch (e) {
      debugPrint('Error getting child gender: $e');
      return null;
    }
  }

  /// Calculate child age in months
  static int? getChildAgeInMonths(String? userId) {
    final birthDate = getChildBirthDate(userId);
    if (birthDate == null) {
      return null;
    }

    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12;
    months += now.month - birthDate.month;
    
    if (now.day < birthDate.day) {
      months--;
    }
    
    return months;
  }

  /// Calculate child age in years
  static int? getChildAgeInYears(String? userId) {
    final birthDate = getChildBirthDate(userId);
    if (birthDate == null) {
      return null;
    }

    final now = DateTime.now();
    int years = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    
    return years;
  }

  /// Get formatted child age string
  /// Examples:
  /// - "2 bulan"
  /// - "1 tahun 3 bulan"
  /// - "Baru lahir"
  static String getChildAgeString(String? userId) {
    final birthDate = getChildBirthDate(userId);
    if (birthDate == null) {
      return '';
    }

    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      // Add days from previous month
      final prevMonth = DateTime(now.year, now.month - 1, birthDate.day);
      days = now.difference(prevMonth).inDays;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    // Baru lahir (< 1 month)
    if (years == 0 && months == 0) {
      if (days == 0) {
        return 'Baru lahir';
      } else if (days == 1) {
        return '1 hari';
      } else {
        return '$days hari';
      }
    }

    // < 1 year
    if (years == 0) {
      return '$months bulan';
    }

    // >= 1 year
    if (months > 0) {
      return '$years tahun $months bulan';
    }
    
    return '$years tahun';
  }

  /// Get gender display string (Indonesian)
  static String getGenderDisplay(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'boy':
        return 'Laki-laki';
      case 'girl':
        return 'Perempuan';
      default:
        return '';
    }
  }

  /// Get gender icon
  static IconData getGenderIcon(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'boy':
        return Icons.boy;
      case 'girl':
        return Icons.girl;
      default:
        return Icons.child_care;
    }
  }

  /// Get greeting based on time of day
  static String getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return 'Selamat pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore';
    } else {
      return 'Selamat malam';
    }
  }

  /// Get personalized greeting with child name
  /// Example: "Selamat pagi, Ibu dari Emyr!"
  static String getPersonalizedGreeting(String? userId) {
    final greeting = getTimeOfDayGreeting();
    final childName = getChildName(userId);
    
    return '$greeting, Ibu dari $childName!';
  }

  /// Check if child profile is complete
  static bool isProfileComplete(String? userId) {
    if (userId == null) {
      return false;
    }
    
    try {
      final hiveDb = HiveDatabase();
      final user = hiveDb.userBox.get(userId);
      
      // Check both fields are not null AND not empty
      final hasName = user?.childName != null && 
                      user!.childName!.isNotEmpty &&
                      user.childName != 'Si Kecil';
      final hasBirthDate = user?.childBirthDate != null;
      
      return hasName && hasBirthDate;
    } catch (e) {
      debugPrint('❌ Error checking profile completion: $e');
      return false;
    }
  }

  /// Get child age at specific date (for journals, photos)
  static String getChildAgeAtDate(String? userId, DateTime date) {
    final birthDate = getChildBirthDate(userId);
    if (birthDate == null) {
      return '';
    }

    // Don't show age if date is before birth
    if (date.isBefore(birthDate)) {
      return '';
    }

    int years = date.year - birthDate.year;
    int months = date.month - birthDate.month;
    final int days = date.day - birthDate.day;

    if (days < 0) {
      months--;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    // < 1 month
    if (years == 0 && months == 0) {
      final daysDiff = date.difference(birthDate).inDays;
      if (daysDiff == 0) {
        return 'Baru lahir';
      }
      if (daysDiff == 1) {
        return '1 hari';
      }
      return '$daysDiff hari';
    }

    // < 1 year
    if (years == 0) {
      return '$months bulan';
    }

    // >= 1 year
    if (months > 0) {
      return '$years tahun $months bulan';
    }
    
    return '$years tahun';
  }
}