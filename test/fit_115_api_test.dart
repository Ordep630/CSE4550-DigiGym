import 'dart:convert';
import 'dart:io';

import 'package:digigym/client.dart' as app;
import 'package:digigym/services/digigym_api.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        AuthSuccess,
        ClientAuthSuccessStorage,
        EmailAccountLoginException,
        EmailAccountLoginExceptionReason,
        EmailAccountPasswordResetException,
        EmailAccountPasswordResetExceptionReason;
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    show FlutterAuthSessionManager, FlutterAuthSessionManagerExtension;

class _MemorySession implements ClientAuthSuccessStorage {
  AuthSuccess? value;

  @override
  Future<AuthSuccess?> get() async => value;

  @override
  Future<void> set(AuthSuccess? data) async => value = data;
}

void main() {
  const api = DigiGymApi();
  final account = UuidValue.fromString('123e4567-e89b-12d3-a456-426614174000');
  final timestamp = DateTime(2026, 11, 18, 23, 59).toUtc();
  final fixture = CompletedWorkout(
    id: 7,
    authUserId: account,
    workoutName: 'Strength',
    durationMinutes: 30,
    details: '[]',
    completedAt: timestamp,
  );
  final requests = <String>[];
  final workoutInputs = <String, Map<String, dynamic>>{};
  late HttpServer server;
  late _MemorySession storage;
  Object? passwordError;

  setUpAll(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    app.client = Client('http://127.0.0.1:${server.port}/');
    server.listen((request) async {
      final path = request.uri.path;
      requests.add(path);
      final body = await utf8.decoder.bind(request).join();
      if (!path.startsWith('/profile/')) {
        workoutInputs[path] = jsonDecode(body) as Map<String, dynamic>;
      }
      final Object? data = switch (path) {
        '/workoutHistory/completeWorkout' => fixture.toJson(),
        '/workoutHistory/getMyWorkoutHistory' => [fixture.toJson()],
        '/workoutHistory/deleteMyWorkoutHistory' => 1,
        '/workoutStreak/recordCompletion' || '/workoutStreak/getMyStreak' => 2,
        '/profile/changePassword' =>
          passwordError == null
              ? null
              : Protocol().wrapWithClassName(passwordError),
        _ => null,
      };
      if (path == '/profile/changePassword' && passwordError != null) {
        request.response.statusCode = HttpStatus.badRequest;
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(data));
      await request.response.close();
    });
  });

  setUp(() async {
    storage = _MemorySession();
    app.client.authSessionManager = FlutterAuthSessionManager(storage: storage);
    await app.client.auth.updateSignedInUser(
      AuthSuccess(
        authStrategy: 'session',
        token: 'fixture-only',
        authUserId: account,
        scopeNames: {},
      ),
    );
    passwordError = null;
    requests.clear();
    workoutInputs.clear();
  });

  tearDownAll(() async {
    app.client.close();
    await server.close(force: true);
  });

  test(
    'workout endpoints use the generated contract and the local completion day',
    () async {
      final saved = await api.completeWorkout(
        workoutName: 'Strength',
        durationMinutes: 30,
        details: '[]',
      );
      expect(saved.id, 7);
      expect(saved.completedAt, timestamp);
      expect(await api.recordWorkoutCompletion(saved.completedAt), 2);
      expect(await api.getWorkoutStreak(DateTime(2026, 11, 19, 0, 1)), 2);
      expect((await api.getWorkoutHistory()).single.authUserId, account);
      expect(await api.deleteWorkoutHistory([7]), 1);
      expect(workoutInputs['/workoutHistory/completeWorkout'], {
        'workoutName': 'Strength',
        'durationMinutes': 30,
        'details': '[]',
      });
      expect(workoutInputs['/workoutStreak/recordCompletion'], {
        'localDay': '2026-11-18',
      });
      expect(workoutInputs['/workoutStreak/getMyStreak'], {
        'localDay': '2026-11-19',
      });
      expect(workoutInputs['/workoutHistory/deleteMyWorkoutHistory'], {
        'workoutIds': [7],
      });
    },
  );

  test(
    'password errors are safe, typed and leave the SDK session intact',
    () async {
      final initialAuth = storage.value;
      Future<void> change() => api.changePassword(
        currentPassword: 'fixture-current-value',
        newPassword: 'fixture-new-value',
      );
      for (final (serverError, expected) in [
        (
          EmailAccountLoginException(
            reason: EmailAccountLoginExceptionReason.invalidCredentials,
          ),
          PasswordChangeFailure.incorrectCurrentPassword,
        ),
        (
          EmailAccountLoginException(
            reason: EmailAccountLoginExceptionReason.tooManyAttempts,
          ),
          PasswordChangeFailure.tooManyAttempts,
        ),
        (
          EmailAccountPasswordResetException(
            reason: EmailAccountPasswordResetExceptionReason.policyViolation,
          ),
          PasswordChangeFailure.policyViolation,
        ),
      ]) {
        passwordError = serverError;
        await expectLater(
          change(),
          throwsA(
            isA<PasswordChangeException>().having(
              (value) => value.reason,
              'reason',
              expected,
            ),
          ),
        );
      }
      passwordError = null;
      await change();
      expect(storage.value, same(initialAuth));
      expect(requests, List.filled(4, '/profile/changePassword'));
    },
  );

  test('signed-out calls fail without sending a request', () async {
    await app.client.auth.updateSignedInUser(null);
    await expectLater(api.getWorkoutHistory(), throwsStateError);
    await expectLater(api.getWorkoutStreak(timestamp), throwsStateError);
    await expectLater(
      api.changePassword(
        currentPassword: 'fixture-old',
        newPassword: 'fixture-new',
      ),
      throwsA(
        isA<PasswordChangeException>().having(
          (value) => value.reason,
          'reason',
          PasswordChangeFailure.signInRequired,
        ),
      ),
    );
    expect(requests, isEmpty);
  });
}
