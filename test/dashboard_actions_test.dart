import 'dart:ui' as ui;

import 'package:digigym/main.dart';
import 'package:digigym/models/session.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/screens/edit_profile_screen.dart';
import 'package:digigym/screens/meal_page.dart';
import 'package:digigym/screens/workouts_screen.dart';
import 'package:digigym/screens/profile_screen.dart';
import 'package:digigym/screens/grocery_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/dashboard_card_action.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

Future<FakeDigiGymApi> startDashboard(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280 / 3, 952);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final api = FakeDigiGymApi()
    ..authenticated = true
    ..restoredProfile = testUser();
  await tester.pumpWidget(
    DigiGymApp(api: api, clock: () => DateTime(2026, 10, 24, 9)),
  );
  await tester.pumpAndSettle();
  return api;
}

void main() {
  setUpAll(() async {
    for (final entry in {
      'DigiGymInter': 'Inter',
      'DigiGymDoto': 'Doto',
    }.entries) {
      await (FontLoader(entry.key)..addFont(
            rootBundle.load('assets/fonts/${entry.value}-Variable.ttf'),
          ))
          .load();
    }
  });
  tearDown(() {
    DigiGymSession.currentUser = null;
  });
  for (final action in [
    ('calories', 2, MealPage),
    ('workout', 1, WorkoutsScreen),
    ('bmi', 4, ProfilePage),
    ('plan-workout', 1, WorkoutsScreen),
    ('plan-nutrition', 2, MealPage),
    ('plan-grocery', 3, GroceryScreen),
  ]) {
    testWidgets('${action.$1} opens its existing tab without pushing a route', (
      tester,
    ) async {
      await startDashboard(tester);
      final target = find.byKey(ValueKey('dashboard-${action.$1}-action'));
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      final bounds = tester.getRect(target);
      expect(bounds.width, greaterThanOrEqualTo(48));
      expect(bounds.height, greaterThanOrEqualTo(48));
      expect(
        tester
            .getSemantics(target)
            .getSemanticsData()
            .hasAction(ui.SemanticsAction.tap),
        isTrue,
      );
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(find.byType(action.$3), findsOneWidget);
      expect(
        tester
            .widget<FloatingBottomNavigationBar>(
              find.byType(FloatingBottomNavigationBar),
            )
            .selectedIndex,
        action.$2,
      );
      expect(Navigator.canPop(tester.element(find.byType(action.$3))), isFalse);
      await tester.tap(
        find.descendant(
          of: find.byType(FloatingBottomNavigationBar),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final action in ['goal', 'weight']) {
    testWidgets(
      '$action opens Edit Profile and returned data refreshes dashboard calculations',
      (tester) async {
        final api = await startDashboard(tester);
        final target = find.byKey(ValueKey('dashboard-$action-action'));
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(find.byType(EditProfileScreen), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byType(TextField).at(0))
              .controller!
              .text,
          'Test User',
        );
        await tester.enterText(find.byType(TextField).at(3), '72.5');
        await tester.pumpAndSettle();
        final save = find.widgetWithText(ElevatedButton, 'SAVE CHANGES');
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        await tester.tap(save);
        await tester.pumpAndSettle();
        final dashboard = tester.widget<DashboardPage>(
          find.byType(DashboardPage),
        );
        expect(dashboard.user.weight, 72.5);
        expect(dashboard.user.bmi, api.updateRequest!.bmi);
        expect(
          dashboard.user.estimatedCalories,
          api.updateRequest!.estimatedCalories,
        );
        expect(DigiGymSession.currentUser!.weight, 72.5);
      },
    );
  }

  testWidgets(
    'adding dashboard callbacks preserves every rendered idle pixel',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final boundaryKey = GlobalKey();
      Future<Uint8List> capture(bool interactive) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: DigiGymDashboardTheme.dark(ThemeData(useMaterial3: true)),
            home: RepaintBoundary(
              key: boundaryKey,
              child: DashboardPage(
                user: testUser(),
                clock: () => DateTime(2026, 10, 24, 9),
                onSelectTab: interactive ? (_) {} : null,
                onEditProfile: interactive ? () {} : null,
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          for (final asset in [
            'assets/images/digigym_wordmark.png',
            'assets/images/digigym_workout_icon.png',
            'assets/icons/biceps_flexed.png',
          ]) {
            await precacheImage(
              AssetImage(asset),
              tester.element(find.byType(DashboardPage)),
            );
          }
        });
        await tester.pumpAndSettle();
        final image = await tester.runAsync(
          () =>
              (boundaryKey.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(),
        );
        final data = await tester.runAsync(() => image!.toByteData());
        image!.dispose();
        return data!.buffer.asUint8List();
      }

      final original = await capture(false);
      final interactive = await capture(true);
      expect(interactive, orderedEquals(original));
      expect(find.byType(DashboardCardAction), findsNWidgets(8));
    },
  );
}
