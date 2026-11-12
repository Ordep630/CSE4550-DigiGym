import 'dart:async';

import 'package:digigym/models/session.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/assessment_screen.dart';
import 'package:digigym/screens/edit_profile_screen.dart';
import 'package:digigym/widgets/digigym_form_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

class _ProfileApi extends FakeDigiGymApi {
  int updates = 0;
  @override
  Future<UserProfile> updateProfile(UserProfile profile) {
    updates++;
    return super.updateProfile(profile);
  }
}

Future<void> choose(WidgetTester tester, Finder dropdown, String value) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'DigiGymInter',
    )..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'))).load();
  });
  setUp(DigiGymSession.clearPendingRegistration);
  tearDown(DigiGymSession.clearPendingRegistration);

  testWidgets(
    'assessment keeps every field, maps choices and submits only once',
    (tester) async {
      final gate = Completer<void>();
      final api = _ProfileApi()..updateWait = gate.future;
      DigiGymSession.pendingUser = testUser(name: 'Assessment User');
      var completed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: AssessmentScreen(api: api, onComplete: () => completed++),
        ),
      );
      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(4));
      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(TextField).first)).brightness,
        Brightness.dark,
      );
      await tester.enterText(find.byType(TextField).at(1), '31');
      await tester.enterText(find.byKey(const ValueKey('height-ft')), '5');
      await tester.enterText(find.byKey(const ValueKey('height-in')), '11');
      await tester.enterText(find.byKey(const ValueKey('weight-lb')), '176.4');
      final dropdowns = find.byType(DropdownButtonFormField<String>);
      await choose(tester, dropdowns.at(0), 'Advanced');
      await choose(tester, dropdowns.at(1), 'Maintain Weight');
      await choose(tester, dropdowns.at(2), 'No Restrictions');
      await choose(tester, dropdowns.at(3), 'Athletic');
      await choose(
        tester,
        find.byType(DropdownButtonFormField<int>),
        '60 minutes',
      );
      final action = tester
          .widget<DigiGymPrimaryButton>(find.byType(DigiGymPrimaryButton))
          .onPressed!;
      action();
      action();
      await tester.pump();
      expect(api.updates, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      gate.complete();
      await tester.pumpAndSettle();
      final profile = api.updateRequest!;
      expect(
        (profile.name, profile.age, profile.height, profile.weight),
        ('Assessment User', 31, 180.34, 80.013694068),
      );
      expect(
        (
          profile.fitnessLevel,
          profile.fitnessGoal,
          profile.dietaryPreference,
          profile.bodyType,
          profile.workoutTime,
        ),
        ('Advanced', 'Maintain Weight', 'No Preference', 'Athletic', 60),
      );
      expect(api.signOutCalls, 1);
      expect(completed, 1);
      expect(DigiGymSession.pendingUser, isNull);
    },
  );

  testWidgets('assessment validation and API errors retain entered values', (
    tester,
  ) async {
    final api = _ProfileApi()..updateError = StateError('offline');
    DigiGymSession.pendingUser = testUser();
    await tester.pumpWidget(MaterialApp(home: AssessmentScreen(api: api)));
    final button = find.widgetWithText(ElevatedButton, 'Create My Plan');
    await tester.pumpAndSettle();
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a name and valid age, height, and weight.'),
      findsOneWidget,
    );
    expect(api.updates, 0);
    ScaffoldMessenger.of(tester.element(find.byType(TextField).first))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '31');
    await tester.enterText(find.byKey(const ValueKey('height-ft')), '5');
    await tester.enterText(find.byKey(const ValueKey('height-in')), '11');
    await tester.enterText(find.byKey(const ValueKey('weight-lb')), '176.4');
    await tester.pumpAndSettle();
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Unable to save your assessment. Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(api.signOutCalls, 0);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('weight-lb')))
          .controller!
          .text,
      '176.4',
    );
  });

  testWidgets(
    'pushed profile editor populates values, reports errors and returns the saved profile',
    (tester) async {
      final api = _ProfileApi()..updateError = StateError('offline');
      final original = testUser();
      UserProfile? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditProfileScreen(user: original, api: api),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(TextField).first)).brightness,
        Brightness.dark,
      );
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .map((f) => f.controller!.text),
        ['Test User', '28', '5', '7.7', '149.9', '45'],
      );
      await tester.enterText(find.byType(TextField).at(0), 'Updated User');
      await tester.enterText(find.byKey(const ValueKey('weight-lb')), '160');
      await choose(
        tester,
        find.byType(DropdownButtonFormField<String>).at(1),
        'Maintain Weight',
      );
      await choose(
        tester,
        find.byType(DropdownButtonFormField<String>).at(0),
        'Advanced',
      );
      await choose(
        tester,
        find.byType(DropdownButtonFormField<String>).at(2),
        'Vegan',
      );
      final button = find.widgetWithText(ElevatedButton, 'SAVE CHANGES');
      await tester.pumpAndSettle();
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Unable to save your profile. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(result, isNull);
      api.updateError = null;
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(result!.name, 'Updated User');
      expect(result!.weight, closeTo(72.5747792, 1e-9));
      expect(result!.fitnessGoal, 'Maintain Weight');
      expect(result!.fitnessLevel, 'Advanced');
      expect(result!.dietaryPreference, 'Vegan');
      expect(result!.email, original.email);
      expect(api.updates, 2);
    },
  );

  testWidgets(
    'profile forms stay scrollable on short screens, with keyboards and through 3x text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final assessment in [true, false]) {
        for (final scale in [1.0, 2.0, 3.0]) {
          for (final keyboard in [0.0, 280.0]) {
            tester.view.physicalSize = const Size(320, 568);
            DigiGymSession.pendingUser = testUser();
            await tester.pumpWidget(
              MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                    viewInsets: EdgeInsets.only(bottom: keyboard),
                  ),
                  child: child!,
                ),
                home: assessment
                    ? AssessmentScreen(key: UniqueKey(), api: _ProfileApi())
                    : EditProfileScreen(
                        key: UniqueKey(),
                        user: testUser(),
                        api: _ProfileApi(),
                      ),
              ),
            );
            await tester.pumpAndSettle();
            for (final target in [
              find.byType(TextField).first,
              find.byType(DropdownButtonFormField<String>).last,
              find.byType(ElevatedButton),
            ]) {
              await tester.pumpAndSettle();
              await tester.ensureVisible(target);
              await tester.pumpAndSettle();
              final bounds = tester.getRect(target);
              expect(bounds.left, greaterThanOrEqualTo(20));
              expect(bounds.right, lessThanOrEqualTo(300));
              expect(
                bounds.bottom,
                lessThanOrEqualTo(568 - keyboard + .001),
                reason: "$assessment / $scale / $keyboard / $target / $bounds",
              );
            }
            await choose(
              tester,
              find.byType(DropdownButtonFormField<String>).first,
              'Advanced',
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$assessment $scale $keyboard',
            );
          }
        }
      }
    },
  );

  testWidgets('invalid profile values never reach the API', (tester) async {
    final api = _ProfileApi();
    await tester.pumpWidget(
      MaterialApp(
        home: EditProfileScreen(user: testUser(), api: api),
      ),
    );
    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.pumpAndSettle();
    final save = find.widgetWithText(ElevatedButton, 'SAVE CHANGES');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Enter valid profile values.'), findsOneWidget);
    expect(api.updates, 0);
  });
}
