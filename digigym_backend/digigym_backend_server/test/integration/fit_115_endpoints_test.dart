import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('FIT-115', (sessions, endpoints) {
    const originalPassword = 'fixture-original-password';
    const newPassword = 'fixture-replacement-password';

    Future<UuidValue> createUser() async {
      final session = sessions.build();
      try {
        final user = await AuthUser.db.insertRow(
          session,
          AuthUser(scopeNames: {}),
        );
        return user.id!;
      } finally {
        await session.close();
      }
    }

    TestSessionBuilder authenticated(UuidValue id) => sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        id.toString(),
        {},
      ),
    );

    test(
      'history is scoped to the caller and bulk deletion ignores foreign IDs',
      () async {
        final firstId = await createUser();
        final secondId = await createUser();
        final first = authenticated(firstId);
        final second = authenticated(secondId);

        final firstWorkout = await endpoints.workoutHistory.completeWorkout(
          first,
          '  Strength  ',
          30,
          '[]',
        );
        final secondWorkout = await endpoints.workoutHistory.completeWorkout(
          second,
          'Intervals',
          20,
          '[]',
        );

        expect(firstWorkout.workoutName, 'Strength');
        expect(firstWorkout.durationMinutes, 30);
        expect(firstWorkout.authUserId, firstId);
        expect(firstWorkout.completedAt.isUtc, isTrue);
        expect(
          (await endpoints.workoutHistory.getMyWorkoutHistory(
            first,
          )).map((row) => row.id),
          [firstWorkout.id],
        );
        final day = DateTime.now().toUtc().toIso8601String().substring(0, 10);
        await endpoints.workoutStreak.recordCompletion(first, day);
        expect(
          await endpoints.workoutHistory.deleteMyWorkoutHistory(
            first,
            [firstWorkout.id!, firstWorkout.id!, secondWorkout.id!],
          ),
          1,
        );
        expect(
          await endpoints.workoutHistory.getMyWorkoutHistory(first),
          isEmpty,
        );
        expect(
          (await endpoints.workoutHistory.getMyWorkoutHistory(
            second,
          )).single.id,
          secondWorkout.id,
        );
        expect(await endpoints.workoutStreak.getMyStreak(first, day), 1);
      },
    );

    test(
      'concurrent first writes share one streak and local dates advance once',
      () async {
        final first = authenticated(await createUser());
        final second = authenticated(await createUser());
        final today = DateTime.now().toUtc();
        String localDay(int delta) =>
            today.add(Duration(days: delta)).toIso8601String().substring(0, 10);
        final previousDay = localDay(-1);
        final currentDay = localDay(0);

        expect(
          await endpoints.workoutStreak.getMyStreak(first, previousDay),
          0,
        );
        expect(
          await Future.wait([
            endpoints.workoutStreak.recordCompletion(first, previousDay),
            endpoints.workoutStreak.recordCompletion(first, previousDay),
          ]),
          [1, 1],
        );
        expect(
          await endpoints.workoutStreak.recordCompletion(first, currentDay),
          2,
        );
        expect(
          await endpoints.workoutStreak.recordCompletion(first, previousDay),
          2,
        );
        expect(await endpoints.workoutStreak.getMyStreak(first, currentDay), 2);
        expect(
          await endpoints.workoutStreak.getMyStreak(second, currentDay),
          0,
        );
        await expectLater(
          endpoints.workoutStreak.recordCompletion(first, localDay(2)),
          throwsArgumentError,
        );
      },
    );

    test(
      'password changes preserve issued JWTs and reject the old password',
      () async {
        final session = sessions.build();
        addTearDown(session.close);
        final random = Random.secure();
        String testSecret() => String.fromCharCodes(
          List.generate(64, (_) => 97 + random.nextInt(26)),
        );
        session.serverpod.initializeAuthServices(
          tokenManagerBuilders: [
            JwtConfig(
              algorithm: JwtAlgorithm.hmacSha512(SecretKey(testSecret())),
              refreshTokenHashPepper: testSecret(),
            ),
          ],
          identityProviderBuilders: [
            EmailIdpConfig(secretHashPepper: testSecret()),
          ],
        );

        final id = await createUser();
        final signedIn = authenticated(id);
        const email = 'password-fixture@example.test';
        final idp = AuthServices.getIdentityProvider<EmailIdp>();
        await idp.admin.createEmailAuthentication(
          session,
          authUserId: id,
          email: email,
          password: originalPassword,
        );
        final existing = await idp.login(
          session,
          email: email,
          password: originalPassword,
        );

        await expectLater(
          endpoints.profile.changePassword(
            signedIn,
            'fixture-incorrect-value',
            newPassword,
          ),
          throwsA(
            isA<EmailAccountLoginException>().having(
              (e) => e.reason,
              'reason',
              EmailAccountLoginExceptionReason.invalidCredentials,
            ),
          ),
        );
        await expectLater(
          endpoints.profile.changePassword(signedIn, originalPassword, 'tiny'),
          throwsA(
            isA<EmailAccountPasswordResetException>().having(
              (e) => e.reason,
              'reason',
              EmailAccountPasswordResetExceptionReason.policyViolation,
            ),
          ),
        );

        await endpoints.profile.changePassword(
          signedIn,
          originalPassword,
          newPassword,
        );
        await expectLater(
          idp.login(session, email: email, password: originalPassword),
          throwsA(isA<EmailAccountLoginException>()),
        );
        final replacement = await idp.login(
          session,
          email: email,
          password: newPassword,
        );
        expect(replacement.authUserId, id);
        expect(
          (await AuthServices.instance.authenticationHandler(
            session,
            existing.token,
          ))?.authUserId,
          id,
        );
        final rolled = await AuthServices.getTokenManager<JwtTokenManager>().jwt
            .refreshAccessToken(session, refreshToken: existing.refreshToken!);
        expect(rolled.authUserId, id);
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
