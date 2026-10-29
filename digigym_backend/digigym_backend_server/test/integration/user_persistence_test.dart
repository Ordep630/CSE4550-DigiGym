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
            fitnessLevel: FitnessLevel.beginner,
            fitnessGoal: FitnessGoal.loseWeight,
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
        expect(fetched.fitnessLevel, FitnessLevel.beginner);
        expect(fetched.fitnessGoal, FitnessGoal.loseWeight);

        /* Update the authenticated user's profile.
         */
        final updated = await endpoints.profile.updateMyProfile(
          authenticatedSession,
          'Updated User',
          21,
          171.0,
          71.0,
          FitnessLevel.intermediate,
          FitnessGoal.buildMuscle,
          45,
          'Vegetarian',
          'Average',
        );

        expect(updated.authUserId, authUserId);
        expect(updated.name, 'Updated User');
        expect(updated.age, 21);
        expect(updated.fitnessLevel, FitnessLevel.intermediate);
        expect(updated.fitnessGoal, FitnessGoal.buildMuscle);

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
        expect(fetchedAgain.fitnessLevel, FitnessLevel.intermediate);
        expect(fetchedAgain.fitnessGoal, FitnessGoal.buildMuscle);
        expect(fetchedAgain.workoutTime, 45);
        expect(fetchedAgain.dietaryPreference, 'Vegetarian');
        expect(fetchedAgain.bodyType, 'Average');
      },
    );
    test('rejects invalid profile values', () async {
      final session = sessionBuilder.build();

      final authUser = await AuthUser.db.insertRow(
        session,
        AuthUser(
          scopeNames: {'user'},
        ),
      );

      final authUserId = authUser.id!;

      await DigiGymUser.db.insertRow(
        session,
        DigiGymUser(
          authUserId: authUserId,
          name: 'Test User',
          age: 20,
          height: 170,
          weight: 70,
          fitnessLevel: FitnessLevel.beginner,
          fitnessGoal: FitnessGoal.loseWeight,
          workoutTime: 30,
          dietaryPreference: 'No Preference',
          bodyType: 'Average',
        ),
      );

      final authenticatedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUserId.toString(),
          {Scope('user')},
        ),
      );

      Future<void> expectInvalidProfile({
        String name = 'Test User',
        int age = 20,
        double height = 170,
        double weight = 70,
        int workoutTime = 30,
      }) async {
        await expectLater(
          endpoints.profile.updateMyProfile(
            authenticatedSession,
            name,
            age,
            height,
            weight,
            FitnessLevel.beginner,
            FitnessGoal.loseWeight,
            workoutTime,
            'No Preference',
            'Average',
          ),
          throwsArgumentError,
        );
      }
      // Empty or whitespace-only names must be rejected.
      await expectInvalidProfile(name: '');
      await expectInvalidProfile(name: '   ');

      // Ages outside the allowed 13–100 range must be rejected.
      await expectInvalidProfile(age: 12);
      await expectInvalidProfile(age: 101);

      // Heights outside the allowed 50–275 cm range must be rejected.
      await expectInvalidProfile(height: 49);
      await expectInvalidProfile(height: 276);

      // Weights outside the allowed 20–500 kg range must be rejected.
      await expectInvalidProfile(weight: 19);
      await expectInvalidProfile(weight: 501);

      // Workout durations outside the allowed 1–300 minute range must be rejected.
      await expectInvalidProfile(workoutTime: 0);
      await expectInvalidProfile(workoutTime: 301);
    });
    test('accepts age boundaries of 13 and 100', () async {
      final session = sessionBuilder.build();

      final authUser = await AuthUser.db.insertRow(
        session,
        AuthUser(
          scopeNames: {'user'},
        ),
      );

      final authUserId = authUser.id!;

      await DigiGymUser.db.insertRow(
        session,
        DigiGymUser(
          authUserId: authUserId,
          name: 'Test User',
          age: 20,
          height: 170,
          weight: 70,
          fitnessLevel: FitnessLevel.beginner,
          fitnessGoal: FitnessGoal.loseWeight,
          workoutTime: 30,
          dietaryPreference: 'No Preference',
          bodyType: 'Average',
        ),
      );

      final authenticatedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUserId.toString(),
          {Scope('user')},
        ),
      );

      for (final age in [13, 100]) {
        final updated = await endpoints.profile.updateMyProfile(
          authenticatedSession,
          'Test User',
          age,
          170,
          70,
          FitnessLevel.beginner,
          FitnessGoal.loseWeight,
          30,
          'No Preference',
          'Average',
        );

        expect(updated.age, age);
      }
    });
  });
}
