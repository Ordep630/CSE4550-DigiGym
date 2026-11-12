/// Pure streak rules, independent of Serverpod so they are easy to unit test.
///
/// Days are `yyyy-MM-dd` calendar dates in the user's local time zone.
abstract final class StreakCalculator {
  static final _format = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Parses a `yyyy-MM-dd` string; throws [ArgumentError] when malformed.
  static DateTime parseDay(String value) {
    if (!_format.hasMatch(value)) {
      throw ArgumentError.value(value, 'day', 'Expected yyyy-MM-dd.');
    }
    final parsed = DateTime.parse('${value}T00:00:00Z');
    if (parsed.toIso8601String().substring(0, 10) != value) {
      throw ArgumentError.value(value, 'day', 'Not a real calendar date.');
    }
    return parsed;
  }

  static int daysBetween(String from, String to) =>
      parseDay(to).difference(parseDay(from)).inDays;

  /// Streak after a workout is completed on [today].
  ///
  /// First workout starts a streak at 1; another workout the same day changes
  /// nothing; the next consecutive day adds 1; any gap restarts at 1.
  static int afterCompletion({
    required int? currentStreak,
    required String? lastCompletedDate,
    required String today,
  }) {
    parseDay(today);
    if (currentStreak == null || lastCompletedDate == null) return 1;
    final gap = daysBetween(lastCompletedDate, today);
    if (gap <= 0) return currentStreak < 1 ? 1 : currentStreak;
    if (gap == 1) return currentStreak + 1;
    return 1;
  }

  /// Streak to display on [today]: broken (0) once a full day was missed.
  static int visibleStreak({
    required int currentStreak,
    required String lastCompletedDate,
    required String today,
  }) {
    return daysBetween(lastCompletedDate, today) > 1 ? 0 : currentStreak;
  }
}
