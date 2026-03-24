// lib/core/utils/dev_config.dart
// Central dev mode configuration.
// Flip DEV_MODE to false when going to production with real live data.

class DevConfig {
  DevConfig._();

  /// Set to true while using seeded Nov 2024 mock data in Firestore.
  /// Set to false when school is live and using real current dates.
  static const bool DEV_MODE = true;

  /// Toggle between Local Mock Data and Live Firestore DB.
  /// Set to true to fetch from Firestore, false for local JSON.
  static const bool USE_FIRESTORE = true;

  /// The date all seeded attendance/homework/timetable data exists for.
  static const String DEV_DATE = '2024-11-20';
  static const int DEV_MONTH = 11;
  static const int DEV_YEAR = 2024;
  static const String DEV_DAY_NAME = 'wednesday';

  /// Returns today's date string OR dev date if DEV_MODE is on.
  static String effectiveDate() {
    if (DEV_MODE) return DEV_DATE;
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Returns the month to show attendance for.
  static int effectiveMonth() => DEV_MODE ? DEV_MONTH : DateTime.now().month;
  static int effectiveYear() => DEV_MODE ? DEV_YEAR : DateTime.now().year;

  /// Returns the weekday name for timetable lookup.
  static String effectiveDayName() {
    if (DEV_MODE) return DEV_DAY_NAME;
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[DateTime.now().weekday - 1];
  }

  /// Formats a date string for display.
  static String formatDisplayDate() {
    if (DEV_MODE) return 'Wed, 20 Nov 2024';
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  /// Full date label for AppBar subtitle.
  static String fullDateLabel() {
    if (DEV_MODE) return 'Wednesday, 20 November 2024';
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
