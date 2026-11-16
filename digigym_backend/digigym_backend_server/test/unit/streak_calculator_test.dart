import 'package:digigym_backend_server/src/workout/streak_calculator.dart';
import 'package:test/test.dart';

void main() {
  int after(int? streak, String? last, String today) =>
      StreakCalculator.afterCompletion(
        currentStreak: streak,
        lastCompletedDate: last,
        today: today,
      );

  test('first workout starts a streak at 1', () {
    expect(after(null, null, '2026-11-10'), 1);
  });

  test('same-day completions do not increase the streak', () {
    expect(after(3, '2026-11-10', '2026-11-10'), 3);
  });

  test('consecutive day adds one, including across month/year ends', () {
    expect(after(3, '2026-11-09', '2026-11-10'), 4);
    expect(after(5, '2026-12-31', '2027-01-01'), 6);
    expect(after(2, '2028-02-28', '2028-02-29'), 3);
  });

  test('a missed day restarts at 1', () {
    expect(after(7, '2026-11-08', '2026-11-10'), 1);
  });

  test('visible streak is 0 once a day is missed', () {
    int visible(String last, String today) => StreakCalculator.visibleStreak(
      currentStreak: 4,
      lastCompletedDate: last,
      today: today,
    );
    expect(visible('2026-11-10', '2026-11-10'), 4);
    expect(visible('2026-11-09', '2026-11-10'), 4);
    expect(visible('2026-11-08', '2026-11-10'), 0);
  });

  test('rejects malformed or impossible dates', () {
    expect(() => StreakCalculator.parseDay('11/10/2026'), throwsArgumentError);
    expect(() => StreakCalculator.parseDay('2026-02-30'), throwsArgumentError);
  });
}
