import 'dart:async';

import 'package:digigym/main.dart';
import 'package:digigym/models/session.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/assessment_screen.dart';
import 'package:digigym/screens/edit_profile_screen.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/screens/profile_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/services/dashboard_personalization.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/screens/register_screen.dart';
import 'package:digigym/screens/verify_email_screen.dart';
import 'package:digigym/services/digigym_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    show KeyValueStorage;

import 'support/fake_digigym_api.dart';

class _MessageStorage implements KeyValueStorage {
  String? value;
  bool unavailable = false;
  int writes = 0;
  @override
  Future<String?> get(String key) async {
    if (unavailable) throw StateError('Unavailable');
    return value;
  }

  @override
  Future<void> set(String key, String? next) async {
    if (unavailable) throw StateError('Unavailable');
    value = next;
    writes++;
  }
}

Future<void> _login(WidgetTester tester, String email) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), 'secret12');
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

String _message(WidgetTester tester) =>
    tester.widget<HomeScreen>(find.byType(HomeScreen)).motivationalMessage;

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
    'complete registration verification assessment and login retains the existing flow',
    (tester) async {
      final api = FakeDigiGymApi();
      final storage = _MessageStorage();
      final personalization = DashboardPersonalization(storage: storage);
      await tester.pumpWidget(
        DigiGymApp(api: api, personalization: personalization),
      );
      await tester.pumpAndSettle();
      final signup = find.widgetWithText(TextButton, 'Sign Up');
      await tester.ensureVisible(signup);
      await tester.pumpAndSettle();
      await tester.tap(signup);
      await tester.pumpAndSettle();
      for (final entry in [
        'New User',
        'new@example.com',
        'secret12',
        'secret12',
      ].asMap().entries) {
        await tester.enterText(
          find.byType(TextField).at(entry.key),
          entry.value,
        );
      }
      await tester.pumpAndSettle();
      final register = find.widgetWithText(ElevatedButton, 'Register');
      await tester.ensureVisible(register);
      await tester.pumpAndSettle();
      await tester.tap(register);
      await tester.pumpAndSettle();
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'a1b2c3d4');
      await tester.pumpAndSettle();
      final verify = find.widgetWithText(ElevatedButton, 'Verify');
      await tester.ensureVisible(verify);
      await tester.pumpAndSettle();
      await tester.tap(verify);
      await tester.pumpAndSettle();
      expect(find.byType(AssessmentScreen), findsOneWidget);
      expect(DigiGymSession.pendingRegistrationPassword, isNull);
      expect(storage.writes, 0);
      await tester.enterText(find.byType(TextField).at(1), '31');
      await tester.enterText(find.byKey(const ValueKey('height-ft')), '5');
      await tester.enterText(find.byKey(const ValueKey('height-in')), '11');
      await tester.enterText(find.byKey(const ValueKey('weight-lb')), '176.4');
      await tester.pumpAndSettle();
      final create = find.widgetWithText(ElevatedButton, 'Create My Plan');
      await tester.ensureVisible(create);
      await tester.pumpAndSettle();
      await tester.tap(create);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(api.signOutCalls, 1);
      expect(api.updateRequest!.name, 'New User');
      expect(api.updateRequest!.email, 'new@example.com');
      expect(api.verifiedCode, 'a1b2c3d4');
      api.restoredProfile = api.updateRequest;
      ScaffoldMessenger.of(tester.element(find.byType(LoginScreen)))
          .removeCurrentSnackBar();
      await tester.pumpAndSettle();
      await _login(tester, 'new@example.com');
      await personalization.flush();
      expect(_message(tester), DashboardPersonalization.messages.first);
      expect(storage.writes, 1);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        tester.widget<DashboardPage>(find.byType(DashboardPage)).user.weight,
        closeTo(80.013694068, 1e-9),
      );
      expect(
        tester.widget<DashboardPage>(find.byType(DashboardPage)).user.name,
        'New User',
      );
    },
  );

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
      await tester.enterText(find.byType(TextField).at(3), 'secret12');
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Register'),
      );
      await tester.pumpAndSettle();
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
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
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

    await tester.pumpWidget(
      DigiGymApp(
        api: api,
        personalization: DashboardPersonalization(storage: _MessageStorage()),
        clock: () => DateTime(2026, 10, 20, 9),
      ),
    );
    expect(find.text('Restoring your session...'), findsOneWidget);

    restoreCompleter.complete();
    await tester.pumpAndSettle();

    expect(find.text('Good Morning,'), findsOneWidget);
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
    await tester.enterText(find.byKey(const ValueKey('height-ft')), '5');
    await tester.enterText(find.byKey(const ValueKey('height-in')), '11');
    await tester.enterText(find.byKey(const ValueKey('weight-lb')), '176.4');
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Create My Plan'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create My Plan'));
    await tester.pumpAndSettle();

    expect(api.updateRequest?.name, 'Assessment User');
    expect(api.updateRequest?.age, 31);
    expect(api.updateRequest?.height, closeTo(180.34, 1e-9));
    expect(api.updateRequest?.weight, closeTo(80.013694068, 1e-9));
    expect(api.signOutCalls, 1);
    expect(DigiGymSession.pendingUser, isNull);
    expect(DigiGymSession.registrationRequestId, isNull);
  });

  testWidgets('Maintain Weight is submitted during assessment', (tester) async {
    final api = FakeDigiGymApi();
    DigiGymSession.pendingUser = testUser();

    await tester.pumpWidget(MaterialApp(home: AssessmentScreen(api: api)));
    final goalDropdown = find.byType(DropdownButtonFormField<String>).at(1);
    await tester.pumpAndSettle();
    await tester.ensureVisible(goalDropdown);
    await tester.pumpAndSettle();
    await tester.tap(goalDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maintain Weight').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), '31');
    await tester.enterText(find.byKey(const ValueKey('height-ft')), '5');
    await tester.enterText(find.byKey(const ValueKey('height-in')), '11');
    await tester.enterText(find.byKey(const ValueKey('weight-lb')), '176.4');
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Create My Plan'),
    );
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('SAVE CHANGES'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAVE CHANGES'));
    await tester.pumpAndSettle();

    expect(api.updateRequest?.name, 'Updated User');
    expect(api.updateRequest?.fitnessGoal, 'Maintain Weight');
    expect(result?.name, 'Updated User');
    expect(result?.fitnessGoal, 'Maintain Weight');
  });

  testWidgets('only a completed successful login selects a new message', (
    tester,
  ) async {
    final api = FakeDigiGymApi();
    final storage = _MessageStorage();
    final service = DashboardPersonalization(storage: storage);
    await tester.pumpWidget(DigiGymApp(api: api, personalization: service));
    await tester.pumpAndSettle();
    api.loginError = StateError('Rejected');
    await _login(tester, 'test@example.com');
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(storage.writes, 0);
    final gate = Completer<void>();
    api.loginError = null;
    api.loginWait = gate.future;
    api.restoredProfile = testUser();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    expect(storage.writes, 0);
    expect(find.byType(HomeScreen), findsNothing);
    gate.complete();
    await tester.pumpAndSettle();
    await service.flush();
    final first = _message(tester);
    expect(first, DashboardPersonalization.messages.first);
    expect(storage.writes, 1);
    await tester.widget<HomeScreen>(find.byType(HomeScreen)).onLogout();
    await tester.pumpAndSettle();
    expect(storage.writes, 1);
    await _login(tester, 'test@example.com');
    await service.flush();
    expect(_message(tester), DashboardPersonalization.messages[1]);
    expect(storage.writes, 2);
    expect(api.signOutCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'tabs, rebuilds, profile updates and resume keep the session message',
    (tester) async {
      final api = FakeDigiGymApi();
      final storage = _MessageStorage();
      final service = DashboardPersonalization(storage: storage);
      var now = DateTime(2026, 10, 20, 9);
      Widget app() =>
          DigiGymApp(api: api, personalization: service, clock: () => now);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      api.restoredProfile = testUser();
      await _login(tester, 'test@example.com');
      await service.flush();
      final selected = _message(tester);
      for (final tab in ['Workout', 'Meals', 'Groceries', 'Profile', 'Home']) {
        await tester.tap(
          find.descendant(
            of: find.byType(FloatingBottomNavigationBar),
            matching: find.text(tab),
          ),
        );
        await tester.pumpAndSettle();
        if (tab == 'Workout') now = DateTime(2026, 10, 20, 13);
        expect(_message(tester), selected);
      }
      expect(find.text('Good Afternoon,'), findsOneWidget);
      expect(find.text(selected), findsOneWidget);
      tester
          .widget<HomeScreen>(find.byType(HomeScreen))
          .onUpdateProfile(testUser(name: 'Updated Name'));
      await tester.pumpAndSettle();
      expect(find.text('Updated Name'), findsOneWidget);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = DateTime(2026, 10, 20, 18);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Good Evening,'), findsOneWidget);
      expect(_message(tester), selected);
      expect(
        tester
            .widget<DashboardPage>(find.byType(DashboardPage))
            .motivationalMessage,
        selected,
      );
      await service.flush();
      expect(storage.writes, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'restoration and account switches preserve the correct account choice',
    (tester) async {
      final api = FakeDigiGymApi();
      final storage = _MessageStorage();
      var service = DashboardPersonalization(storage: storage);
      await tester.pumpWidget(DigiGymApp(api: api, personalization: service));
      await tester.pumpAndSettle();
      api.restoredProfile = testUser(name: 'Account A', email: 'a@example.com');
      await _login(tester, 'a@example.com');
      final a = _message(tester);
      await tester.widget<HomeScreen>(find.byType(HomeScreen)).onLogout();
      await tester.pumpAndSettle();
      api.restoredProfile = testUser(name: 'Account B', email: 'b@example.com');
      await _login(tester, 'b@example.com');
      final b = _message(tester);
      expect(b, isNot(a));
      await service.flush();
      expect(storage.writes, 2);
      await tester.pumpWidget(const SizedBox());
      DigiGymSession.currentUser = null;
      service = DashboardPersonalization(storage: storage);
      await tester.pumpWidget(DigiGymApp(api: api, personalization: service));
      await tester.pumpAndSettle();
      expect(find.text('Account B'), findsOneWidget);
      expect(_message(tester), b);
      expect(a, DashboardPersonalization.messages.first);
      await service.flush();
      expect(storage.writes, 2);
      await tester.widget<HomeScreen>(find.byType(HomeScreen)).onLogout();
      await tester.pumpAndSettle();
      api.restoredProfile = testUser(name: 'Account A', email: 'a@example.com');
      await _login(tester, 'a@example.com');
      expect(_message(tester), isNot(b));
      expect(find.text('Account A'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unavailable personalization storage does not block auth or restoration',
    (tester) async {
      final api = FakeDigiGymApi()
        ..authenticated = true
        ..restoredProfile = testUser();
      final storage = _MessageStorage()..unavailable = true;
      final service = DashboardPersonalization(storage: storage);
      await tester.pumpWidget(DigiGymApp(api: api, personalization: service));
      await tester.pumpAndSettle();
      final first = _message(tester);
      expect(
        find.textContaining('could not restore your session'),
        findsNothing,
      );
      expect(api.authenticated, isTrue);
      await service.flush();
      await tester.widget<HomeScreen>(find.byType(HomeScreen)).onLogout();
      await tester.pumpAndSettle();
      await _login(tester, 'test@example.com');
      expect(_message(tester), isNot(first));
      expect(api.authenticated, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'demo login gets one stable message without backend authentication',
    (tester) async {
      final api = FakeDigiGymApi();
      final service = DashboardPersonalization(storage: _MessageStorage());
      await tester.pumpWidget(DigiGymApp(api: api, personalization: service));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'demo@gym.com');
      await tester.enterText(find.byType(TextField).at(1), '123456');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(api.loginEmail, isNull);
      expect(api.authenticated, isFalse);
      expect(DashboardPersonalization.messages, contains(_message(tester)));
    },
  );

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

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('LOGOUT'));
    await tester.pumpAndSettle();
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
