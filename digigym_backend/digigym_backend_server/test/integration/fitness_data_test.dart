import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'package:digigym_backend_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Fitness data handling', (sessionBuilder, endpoints) {
    test(
      'gets and updates fitness data using intermediate, buildMuscle',
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

        /// Create DigiGymUser for the authenticated session
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
        expect(initial!.fitnessLevel, FitnessLevel.beginner);
        expect(initial.fitnessGoal, equals(FitnessGoal.loseWeight));

        /// Update the fitness data
        final updated = await endpoints.profile.updateMyFitnessData(
          authenticatedSession,
          FitnessLevel.intermediate,
          FitnessGoal.buildMuscle,
        );

        expect(updated.fitnessLevel, equals(FitnessLevel.intermediate));
        expect(updated.fitnessGoal, equals(FitnessGoal.buildMuscle));

        // Verify that the updated values persisted
        final persisted = await endpoints.profile.getMyFitnessData(
          authenticatedSession,
        );

        expect(persisted, isNotNull);
        expect(persisted!.fitnessLevel, equals(FitnessLevel.intermediate));
        expect(persisted.fitnessGoal, equals(FitnessGoal.buildMuscle));

        /// Verify the underlying DigiGymUser was updated as well
        final verify = await DigiGymUser.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(authUserId),
        );
        expect(verify, isNotNull);
        expect(verify!.fitnessLevel, equals(FitnessLevel.intermediate));
        expect(verify.fitnessGoal, equals(FitnessGoal.buildMuscle));
      },
    );
    test(
      'updates the user fitness data using advanced, maintainWeight',
      () async {
        final session = sessionBuilder.build();

        final authUser = await AuthUser.db.insertRow(
          session,
          AuthUser(
            scopeNames: {'user'},
          ),
        );

        final authUserId = authUser.id!;

        /// Create DigiGymUser for the authenticated session
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
            workoutTime: 45,
            dietaryPreference: 'None',
            bodyType: 'Average',
          ),
        );
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUserId.toString(),
            {Scope('user')},
          ),
        );
        final initial = await endpoints.profile.getMyFitnessData(
          authenticatedSession,
        );

        expect(initial, isNotNull);
        expect(initial!.fitnessLevel, FitnessLevel.beginner);
        expect(initial.fitnessGoal, equals(FitnessGoal.loseWeight));

        final updated = await endpoints.profile.updateMyFitnessData(
          authenticatedSession,
          FitnessLevel.advanced,
          FitnessGoal.maintainWeight,
        );

        expect(updated.fitnessLevel, equals(FitnessLevel.advanced));
        expect(updated.fitnessGoal, equals(FitnessGoal.maintainWeight));

        final persisted = await endpoints.profile.getMyFitnessData(
          authenticatedSession,
        );

        expect(persisted, isNotNull);
        expect(persisted!.fitnessLevel, equals(FitnessLevel.advanced));
        expect(persisted.fitnessGoal, equals(FitnessGoal.maintainWeight));

        final verify = await DigiGymUser.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(authUserId),
        );

        expect(verify, isNotNull);
        expect(verify!.fitnessLevel, equals(FitnessLevel.advanced));
        expect(verify.fitnessGoal, equals(FitnessGoal.maintainWeight));
      },
    );
    test(
      'handles an authenticated user without a fitness profile',
      () async {
        final session = sessionBuilder.build();

        final authUser = await AuthUser.db.insertRow(
          session,
          AuthUser(scopeNames: {'user'}),
        );
        final authUserId = authUser.id!;

        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUserId.toString(),
            {Scope('user')},
          ),
        );

        final fitnessData = await endpoints.profile.getMyFitnessData(
          authenticatedSession,
        );
        expect(fitnessData, isNull);

        await expectLater(
          endpoints.profile.updateMyFitnessData(
            authenticatedSession,
            FitnessLevel.intermediate,
            FitnessGoal.buildMuscle,
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              'User profile not found.',
            ),
          ),
        );
      },
    );
  });
}
