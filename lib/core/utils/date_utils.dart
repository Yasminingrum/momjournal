import 'package:intl/intl.dart';

/// Date Utilities
/// Helper functions for date formatting and manipulation
class DateUtils {
  // Date Formatters
  static final DateFormat _displayFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _shortFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _fullFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM', 'id_ID');
  
  /// Format date to display format (e.g., "08 Desember 2024")
  static String formatDisplay(DateTime date) {
    return _displayFormat.format(date);
  }
  
  /// Format date to short format (e.g., "08/12/2024")
  static String formatShort(DateTime date) {
    return _shortFormat.format(date);
  }
  
  /// Format time (e.g., "14:30")
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }
  
  /// Format date and time (e.g., "08/12/2024 14:30")
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
  
  /// Format to full format (e.g., "Minggu, 08 Desember 2024")
  static String formatFull(DateTime date) {
    return _fullFormat.format(date);
  }
  
  /// Format to month and year (e.g., "Desember 2024")
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }
  
  /// Format to day and month (e.g., "08 Des")
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
  
  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }
  
  /// Check if date is in current week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  /// Check if date is in current month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  /// Get relative date string (e.g., "Hari ini", "Kemarin", "2 hari yang lalu")
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Hari ini';
    } else if (isYesterday(date)) {
      return 'Kemarin';
    } else if (isTomorrow(date)) {
      return 'Besok';
    }
    
    final difference = DateTime.now().difference(date);
    
    if (difference.inDays < 7 && difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 0 && difference.inDays > -7) {
      return '${-difference.inDays} hari lagi';
    }
    
    return formatDisplay(date);
  }
  
  /// Get relative time string (e.g., "Baru saja", "5 menit yang lalu")
  static String getRelativeTimeString(DateTime date) {
    final difference = DateTime.now().difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    }
    
    return formatDisplay(date);
  }
  
  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - DateTime.monday;
    return startOfDay(date.subtract(Duration(days: daysToSubtract)));
  }
  
  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToAdd = DateTime.sunday - date.weekday;
    return endOfDay(date.add(Duration(days: daysToAdd)));
  }
  
  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = date.month == 12 
        ? DateTime(date.year + 1, 1, 1) 
        : DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }
  
  /// Get days in month
  static int daysInMonth(DateTime date) {
    return endOfMonth(date).day;
  }
  
  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }
  
  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
  
  /// Get age in years from birth date
  static int getAgeInYears(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
  
  /// Get age in months from birth date
  static int getAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12;
    months += now.month - birthDate.month;
    
    if (now.day < birthDate.day) {
      months--;
    }
    
    return months;
  }
  
  /// Get age string (e.g., "1 tahun 3 bulan" or "8 bulan")
  static String getAgeString(DateTime birthDate) {
    final years = getAgeInYears(birthDate);
    final months = getAgeInMonths(birthDate) % 12;
    
    if (years > 0) {
      if (months > 0) {
        return '$years tahun $months bulan';
      }
      return '$years tahun';
    }
    
    return '$months bulan';
  }
  
  /// Parse date from string
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Get list of dates between two dates
  static List<DateTime> getDatesBetween(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = startOfDay(start);
    final endDate = startOfDay(end);
    
    while (current.isBefore(endDate) || isSameDay(current, endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }
  
  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
  
  /// Combine date and time
  static DateTime combineDateTime(DateTime date, DateTime time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
    );
  }
  
  /// Get time difference in readable format
  static String getTimeDifference(DateTime from, DateTime to) {
    final difference = to.difference(from);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} hari';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit';
    } else {
      return '${difference.inSeconds} detik';
    }
  }
  
  // Private constructor to prevent instantiation
  DateUtils._();
}