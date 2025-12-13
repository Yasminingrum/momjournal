/// Domain entity for mood tracking in journal entries
/// 
/// This file defines the MoodType enum and related utilities for
/// representing and working with user moods in the journaling feature.
library;

/// Enum representing different mood types available in the app
/// 
/// Used for mood tracking in journal entries to help mothers
/// monitor their emotional well-being over time.
enum MoodType {
  /// Very happy, excellent mood
  veryHappy,
  
  /// Happy, good mood
  happy,
  
  /// Neutral, neither happy nor sad
  neutral,
  
  /// Sad, low mood
  sad,
  
  /// Very sad, poor mood
  verySad,
}

/// Extension on MoodType to add utility methods and properties
extension MoodTypeExtension on MoodType {
  /// Returns emoji representation of the mood
  String get emoji {
    switch (this) {
      case MoodType.veryHappy:
        return '😄';
      case MoodType.happy:
        return '🙂';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😔';
      case MoodType.verySad:
        return '😢';
    }
  }

  /// Returns display label for the mood
  String get label {
    switch (this) {
      case MoodType.veryHappy:
        return 'Sangat Senang';
      case MoodType.happy:
        return 'Senang';
      case MoodType.neutral:
        return 'Biasa Saja';
      case MoodType.sad:
        return 'Sedih';
      case MoodType.verySad:
        return 'Sangat Sedih';
    }
  }

  /// Returns color representation as hex string
  /// Used for charts and mood indicators
  String get colorHex {
    switch (this) {
      case MoodType.veryHappy:
        return '#4CAF50'; // Green
      case MoodType.happy:
        return '#8BC34A'; // Light Green
      case MoodType.neutral:
        return '#FFC107'; // Amber
      case MoodType.sad:
        return '#FF9800'; // Orange
      case MoodType.verySad:
        return '#F44336'; // Red
    }
  }

  /// Returns numeric value for mood (for trending/analytics)
  /// Higher value = better mood
  int get numericValue {
    switch (this) {
      case MoodType.veryHappy:
        return 5;
      case MoodType.happy:
        return 4;
      case MoodType.neutral:
        return 3;
      case MoodType.sad:
        return 2;
      case MoodType.verySad:
        return 1;
    }
  }

  /// Converts MoodType to string for storage
  String toJson() => name;
}

/// Helper class for MoodType conversions
class MoodHelper {
  /// Converts string to MoodType
  /// 
  /// Returns null if string doesn't match any mood type
  static MoodType? fromString(String? value) {
    if (value == null) {
      return null;
    }
    
    try {
      return MoodType.values.firstWhere(
        (mood) => mood.name == value,
      );
    } catch (e) {
      return null;
    }
  }

  /// Converts string to MoodType with fallback
  /// 
  /// Returns [defaultMood] if string doesn't match any mood type
  static MoodType fromStringOrDefault(
    String? value, {
    MoodType defaultMood = MoodType.neutral,
  }) => fromString(value) ?? defaultMood;

  /// Gets all available mood types
  static List<MoodType> get allMoods => MoodType.values;

  /// Calculates average mood from a list of moods
  /// 
  /// Returns null if list is empty
  static double? calculateAverageMood(List<MoodType> moods) {
    if (moods.isEmpty) {
      return null;
    }
    
    final sum = moods.fold<int>(
      0,
      (sum, mood) => sum + mood.numericValue,
    );
    
    return sum / moods.length;
  }

  /// Gets mood from numeric value
  /// 
  /// Rounds to nearest integer and maps to corresponding mood
  static MoodType fromNumericValue(int value) {
    // Clamp value between 1 and 5
    final clampedValue = value.clamp(1, 5);
    
    switch (clampedValue) {
      case 5:
        return MoodType.veryHappy;
      case 4:
        return MoodType.happy;
      case 3:
        return MoodType.neutral;
      case 2:
        return MoodType.sad;
      case 1:
      default:
        return MoodType.verySad;
    }
  }

  /// Gets mood trend description from average
  /// 
  /// Returns human-readable description of mood trend
  static String getMoodTrendDescription(double? averageMood) {
    if (averageMood == null) {
      return 'Belum ada data';
    }
    
    if (averageMood >= 4.5) {
      return 'Mood Anda sangat baik!';
    } else if (averageMood >= 3.5) {
      return 'Mood Anda cukup baik';
    } else if (averageMood >= 2.5) {
      return 'Mood Anda biasa saja';
    } else if (averageMood >= 1.5) {
      return 'Mood Anda kurang baik';
    } else {
      return 'Mood Anda perlu perhatian';
    }
  }
}