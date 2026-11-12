import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class WorkoutHistoryEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<CompletedWorkout> completeWorkout(
    Session session,
    String workoutName,
    int durationMinutes,
    String details,
  ) async {
    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      throw StateError('User is not authenticated.');
    }

    if (workoutName.trim().isEmpty) {
      throw ArgumentError.value(workoutName, 'workoutName');
    }

    if (durationMinutes < 0) {
      throw ArgumentError.value(durationMinutes, 'durationMinutes');
    }

    return CompletedWorkout.db.insertRow(
      session,
      CompletedWorkout(
        authUserId: authUserId,
        workoutName: workoutName.trim(),
        durationMinutes: durationMinutes,
        details: details,
        completedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<List<CompletedWorkout>> getMyWorkoutHistory(
  Session session,
) async {
  final authUserId = session.authenticated?.authUserId;

  if (authUserId == null) {
    throw StateError('User is not authenticated.');
  }

  return CompletedWorkout.db.find(
    session,
    where: (t) => t.authUserId.equals(authUserId),
    orderBy: (t) => t.completedAt.desc(),
  );
}

  Future<int> deleteMyWorkoutHistory(
    Session session,
    List<int> workoutIds,
  ) async {
    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      throw StateError('User is not authenticated.');
    }

    var deletedCount = 0;

    for (final workoutId in workoutIds.toSet()) {
      final workout = await CompletedWorkout.db.findFirstRow(
        session,
        where: (t) =>
            t.id.equals(workoutId) & t.authUserId.equals(authUserId),
      );

      if (workout != null) {
        await CompletedWorkout.db.deleteRow(session, workout);
        deletedCount++;
      }
    }

    return deletedCount;
  }
}