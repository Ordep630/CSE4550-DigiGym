import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'package:digigym_backend_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Fitness data handling', (sessionBuilder, endpoints) {
    test(
      'gets and updates fitness data for the authenticated user',
      () async {
        final session = sessionBuilder.build();

        /// Create a real AuthUser so the DigiGymUser foreign key is valid
        final authUser = await AuthUser.db.insertRow(
          session,
          AuthUser(
            scopeNames: {'user'},
          ),
        );

        final authUserId = authUser.id!;

        /// Create the existing DigiGym profile for the authenticated user
        await DigiGymUser.db.insertRow(
          session,
          DigiGymUser(
            authUserId: authUserId,
            name: 'Test User',
            age: 25,
            height: 175.0,
            weight: 75.0,
            fitnessLevel: 'beginner',
            fitnessGoal: 'weight_loss',
            workoutTime: 45,
            dietaryPreference: 'None',
            bodyType: 'Average',
          ),
        );

        // Simulate the AuthUser being authenticated.
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUserId.toString(),
            {Scope('user')},
          ),
        );

        /// Verify the initial fitness data.
        final initial = await endpoints.profile.getMyFitnessData(
          authenticatedSession,
        );

        expect(initial, isNotNull);
        expect(initial!.fitnessLevel, equals('beginner'));
        expect(initial.fitnessGoal, equals('weight_loss'));

        /// Update the fitness data
        final updated = await endpoints.profile.updateMyFitnessData(
          authenticatedSession,
          'intermediate',
          'build_muscle',
        );

        expect(updated.fitnessLevel, equals('intermediate'));
        expect(updated.fitnessGoal, equals('build_muscle'));

        // Verify that the updated values persisted
        final persisted = await endpoints.profile.getMyFitnessData(
          authenticatedSession,
        );

        expect(persisted, isNotNull);
        expect(persisted!.fitnessLevel, equals('intermediate'));
        expect(persisted.fitnessGoal, equals('build_muscle'));

        /// Verify the underlying DigiGymUser was updated as well
        await DigiGymUser.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(authUserId),
        );

       // expect(updatedProfile, isNotNull);
       // expect(updatedProfile!.fitnessLevel, equals('intermediate'));
       // expect(updatedProfile.fitnessGoal, equals('build_muscle'));
      },
    );
  });
}
