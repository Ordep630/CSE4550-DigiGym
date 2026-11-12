import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Manages the authenticated user's weekly workout schedule.
class WorkoutScheduleEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the saved weekdays, or null if no schedule exists.
  Future<List<int>?> getMyWorkoutSchedule(Session session) async {
    final authenticated = session.authenticated;

    if (authenticated == null) {
      throw StateError('User is not authenticated.');
    }

    final authUserId = UuidValue.withValidation(
      authenticated.userIdentifier,
    );

    final schedule = await WorkoutSchedule.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    return schedule?.workoutDays;
  }

  /// Saves or updates the authenticated user's selected weekdays.
  Future<List<int>> updateMyWorkoutSchedule(
    Session session,
    List<int> workoutDays,
  ) async {
    final authenticated = session.authenticated;

    if (authenticated == null) {
      throw StateError('User is not authenticated.');
    }

    final authUserId = UuidValue.withValidation(
      authenticated.userIdentifier,
    );

    if (workoutDays.any((day) => day < 0 || day > 6) ||
        workoutDays.toSet().length != workoutDays.length) {
      throw ArgumentError(
        'Weekdays must be unique values from Sunday (0) through Saturday (6).',
      );
    }

    final orderedDays = workoutDays.toList()..sort();

    final existing = await WorkoutSchedule.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (existing == null) {
      await WorkoutSchedule.db.insertRow(
        session,
        WorkoutSchedule(
          authUserId: authUserId,
          workoutDays: orderedDays,
        ),
      );
    } else {
      await WorkoutSchedule.db.updateRow(
        session,
        existing.copyWith(workoutDays: orderedDays),
      );
    }

    return orderedDays;
  }
}
