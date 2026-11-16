import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'streak_calculator.dart';

/// Tracks the authenticated user's consecutive-day workout streak.
class WorkoutStreakEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  UuidValue _userId(Session session) {
    final authUserId = session.authenticated?.authUserId;
    if (authUserId == null) {
      throw StateError('User is not authenticated.');
    }
    return authUserId;
  }

  /// [localDay] is the user's calendar day (yyyy-MM-dd). It must be within a
  /// day of the server's UTC date, which covers every real time zone.
  void _validateDay(String localDay) {
    final day = StreakCalculator.parseDay(localDay);
    final utcToday = DateTime.now().toUtc();
    final utcDay = DateTime.utc(utcToday.year, utcToday.month, utcToday.day);
    if (day.difference(utcDay).inDays.abs() > 1) {
      throw ArgumentError.value(localDay, 'localDay', 'Date is out of range.');
    }
  }

  /// Creates or updates the streak for a completed workout and returns it.
  /// Safe to call repeatedly: extra completions on one day change nothing.
  Future<int> recordCompletion(Session session, String localDay) async {
    final authUserId = _userId(session);
    _validateDay(localDay);

    return session.db.transaction((transaction) async {
      // Lock a row that exists even before the first streak is recorded.
      final account = await AuthUser.db.findById(
        session,
        authUserId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (account == null) throw StateError('User account no longer exists.');

      final existing = await WorkoutStreak.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(authUserId),
        transaction: transaction,
      );

      final next = StreakCalculator.afterCompletion(
        currentStreak: existing?.currentStreak,
        lastCompletedDate: existing?.lastCompletedDate,
        today: localDay,
      );

      // A late/out-of-order date must never move the stored day backwards.
      final lastDay =
          existing != null &&
              StreakCalculator.daysBetween(
                    existing.lastCompletedDate,
                    localDay,
                  ) <
                  0
          ? existing.lastCompletedDate
          : localDay;

      if (existing == null) {
        await WorkoutStreak.db.insertRow(
          session,
          WorkoutStreak(
            authUserId: authUserId,
            currentStreak: next,
            lastCompletedDate: lastDay,
          ),
          transaction: transaction,
        );
      } else {
        await WorkoutStreak.db.updateRow(
          session,
          existing.copyWith(
            currentStreak: next,
            lastCompletedDate: lastDay,
          ),
          transaction: transaction,
        );
      }
      return next;
    });
  }

  /// Current streak as of [localDay]; 0 if none or a day was missed.
  Future<int> getMyStreak(Session session, String localDay) async {
    final authUserId = _userId(session);
    _validateDay(localDay);

    final existing = await WorkoutStreak.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (existing == null) return 0;

    return StreakCalculator.visibleStreak(
      currentStreak: existing.currentStreak,
      lastCompletedDate: existing.lastCompletedDate,
      today: localDay,
    );
  }
}
