import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/edit_profile_screen.dart';
import 'package:digigym/screens/profile_details_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

Future<void> save(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'SAVE CHANGES');
  await tester.pumpAndSettle();
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'repeated unchanged and name-only saves preserve exact metric values and calculations',
    (tester) async {
      final api = FakeDigiGymApi();
      var profile = testUser()
        ..height = 174.123456789
        ..weight = 58.0123456789;
      final originalHeight = profile.height,
          originalWeight = profile.weight,
          originalBmi = profile.bmi;
      for (var i = 0; i < 4; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    final result = await Navigator.push<UserProfile>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditProfileScreen(user: profile, api: api),
                      ),
                    );
                    if (result != null) profile = result;
                  },
                  child: const Text('Edit'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'Updated $i');
        await save(tester);
        expect(profile.height, originalHeight);
        expect(profile.weight, originalWeight);
        expect(profile.bmi, originalBmi);
        expect(api.updateRequest!.height, originalHeight);
        expect(api.updateRequest!.weight, originalWeight);
      }
    },
  );
  testWidgets(
    'imperial edits become metric only at submission and invalid values never reach API',
    (tester) async {
      final api = FakeDigiGymApi();
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfileScreen(user: testUser(), api: api),
        ),
      );
      for (final pair in [('', '0'), ('5', '12'), ('5', 'NaN'), ('-1', '2')]) {
        await tester.enterText(
          find.byKey(const ValueKey('height-ft')),
          pair.$1,
        );
        await tester.enterText(
          find.byKey(const ValueKey('height-in')),
          pair.$2,
        );
        await save(tester);
        expect(api.updateRequest, isNull);
      }
      await tester.enterText(find.byKey(const ValueKey('height-ft')), '6');
      await tester.enterText(find.byKey(const ValueKey('height-in')), '0');
      await tester.enterText(find.byKey(const ValueKey('weight-lb')), '200');
      await save(tester);
      expect(api.updateRequest!.height, 182.88);
      expect(api.updateRequest!.weight, 90.718474);
      expect(api.updateRequest!.bmi, closeTo(27.12462, .0001));
    },
  );
  testWidgets(
    'profile measurements stay readable at narrow widths and through 3x text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final scale in [1.0, 2.0, 3.0]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: DigiGymDashboardTheme.dark(ThemeData()),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: ProfileDetailsScreen(
              user: testUser()
                ..height = 174
                ..weight = 58,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('5 ft 8.5 in'), findsOneWidget);
        expect(find.text('127.9 lb'), findsOneWidget);
        for (final label in ['5 ft 8.5 in', '127.9 lb']) {
          await tester.ensureVisible(find.text(label));
          await tester.pumpAndSettle();
          final rect = tester.getRect(find.text(label));
          expect(rect.left, greaterThanOrEqualTo(20));
          expect(rect.right, lessThanOrEqualTo(300));
        }
        expect(tester.takeException(), isNull, reason: 'scale $scale');
      }
    },
  );
}
