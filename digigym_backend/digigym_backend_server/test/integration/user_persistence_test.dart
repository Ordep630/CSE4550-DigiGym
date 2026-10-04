import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('User profile persistence', (sessionBuilder, endpoints) {
    test(
      'creates, retrieves, and updates the authenticated user profile',
      () async {
        final session = sessionBuilder.build();

        // Create a real AuthUser so the DigiGymUser foreign key is valid.
        final authUser = await AuthUser.db.insertRow(
          session,
          AuthUser(
            scopeNames: {'user'},
          ),
        );

        final authUserId = authUser.id!;

        // Simulate this AuthUser being authenticated.
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUserId.toString(),
            {Scope('user')},
          ),
        );

        final created = await endpoints.profile.createMyProfile(
          authenticatedSession,
          'Test User',
          25,
          175.0,
          75.0,
          'beginner',
          'strength',
          45,
          'none',
          'average',
        );

        expect(created.authUserId, authUserId);
        expect(created.name, 'Test User');
        expect(created.fitnessGoal, 'strength');

        final fetched = await endpoints.profile.getMyProfile(
          authenticatedSession,
        );

        expect(fetched, isNotNull);
        expect(fetched!.authUserId, authUserId);
        expect(fetched.name, 'Test User');
        expect(fetched.fitnessGoal, 'strength');

        final updated = await endpoints.profile.updateMyProfile(
          authenticatedSession,
          'Updated User',
          26,
          176.0,
          76.0,
          'intermediate',
          'muscle_gain',
          60,
          'vegetarian',
          'athletic',
        );

        expect(updated.authUserId, authUserId);
        expect(updated.name, 'Updated User');
        expect(updated.age, 26);
        expect(updated.fitnessGoal, 'muscle_gain');

        final fetchedAgain = await endpoints.profile.getMyProfile(
          authenticatedSession,
        );

        expect(fetchedAgain, isNotNull);
        expect(fetchedAgain!.authUserId, authUserId);
        expect(fetchedAgain.name, 'Updated User');
        expect(fetchedAgain.age, 26);
        expect(fetchedAgain.height, 176.0);
        expect(fetchedAgain.weight, 76.0);
        expect(fetchedAgain.fitnessLevel, 'intermediate');
        expect(fetchedAgain.fitnessGoal, 'muscle_gain');
        expect(fetchedAgain.workoutTime, 60);
        expect(fetchedAgain.dietaryPreference, 'vegetarian');
        expect(fetchedAgain.bodyType, 'athletic');
      },
    );
  });
}
