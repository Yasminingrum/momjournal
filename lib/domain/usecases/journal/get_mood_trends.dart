/// Get Mood Trends Use Case
/// 
/// Use case untuk analisis mood trends dari journals
/// Location: lib/domain/usecases/journal/get_mood_trends.dart

import '../../../data/repositories/journal_repository.dart';
import '../../entities/journal_entity.dart';

/// Mood trend data
class MoodTrendData {
  final DateTime date;
  final Mood mood;
  final int moodValue; // 1-5 untuk charting

  MoodTrendData({
    required this.date,
    required this.mood,
    required this.moodValue,
  });
}

/// Mood statistics
class MoodStatistics {
  final Map<Mood, int> moodCounts;
  final Mood? mostFrequentMood;
  final double averageMoodValue;
  final List<MoodTrendData> trendData;

  MoodStatistics({
    required this.moodCounts,
    required this.mostFrequentMood,
    required this.averageMoodValue,
    required this.trendData,
  });
}

class GetMoodTrendsUseCase {
  final JournalRepository repository;

  GetMoodTrendsUseCase(this.repository);

  /// Get mood trends for date range
  Future<MoodStatistics> execute({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final journals = await repository.getJournalsByDateRange(
        startDate,
        endDate,
      );

      if (journals.isEmpty) {
        return MoodStatistics(
          moodCounts: {},
          mostFrequentMood: null,
          averageMoodValue: 0,
          trendData: [],
        );
      }

      // Calculate mood counts
      final moodCounts = <Mood, int>{};
      for (var journal in journals) {
        moodCounts[journal.mood] = (moodCounts[journal.mood] ?? 0) + 1;
      }

      // Find most frequent mood
      Mood? mostFrequentMood;
      int maxCount = 0;
      moodCounts.forEach((mood, count) {
        if (count > maxCount) {
          maxCount = count;
          mostFrequentMood = mood;
        }
      });

      // Calculate average mood value
      final totalMoodValue = journals.fold<int>(
        0,
        (sum, journal) => sum + _getMoodValue(journal.mood),
      );
      final averageMoodValue = totalMoodValue / journals.length;

      // Create trend data
      final trendData = journals.map((journal) {
        return MoodTrendData(
          date: journal.date,
          mood: journal.mood,
          moodValue: _getMoodValue(journal.mood),
        );
      }).toList();

      // Sort by date
      trendData.sort((a, b) => a.date.compareTo(b.date));

      print('✅ UseCase: Calculated mood trends for ${journals.length} journals');

      return MoodStatistics(
        moodCounts: moodCounts,
        mostFrequentMood: mostFrequentMood,
        averageMoodValue: averageMoodValue,
        trendData: trendData,
      );
    } catch (e) {
      print('❌ UseCase: Failed to get mood trends: $e');
      rethrow;
    }
  }

  /// Get mood trends for last N days
  Future<MoodStatistics> executeForLastDays(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    return execute(startDate: startDate, endDate: endDate);
  }

  /// Get mood trends for current week
  Future<MoodStatistics> executeForWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
    
    return execute(startDate: startOfWeek, endDate: endOfWeek);
  }

  /// Get mood trends for current month
  Future<MoodStatistics> executeForMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return execute(startDate: startOfMonth, endDate: endOfMonth);
  }

  /// Convert mood to numeric value (1-5)
  int _getMoodValue(Mood mood) {
    switch (mood) {
      case Mood.veryHappy:
        return 5;
      case Mood.happy:
        return 4;
      case Mood.neutral:
        return 3;
      case Mood.sad:
        return 2;
      case Mood.verySad:
        return 1;
    }
  }
}