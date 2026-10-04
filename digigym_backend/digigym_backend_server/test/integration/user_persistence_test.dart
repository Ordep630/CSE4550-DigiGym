import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'package:digigym_backend_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('User profile persistence', (sessionBuilder, endpoints) {
    test(
      'retrieves and updates the authenticated user profile',
      () async {
        final session = sessionBuilder.build();

        /* Create AuthUser that would create during registration.
         */
        final authUser = await AuthUser.db.insertRow(
          session,
          AuthUser(
            scopeNames: {'user'},
          ),
        );

        final authUserId = authUser.id!;

        /* Create the DigiGymUser profile that FIT-22 creates
        * through onAfterAuthUserCreated.
        */
        final profile = await DigiGymUser.db.insertRow(
          session,
          DigiGymUser(
            authUserId: authUserId,
            name: 'Test User',
            age: 20,
            height: 170,
            weight: 70,
            fitnessLevel: 'Beginner',
            fitnessGoal: 'Lose Weight',
            workoutTime: 30,
            dietaryPreference: 'No Preference',
            bodyType: 'Average',
          ),
        );

        expect(profile.authUserId, authUserId);

        /* Simulate the AuthUser being authenticated.
         */
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUserId.toString(),
            {Scope('user')},
          ),
        );

        /* Verify the authenticated user can retrieve their profile.
         */
        final fetched = await endpoints.profile.getMyProfile(
          authenticatedSession,
        );

        expect(fetched, isNotNull);
        expect(fetched!.authUserId, authUserId);
        expect(fetched.name, 'Test User');
        expect(fetched.age, 20);
        expect(fetched.fitnessLevel, 'Beginner');
        expect(fetched.fitnessGoal, 'Lose Weight');

        /* Update the authenticated user's profile.
         */
        final updated = await endpoints.profile.updateMyProfile(
          authenticatedSession,
          'Updated User',
          21,
          171.0,
          71.0,
          'Intermediate',
          'Build Muscle',
          45,
          'Vegetarian',
          'Average',
        );

        expect(updated.authUserId, authUserId);
        expect(updated.name, 'Updated User');
        expect(updated.age, 21);
        expect(updated.fitnessLevel, 'Intermediate');
        expect(updated.fitnessGoal, 'Build Muscle');

        /* Verify the changes persisted.
         */
        final fetchedAgain = await endpoints.profile.getMyProfile(
          authenticatedSession,
        );

        expect(fetchedAgain, isNotNull);
        expect(fetchedAgain!.authUserId, authUserId);
        expect(fetchedAgain.name, 'Updated User');
        expect(fetchedAgain.age, 21);
        expect(fetchedAgain.height, 171.0);
        expect(fetchedAgain.weight, 71.0);
        expect(fetchedAgain.fitnessLevel, 'Intermediate');
        expect(fetchedAgain.fitnessGoal, 'Build Muscle');
        expect(fetchedAgain.workoutTime, 45);
        expect(fetchedAgain.dietaryPreference, 'Vegetarian');
        expect(fetchedAgain.bodyType, 'Average');
      },
    );
  });
}
