import 'package:digigym/main.dart';
import 'package:digigym/models/session.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/assessment_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/services/digigym_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

const _account = '123e4567-e89b-12d3-a456-426614174000';

UserProfile _draft() => UserProfile(
  accountId: _account,
  name: '',
  email: 'interrupted@example.com',
  age: 37,
  height: 181.234,
  weight: 83.456,
  fitnessLevel: 'Advanced',
  fitnessGoal: 'Maintain Weight',
  workoutTime: 47,
  dietaryPreference: 'Vegetarian',
  bodyType: 'Athletic',
);

Future<void> _submit(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  final button = find.widgetWithText(ElevatedButton, 'Create My Plan');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextField).at(0),
    'interrupted@example.com',
  );
  await tester.enterText(find.byType(TextField).at(1), 'synthetic-test-only');
  final button = find.widgetWithText(ElevatedButton, 'Login');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  void clearSession() {
    DigiGymSession.currentUser = null;
    DigiGymSession.registeredUser = null;
    DigiGymSession.clearPendingRegistration();
  }

  setUp(() {
    clearSession();
    final storage = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
          final args = call.arguments as Map;
          final key = args['key'] as String;
          if (call.method == 'read') return storage[key];
          if (call.method == 'write') storage[key] = args['value'] as String;
          if (call.method == 'delete') storage.remove(key);
          return null;
        });
  });
  tearDown(() {
    clearSession();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  testWidgets(
    'restart keeps interrupted assessment gated and preserves the server draft',
    (tester) async {
      final draft = _draft();
      final api = FakeDigiGymApi()
        ..authenticated = true
        ..restoreError = ProfileSetupRequiredException(
          draft.email,
          profile: draft,
        );
      for (var restart = 0; restart < 2; restart++) {
        // Simulate loss of all in-memory registration state across app restarts.
        clearSession();
        await tester.pumpWidget(DigiGymApp(key: ValueKey(restart), api: api));
        await tester.pumpAndSettle();
        expect(find.byType(AssessmentScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsNothing);
        expect(DigiGymSession.currentUser, isNull);
        expect(DigiGymSession.pendingUser?.accountId, _account);
        expect(
          tester
              .widget<TextField>(find.byType(TextField).at(1))
              .controller!
              .text,
          '37',
        );
        expect(find.text('Maintain Weight'), findsOneWidget);
        expect(find.text('47 minutes'), findsOneWidget);
        expect(api.updateRequest, isNull);
      }
    },
  );

  testWidgets(
    'recovered assessment saves once with its original precise profile values',
    (tester) async {
      final draft = _draft();
      final api = FakeDigiGymApi()
        ..authenticated = true
        ..restoreError = ProfileSetupRequiredException(
          draft.email,
          profile: draft,
        );
      await tester.pumpWidget(DigiGymApp(api: api));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Recovered User');
      await _submit(tester);

      final saved = api.updateRequest!;
      expect(saved.accountId, _account);
      expect(saved.email, draft.email);
      expect(saved.height, 181.234);
      expect(saved.weight, 83.456);
      expect(saved.age, 37);
      expect(saved.fitnessLevel, 'Advanced');
      expect(saved.fitnessGoal, 'Maintain Weight');
      expect(saved.workoutTime, 47);
      expect(saved.dietaryPreference, 'Vegetarian');
      expect(saved.bodyType, 'Athletic');
      expect(api.signOutCalls, 1);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(DigiGymSession.pendingUser, isNull);

      api
        ..authenticated = true
        ..restoreError = null
        ..restoredProfile = saved;
      await tester.pumpWidget(
        DigiGymApp(key: const ValueKey('completed-restart'), api: api),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(DigiGymSession.currentUser?.height, 181.234);
      expect(find.byType(AssessmentScreen), findsNothing);
    },
  );

  testWidgets(
    'failed assessment save stays open with entered values and supports retry',
    (tester) async {
      final draft = _draft();
      final api = FakeDigiGymApi()
        ..authenticated = true
        ..updateError = Exception('offline');
      DigiGymSession.pendingUser = draft;
      await tester.pumpWidget(MaterialApp(home: AssessmentScreen(api: api)));
      await tester.enterText(find.byType(TextField).at(0), 'Recovered User');
      await _submit(tester);
      expect(
        find.textContaining('Unable to save your assessment'),
        findsOneWidget,
      );
      expect(find.byType(AssessmentScreen), findsOneWidget);
      expect(api.signOutCalls, 0);
      expect(DigiGymSession.pendingUser, same(draft));
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        'Recovered User',
      );
      api.updateError = null;
      ScaffoldMessenger.of(tester.element(find.byType(AssessmentScreen)))
          .removeCurrentSnackBar();
      await _submit(tester);
      expect(api.signOutCalls, 1);
      expect(DigiGymSession.pendingUser, isNull);
    },
  );

  testWidgets('unconfirmed save does not announce success or clear the draft', (
    tester,
  ) async {
    final draft = _draft();
    final api = FakeDigiGymApi()..updatedProfile = _draft();
    DigiGymSession.pendingUser = draft;
    await tester.pumpWidget(MaterialApp(home: AssessmentScreen(api: api)));
    await tester.enterText(find.byType(TextField).at(0), 'Recovered User');
    await _submit(tester);
    expect(
      find.textContaining('Unable to save your assessment'),
      findsOneWidget,
    );
    expect(api.signOutCalls, 0);
    expect(DigiGymSession.pendingUser, same(draft));
    expect(DigiGymSession.registeredUser, isNull);
  });

  testWidgets(
    'missing profile offers retry and sign out without opening Assessment',
    (tester) async {
      DigiGymSession.pendingUser = testUser(email: 'stale@example.com');
      DigiGymSession.registrationRequestId = 'stale-registration';
      DigiGymSession.pendingRegistrationPassword = 'synthetic-test-only';
      DigiGymSession.currentUser = testUser(email: 'stale@example.com');
      final api = FakeDigiGymApi()
        ..authenticated = true
        ..restoreError = const MissingFitnessProfileException();
      await tester.pumpWidget(DigiGymApp(api: api));
      await tester.pumpAndSettle();
      expect(find.text(MissingFitnessProfileException.message), findsOneWidget);
      expect(find.byType(AssessmentScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      expect(api.signOutCalls, 0);
      expect(api.updateRequest, isNull);
      expect(DigiGymSession.pendingUser, isNull);
      expect(DigiGymSession.pendingRegistrationPassword, isNull);
      expect(DigiGymSession.registrationRequestId, isNull);
      expect(DigiGymSession.currentUser, isNull);
      await tester.tap(find.text('Sign out on this device'));
      await tester.pumpAndSettle();
      expect(api.signOutCalls, 1);
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  testWidgets(
    'missing-row retry recovers only after the backend returns a real profile',
    (tester) async {
      final api = FakeDigiGymApi()
        ..authenticated = true
        ..restoreError = const MissingFitnessProfileException();
      await tester.pumpWidget(DigiGymApp(api: api));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text(MissingFitnessProfileException.message), findsOneWidget);
      api
        ..restoreError = null
        ..restoredProfile = testUser();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(api.updateRequest, isNull);
    },
  );

  testWidgets('login routes only the current account draft to Assessment', (
    tester,
  ) async {
    final draft = _draft();
    final api = FakeDigiGymApi()
      ..loginError = ProfileSetupRequiredException(draft.email, profile: draft);
    DigiGymSession.pendingUser = testUser(email: 'different@example.com');
    DigiGymSession.registrationRequestId = 'other-account-request';
    DigiGymSession.pendingRegistrationPassword = 'synthetic-test-only';
    var loggedIn = false;
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(api: api, onLogin: (_) => loggedIn = true),
        routes: {'/assessment': (_) => AssessmentScreen(api: api)},
      ),
    );
    await _login(tester);
    expect(loggedIn, isFalse);
    expect(find.byType(AssessmentScreen), findsOneWidget);
    expect(DigiGymSession.pendingUser, same(draft));
    expect(DigiGymSession.registrationRequestId, isNull);
    expect(DigiGymSession.pendingRegistrationPassword, isNull);
    expect(api.updateRequest, isNull);
  });

  testWidgets(
    'missing-row login reports the dependency without fake saving or navigation',
    (tester) async {
      final api = FakeDigiGymApi()
        ..loginError = const MissingFitnessProfileException();
      var loggedIn = false;
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(api: api, onLogin: (_) => loggedIn = true),
        ),
      );
      await _login(tester);
      expect(find.text(MissingFitnessProfileException.message), findsOneWidget);
      expect(find.byType(AssessmentScreen), findsNothing);
      expect(loggedIn, isFalse);
      expect(api.updateRequest, isNull);
      expect(DigiGymSession.pendingUser, isNull);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        isEmpty,
      );
    },
  );
}
