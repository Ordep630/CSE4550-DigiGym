import 'dart:async';

import 'package:digigym/main.dart';
import 'package:digigym/models/session.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/assessment_screen.dart';
import 'package:digigym/screens/edit_profile_screen.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/screens/profile_screen.dart';
import 'package:digigym/screens/register_screen.dart';
import 'package:digigym/screens/verify_email_screen.dart';
import 'package:digigym/services/digigym_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

void main() {
  setUp(() {
    DigiGymSession.currentUser = null;
    DigiGymSession.registeredUser = null;
    DigiGymSession.clearPendingRegistration();
  });

  tearDown(() {
    DigiGymSession.currentUser = null;
    DigiGymSession.registeredUser = null;
    DigiGymSession.clearPendingRegistration();
  });

  testWidgets(
    'registration submits once and keeps password only for verification',
    (tester) async {
      final api = FakeDigiGymApi();

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(api: api),
          routes: {
            '/verify-email': (_) => const Scaffold(body: Text('Verify route')),
          },
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'New User');
      await tester.enterText(find.byType(TextField).at(1), 'new@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'secret12');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();

      expect(api.startedRegistrationEmail, 'new@example.com');
      expect(DigiGymSession.registrationRequestId, api.registrationRequestId);
      expect(DigiGymSession.pendingUser?.name, 'New User');
      expect(DigiGymSession.pendingRegistrationPassword, 'secret12');
      expect(find.text('Verify route'), findsOneWidget);
    },
  );

  testWidgets('email verification clears the retained password', (
    tester,
  ) async {
    final api = FakeDigiGymApi();
    DigiGymSession.registrationRequestId = api.registrationRequestId;
    DigiGymSession.pendingUser = testUser();
    DigiGymSession.pendingRegistrationPassword = 'secret12';

    await tester.pumpWidget(
      MaterialApp(
        home: VerifyEmailScreen(api: api),
        routes: {
          '/assessment': (_) => const Scaffold(body: Text('Assessment route')),
        },
      ),
    );

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Verify'));
    await tester.pumpAndSettle();

    expect(api.verifiedRequestId, api.registrationRequestId);
    expect(api.verifiedCode, '123456');
    expect(api.verifiedPassword, 'secret12');
    expect(DigiGymSession.pendingRegistrationPassword, isNull);
    expect(find.text('Assessment route'), findsOneWidget);
  });

  testWidgets('login retrieves a profile and clears the password field', (
    tester,
  ) async {
    final api = FakeDigiGymApi()..restoredProfile = testUser();
    var loggedInUser = testUser(name: 'Not logged in');

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(api: api, onLogin: (user) => loggedInUser = user),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret12');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pumpAndSettle();

    expect(api.loginEmail, 'test@example.com');
    expect(api.loginPassword, 'secret12');
    expect(loggedInUser.name, 'Test User');
    final passwordField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(passwordField.controller?.text, isEmpty);
  });

  testWidgets('session restoration shows progress and restores the profile', (
    tester,
  ) async {
    final restoreCompleter = Completer<void>();
    final api = FakeDigiGymApi()
      ..authenticated = true
      ..restoredProfile = testUser(name: 'Restored User')
      ..restoreWait = restoreCompleter.future;

    await tester.pumpWidget(DigiGymApp(api: api));
    expect(find.text('Restoring your session...'), findsOneWidget);

    restoreCompleter.complete();
    await tester.pumpAndSettle();

    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Restored User'), findsOneWidget);
  });

  testWidgets(
    'session restoration failure offers retry without clearing auth',
    (tester) async {
      final api = FakeDigiGymApi()
        ..authenticated = true
        ..restoreError = Exception('offline');

      await tester.pumpWidget(DigiGymApp(api: api));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('could not restore your session'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Sign out on this device'), findsOneWidget);
      expect(api.signOutCalls, 0);
    },
  );

  testWidgets('an authenticated user without a profile resumes assessment', (
    tester,
  ) async {
    final api = FakeDigiGymApi()
      ..authenticated = true
      ..restoreError = const ProfileSetupRequiredException(
        'incomplete@example.com',
      );

    await tester.pumpWidget(DigiGymApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Fitness Assessment'), findsOneWidget);
    expect(DigiGymSession.pendingUser?.email, 'incomplete@example.com');
    expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
  });

  testWidgets('assessment persists through updateMyProfile adapter', (
    tester,
  ) async {
    final api = FakeDigiGymApi()..authenticated = true;
    DigiGymSession.pendingUser = testUser(name: 'Assessment User');
    DigiGymSession.registrationRequestId = api.registrationRequestId;

    await tester.pumpWidget(MaterialApp(home: AssessmentScreen(api: api)));
    await tester.enterText(find.byType(TextField).at(1), '31');
    await tester.enterText(find.byType(TextField).at(2), '180');
    await tester.enterText(find.byType(TextField).at(3), '80');
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Create My Plan'),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create My Plan'));
    await tester.pumpAndSettle();

    expect(api.updateRequest?.name, 'Assessment User');
    expect(api.updateRequest?.age, 31);
    expect(api.updateRequest?.height, 180);
    expect(api.updateRequest?.weight, 80);
    expect(api.signOutCalls, 1);
    expect(DigiGymSession.pendingUser, isNull);
    expect(DigiGymSession.registrationRequestId, isNull);
  });

  testWidgets('Maintain Weight is submitted during assessment', (tester) async {
    final api = FakeDigiGymApi();
    DigiGymSession.pendingUser = testUser();

    await tester.pumpWidget(MaterialApp(home: AssessmentScreen(api: api)));
    final goalDropdown = find.byType(DropdownButtonFormField<String>).at(1);
    await tester.tap(goalDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maintain Weight').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), '31');
    await tester.enterText(find.byType(TextField).at(2), '180');
    await tester.enterText(find.byType(TextField).at(3), '80');
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Create My Plan'),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create My Plan'));
    await tester.pumpAndSettle();

    expect(api.updateRequest?.fitnessGoal, 'Maintain Weight');
    expect(api.signOutCalls, 1);
  });

  testWidgets('real profile edits support Maintain Weight', (tester) async {
    final api = FakeDigiGymApi();
    final original = testUser(fitnessGoal: 'Maintain Weight');
    UserProfile? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await Navigator.push<UserProfile>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(user: original, api: api),
                ),
              );
            },
            child: const Text('Open editor'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Updated User');
    await tester.ensureVisible(find.text('SAVE CHANGES'));
    await tester.tap(find.text('SAVE CHANGES'));
    await tester.pumpAndSettle();

    expect(api.updateRequest?.name, 'Updated User');
    expect(api.updateRequest?.fitnessGoal, 'Maintain Weight');
    expect(result?.name, 'Updated User');
    expect(result?.fitnessGoal, 'Maintain Weight');
  });

  testWidgets('logout shows progress while the async sign-out is running', (
    tester,
  ) async {
    final logoutCompleter = Completer<void>();
    var logoutCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(
          user: testUser(),
          onUpdateProfile: (_) {},
          onLogout: () {
            logoutCalls++;
            return logoutCompleter.future;
          },
        ),
      ),
    );

    await tester.ensureVisible(find.text('LOGOUT'));
    await tester.tap(find.text('LOGOUT'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pump();

    expect(logoutCalls, 1);
    expect(find.text('LOGGING OUT...'), findsOneWidget);

    logoutCompleter.complete();
    await tester.pumpAndSettle();
    expect(find.text('LOGOUT'), findsOneWidget);
  });
}
