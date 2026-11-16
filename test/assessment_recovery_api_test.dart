import 'dart:convert';
import 'dart:io';

import 'package:digigym/client.dart' as app;
import 'package:digigym/services/digigym_api.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    show
        AuthSuccess,
        ClientAuthSuccessStorage,
        FlutterAuthSessionManager,
        FlutterAuthSessionManagerExtension,
        UserProfileModel;

class _AuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async => value = data;
}

// Real DigiGymApi, generated endpoints and SDK session storage against a local
// HTTP fixture. No live account, database, credentials or profile is changed.
void main() {
  const api = DigiGymApi();
  final account = UuidValue.fromString('123e4567-e89b-12d3-a456-426614174000');
  final otherAccount = UuidValue.fromString(
    '123e4567-e89b-12d3-a456-426614174001',
  );
  late HttpServer server;
  late _AuthStorage storage;
  DigiGymUser? profile;
  var email = 'assessment@example.com';
  var failProfileRequest = false;
  final requests = <String>[];

  AuthSuccess authFor(UuidValue id) => AuthSuccess(
    authStrategy: 'session',
    token: 'synthetic-contract-test-session',
    authUserId: id,
    scopeNames: {},
  );

  DigiGymUser draft({String name = '', UuidValue? accountId}) => DigiGymUser(
    authUserId: accountId ?? account,
    name: name,
    age: 20,
    height: 170,
    weight: 70,
    fitnessLevel: FitnessLevel.beginner,
    fitnessGoal: FitnessGoal.loseWeight,
    workoutTime: 30,
    dietaryPreference: 'No Preference',
    bodyType: 'Average',
  );

  Future<void> restoreSdkSession({UuidValue? accountId}) async {
    storage.value = authFor(accountId ?? account);
    app.client.authSessionManager = FlutterAuthSessionManager(storage: storage);
    expect(await app.client.auth.initialize(), isTrue);
    requests.clear();
  }

  setUpAll(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    app.client = Client('http://127.0.0.1:${server.port}/');
    server.listen((request) async {
      final path = request.uri.path;
      requests.add(path);
      await utf8.decoder.bind(request).join();
      Object? result;
      switch (path) {
        case '/emailIdp/login':
          result = authFor(profile?.authUserId ?? account).toJson();
        case '/profile/getMyProfile':
          if (failProfileRequest) request.response.statusCode = 503;
          result = profile?.toJson();
        case '/serverpod_auth_core.userProfileInfo/get':
          result = UserProfileModel(
            authUserId: profile?.authUserId ?? account,
            email: email,
          ).toJson();
        case '/serverpod_auth_core.status/isSignedIn':
          result = true;
        case '/serverpod_auth_core.status/signOutDevice':
          result = null;
        default:
          request.response.statusCode = 404;
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(result));
      await request.response.close();
    });
  });

  tearDownAll(() async {
    app.client.close();
    await server.close(force: true);
  });

  setUp(() async {
    requests.clear();
    storage = _AuthStorage();
    profile = draft();
    email = 'assessment@example.com';
    failProfileRequest = false;
    app.client.authSessionManager = FlutterAuthSessionManager(storage: storage);
    await app.client.auth.restore();
  });

  final needsAssessment = isA<ProfileSetupRequiredException>()
      .having((e) => e.profile?.accountId, 'account', account.toString())
      .having((e) => e.profile?.name, 'saved draft name', '')
      .having((e) => e.email, 'email', 'assessment@example.com');

  test(
    'successful auth with an untouched default row requires assessment',
    () async {
      await expectLater(
        api.login(email: email, password: 'synthetic-test-only'),
        throwsA(needsAssessment),
      );
      expect(api.isAuthenticated, isTrue);
      expect(storage.value?.authUserId, account);
      expect(requests, [
        '/emailIdp/login',
        '/profile/getMyProfile',
        '/serverpod_auth_core.userProfileInfo/get',
      ]);
    },
  );

  test(
    'SDK session restoration repeatedly gates an interrupted assessment',
    () async {
      for (var restart = 0; restart < 2; restart++) {
        await restoreSdkSession();
        await expectLater(api.restoreProfile(), throwsA(needsAssessment));
        expect(api.isAuthenticated, isTrue);
        expect(requests.any((path) => path.contains('update')), isFalse);
      }
    },
  );

  test(
    'whitespace-only name is incomplete without changing saved metrics',
    () async {
      profile = draft(name: '   ').copyWith(
        age: 37,
        height: 181.234,
        weight: 83.456,
        fitnessLevel: FitnessLevel.advanced,
        fitnessGoal: FitnessGoal.maintainWeight,
        workoutTime: 47,
      );
      await restoreSdkSession();
      await expectLater(
        api.restoreProfile(),
        throwsA(
          isA<ProfileSetupRequiredException>()
              .having((e) => e.profile?.height, 'height', 181.234)
              .having((e) => e.profile?.weight, 'weight', 83.456)
              .having((e) => e.profile?.workoutTime, 'duration', 47)
              .having((e) => e.profile?.fitnessGoal, 'goal', 'Maintain Weight'),
        ),
      );
    },
  );

  test('a completed profile with default metrics remains valid on login and restart', () async {
    profile = draft(name: 'Completed User');
    final signedIn = await api.login(
      email: email,
      password: 'synthetic-test-only',
    );
    expect(signedIn.hasCompletedAssessment, isTrue);
    await restoreSdkSession();
    final restored = await api.restoreProfile();
    expect(restored?.name, 'Completed User');
    expect(restored?.height, 170);
    expect(restored?.weight, 70);
    expect(requests.any((path) => path.contains('update')), isFalse);
  });

  test(
    'missing row is blocked instead of opening an unsaveable assessment',
    () async {
      profile = null;
      await restoreSdkSession();
      await expectLater(
        api.restoreProfile(),
        throwsA(isA<MissingFitnessProfileException>()),
      );
      expect(
        api.isAuthenticated,
        isTrue,
      ); // Retry/sign out is offered by the app.
      expect(requests, ['/profile/getMyProfile']);
    },
  );

  test(
    'missing-row login uses existing auth cleanup and never writes a profile',
    () async {
      profile = null;
      await expectLater(
        api.login(email: email, password: 'synthetic-test-only'),
        throwsA(isA<MissingFitnessProfileException>()),
      );
      expect(api.isAuthenticated, isFalse);
      expect(storage.value, isNull);
      expect(requests, [
        '/emailIdp/login',
        '/profile/getMyProfile',
        '/serverpod_auth_core.status/signOutDevice',
      ]);
    },
  );

  test(
    'failed profile request does not masquerade as missing or completed data',
    () async {
      failProfileRequest = true;
      await restoreSdkSession();
      await expectLater(
        api.restoreProfile(),
        throwsA(isA<ServerpodClientException>()),
      );
      expect(api.isAuthenticated, isTrue);
      failProfileRequest = false;
      profile = draft(name: 'Recovered User');
      expect((await api.restoreProfile())?.name, 'Recovered User');
    },
  );

  test(
    'account switch reads the new account rather than a prior completion flag',
    () async {
      profile = draft(name: 'First Account');
      await restoreSdkSession();
      expect((await api.restoreProfile())?.hasCompletedAssessment, isTrue);
      profile = draft(accountId: otherAccount);
      email = 'other@example.com';
      await restoreSdkSession(accountId: otherAccount);
      await expectLater(
        api.restoreProfile(),
        throwsA(
          isA<ProfileSetupRequiredException>()
              .having(
                (e) => e.profile?.accountId,
                'account',
                otherAccount.toString(),
              )
              .having((e) => e.email, 'email', email),
        ),
      );
    },
  );

  test('signed-out restoration makes no profile requests', () async {
    expect(await api.restoreProfile(), isNull);
    expect(requests, isEmpty);
  });
}
