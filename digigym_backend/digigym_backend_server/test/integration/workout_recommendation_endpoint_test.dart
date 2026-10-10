import 'package:digigym_backend_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Workout recommendation endpoint',
    (sessionBuilder, endpoints) {
      test(
        'returns a recommendation for the authenticated user',
        () async {
          final session = sessionBuilder.build();

          // Create a real AuthUser for the DigiGymUser foreign key.
          final authUser = await AuthUser.db.insertRow(
            session,
            AuthUser(
              scopeNames: {'user'},
            ),
          );

          final authUserId = authUser.id!;

          // Create the existing DigiGymUser profile.
          await DigiGymUser.db.insertRow(
            session,
            DigiGymUser(
              authUserId: authUserId,
              name: 'Test User',
              age: 25,
              height: 175.0,
              weight: 75.0,
              fitnessLevel: FitnessLevel.beginner,
              fitnessGoal: FitnessGoal.loseWeight,
              workoutTime: 30,
              dietaryPreference: 'none',
              bodyType: 'average',
            ),
          );

          // Simulate the AuthUser being authenticated.
          final authenticatedSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              authUserId.toString(),
              {Scope('user')},
            ),
          );

          final recommendation = await endpoints.workoutRecommendation
              .getMyWorkoutRecommendation(
                authenticatedSession,
              );

          expect(recommendation, isNotNull);
          expect(recommendation!.workoutType, 'cardio');
          expect(recommendation.difficulty, 'beginner');
          expect(recommendation.durationMinutes, 30);
        },
      );
    },
  );
}
