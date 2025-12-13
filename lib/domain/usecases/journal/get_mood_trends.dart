/// Use case for retrieving and analyzing mood trends from journal entries
/// 
/// This use case provides mood analytics and trend analysis to help
/// mothers track their emotional well-being over time.
library;

import '../../../data/repositories/journal_repository.dart';
import '../../entities/journal_entity.dart' hide MoodType;
import '../../entities/mood_entity.dart';

/// Result class containing mood trend analysis data
class MoodTrendResult {

  const MoodTrendResult({
    required this.journals,
    required this.averageMood,
    required this.dominantMood,
    required this.moodDistribution,
    required this.trend,
    required this.totalEntries,
    required this.startDate,
    required this.endDate,
  });
  /// List of journals included in the analysis
  final List<JournalEntity> journals;

  /// Average mood value (1-5 scale)
  final double? averageMood;

  /// Most common mood in the period
  final MoodType? dominantMood;

  /// Distribution of moods (count per mood type)
  final Map<MoodType, int> moodDistribution;

  /// Mood trend direction (improving, stable, declining)
  final MoodTrend trend;

  /// Total number of journal entries analyzed
  final int totalEntries;

  /// Date range of analysis
  final DateTime startDate;
  final DateTime endDate;

  /// Gets trend description in Indonesian
  String get trendDescription {
    switch (trend) {
      case MoodTrend.improving:
        return 'Mood Anda sedang membaik! 📈';
      case MoodTrend.stable:
        return 'Mood Anda cukup stabil 😊';
      case MoodTrend.declining:
        return 'Mood Anda perlu perhatian 📉';
      case MoodTrend.insufficient:
        return 'Data belum cukup untuk analisis';
    }
  }

  /// Gets average mood description
  String get averageMoodDescription => MoodHelper.getMoodTrendDescription(averageMood);

  /// Checks if there's enough data for meaningful analysis
  bool get hasEnoughData => totalEntries >= 3;

  /// Gets percentage for a specific mood
  double getMoodPercentage(MoodType mood) {
    if (totalEntries == 0) {
      return 0;
    }
    final count = moodDistribution[mood] ?? 0;
    return (count / totalEntries) * 100;
  }
}

/// Enum representing mood trend direction
enum MoodTrend {
  /// Mood is improving over time
  improving,

  /// Mood is relatively stable
  stable,

  /// Mood is declining over time
  declining,

  /// Not enough data to determine trend
  insufficient,
}

/// Time period for mood trend analysis
enum TrendPeriod {
  /// Last 7 days
  week,

  /// Last 30 days
  month,

  /// Last 90 days
  quarter,

  /// All time
  allTime,

  /// Custom date range
  custom,
}

extension TrendPeriodExtension on TrendPeriod {
  String get label {
    switch (this) {
      case TrendPeriod.week:
        return '7 Hari Terakhir';
      case TrendPeriod.month:
        return '30 Hari Terakhir';
      case TrendPeriod.quarter:
        return '90 Hari Terakhir';
      case TrendPeriod.allTime:
        return 'Semua Waktu';
      case TrendPeriod.custom:
        return 'Kustom';
    }
  }

  int? get daysBack {
    switch (this) {
      case TrendPeriod.week:
        return 7;
      case TrendPeriod.month:
        return 30;
      case TrendPeriod.quarter:
        return 90;
      case TrendPeriod.allTime:
        return null;
      case TrendPeriod.custom:
        return null;
    }
  }
}

/// Use case for getting mood trends from journal entries
class GetMoodTrends {

  const GetMoodTrends(this._repository);
  final JournalRepository _repository;

  /// Gets mood trend analysis for a specific period
  /// 
  /// [period] - The time period to analyze
  /// [customStartDate] - Start date for custom period (optional)
  /// [customEndDate] - End date for custom period (optional)
  /// 
  /// Returns [MoodTrendResult] with comprehensive mood analysis
  Future<MoodTrendResult> call({
    TrendPeriod period = TrendPeriod.month,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async {
    // Determine date range based on period
    final now = DateTime.now();
    late DateTime startDate;
    late DateTime endDate;

    if (period == TrendPeriod.custom) {
      if (customStartDate == null || customEndDate == null) {
        throw ArgumentError(
          'Custom period requires both start and end dates',
        );
      }
      startDate = customStartDate;
      endDate = customEndDate;
    } else if (period == TrendPeriod.allTime) {
      // Get all journals
      final allJournals = await _repository.getAllJournals();
      if (allJournals.isEmpty) {
        return _emptyResult(
          startDate: DateTime(2000),
          endDate: now,
        );
      }
      
      // Find earliest and latest dates
      startDate = allJournals
          .map((j) => j.createdAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      endDate = now;
    } else {
      final daysBack = period.daysBack!;
      startDate = now.subtract(Duration(days: daysBack));
      endDate = now;
    }

    // Get journals in date range
    final journals = await _repository.getJournalsByDateRange(
      startDate,
      endDate,
    );

    // If no journals, return empty result
    if (journals.isEmpty) {
      return _emptyResult(
        startDate: startDate,
        endDate: endDate,
      );
    }

    // Calculate mood distribution
    final moodDistribution = _calculateMoodDistribution(journals);

    // Calculate average mood
    final moods = journals.map((j) => MoodType.values[j.mood.index]).toList();
    final averageMood = MoodHelper.calculateAverageMood(moods);

    // Find dominant mood
    final dominantMood = _findDominantMood(moodDistribution);

    // Calculate trend
    final trend = _calculateTrend(journals);

    return MoodTrendResult(
      journals: journals,
      averageMood: averageMood,
      dominantMood: dominantMood,
      moodDistribution: moodDistribution,
      trend: trend,
      totalEntries: journals.length,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Gets mood trend for the last week (convenience method)
  Future<MoodTrendResult> getWeeklyTrend() async => call(period: TrendPeriod.week);

  /// Gets mood trend for the last month (convenience method)
  Future<MoodTrendResult> getMonthlyTrend() async => call(period: TrendPeriod.month);

  /// Gets mood trend for the last quarter (convenience method)
  Future<MoodTrendResult> getQuarterlyTrend() async => call(period: TrendPeriod.quarter);

  /// Gets all-time mood trend (convenience method)
  Future<MoodTrendResult> getAllTimeTrend() async => call(period: TrendPeriod.allTime);

  /// Gets mood data for charting (last 30 days with daily averages)
  Future<List<MoodChartData>> getMoodChartData({
    int days = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final journals = await _repository.getJournalsByDateRange(
      startDate,
      endDate,
    );

    // Group journals by date
    final groupedByDate = <DateTime, List<JournalEntity>>{};
    for (final journal in journals) {
      final date = DateTime(
        journal.createdAt.year,
        journal.createdAt.month,
        journal.createdAt.day,
      );
      groupedByDate.putIfAbsent(date, () => []).add(journal);
    }

    // Calculate daily averages
    final chartData = <MoodChartData>[];
    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      final journalsOnDate = groupedByDate[dateKey] ?? [];

      if (journalsOnDate.isNotEmpty) {
        final moods = journalsOnDate.map((j) => MoodType.values[j.mood.index]).toList();
        final average = MoodHelper.calculateAverageMood(moods);
        chartData.add(MoodChartData(
          date: dateKey,
          averageMood: average,
          entryCount: journalsOnDate.length,
        ),);
      } else {
        // No entry for this day
        chartData.add(MoodChartData(
          date: dateKey,
          averageMood: null,
          entryCount: 0,
        ),);
      }
    }

    return chartData;
  }

  // Private helper methods

  MoodTrendResult _emptyResult({
    required DateTime startDate,
    required DateTime endDate,
  }) => MoodTrendResult(
      journals: [],
      averageMood: null,
      dominantMood: null,
      moodDistribution: {},
      trend: MoodTrend.insufficient,
      totalEntries: 0,
      startDate: startDate,
      endDate: endDate,
    );

  Map<MoodType, int> _calculateMoodDistribution(
    List<JournalEntity> journals,
  ) {
    final distribution = <MoodType, int>{};
    
    for (final mood in MoodType.values) {
      distribution[mood] = 0;
    }

    for (final journal in journals) {
      final moodType = MoodType.values[journal.mood.index];
      distribution[moodType] = (distribution[moodType] ?? 0) + 1;
    }

    return distribution;
  }

  MoodType? _findDominantMood(Map<MoodType, int> distribution) {
    if (distribution.isEmpty || distribution.values.every((v) => v == 0)) {
      return null;
    }

    MoodType? dominantMood;
    int maxCount = 0;

    distribution.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMood = mood;
      }
    });

    return dominantMood;
  }

  MoodTrend _calculateTrend(List<JournalEntity> journals) {
    // Need at least 3 entries for trend analysis
    if (journals.length < 3) {
      return MoodTrend.insufficient;
    }

    // Sort journals by date
    final sortedJournals = List<JournalEntity>.from(journals)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Divide into two halves and compare averages
    final midPoint = sortedJournals.length ~/ 2;
    final firstHalf = sortedJournals.sublist(0, midPoint);
    final secondHalf = sortedJournals.sublist(midPoint);

    final firstHalfMoods = firstHalf.map((j) => MoodType.values[j.mood.index]).toList();
    final secondHalfMoods = secondHalf.map((j) => MoodType.values[j.mood.index]).toList();

    final firstAverage = MoodHelper.calculateAverageMood(firstHalfMoods);
    final secondAverage = MoodHelper.calculateAverageMood(secondHalfMoods);

    if (firstAverage == null || secondAverage == null) {
      return MoodTrend.insufficient;
    }

    final difference = secondAverage - firstAverage;

    // Threshold for significant change
    const threshold = 0.3;

    if (difference > threshold) {
      return MoodTrend.improving;
    } else if (difference < -threshold) {
      return MoodTrend.declining;
    } else {
      return MoodTrend.stable;
    }
  }
}

/// Data point for mood chart visualization
class MoodChartData {

  const MoodChartData({
    required this.date,
    required this.averageMood,
    required this.entryCount,
  });
  final DateTime date;
  final double? averageMood;
  final int entryCount;

  /// Checks if there's data for this date
  bool get hasData => averageMood != null && entryCount > 0;
}