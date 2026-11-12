import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/utils/bmi_category.dart';
import 'package:digigym/utils/measurement_units.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/dashboard_information_dialogs.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/stat_card.dart';
import 'package:digigym/screens/meal_page.dart';
import 'package:digigym/screens/meal_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

Future<void> _home(WidgetTester tester, {UserProfile? user}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(420, 912);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: HomeScreen(
        user: user ?? testUser(),
        api: FakeDigiGymApi(),
        onLogout: () async {},
        onUpdateProfile: (_) {},
        clock: () => DateTime(2026, 10, 27, 9),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapStat(WidgetTester tester, String name) async {
  final action = find.byKey(ValueKey('dashboard-$name-action'));
  await tester.ensureVisible(action);
  await tester.pumpAndSettle();
  await tester.tap(action);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'weight info uses actual imperial weight and Close preserves Home geometry',
    (tester) async {
      final user = testUser()..weight = 58;
      await _home(tester, user: user);
      final panel = find.byKey(const ValueKey('dashboard-statistics-panel'));
      final original = tester.getRect(panel);
      final nav = tester.getRect(find.byType(FloatingBottomNavigationBar));
      await _tapStat(tester, 'weight');
      expect(find.text('Your Weight'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(MeasurementUnits.formatWeight(user.weight)),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Your current weight is based on the information in your fitness profile.',
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(DashboardGlassCard),
        ),
        findsOneWidget,
      );
      final theme = Theme.of(tester.element(find.text('Your Weight')));
      expect(theme.brightness, Brightness.dark);
      expect(
        theme.textTheme.bodyMedium?.fontFamily,
        DigiGymDashboardTheme.textFont,
      );
      for (final label in ['Edit Weight', 'Close']) {
        expect(
          tester.getSize(find.widgetWithText(TextButton, label)).height,
          greaterThanOrEqualTo(48),
        );
      }
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(tester.getSize(panel), original.size);
      expect(tester.getRect(find.byType(FloatingBottomNavigationBar)), nav);
      expect(
        tester
            .widget<FloatingBottomNavigationBar>(
              find.byType(FloatingBottomNavigationBar),
            )
            .selectedIndex,
        0,
      );
    },
  );

  testWidgets(
    'BMI opens the adult category explanation without selecting Profile',
    (tester) async {
      final user = testUser()
        ..height = 200
        ..weight = 100;
      await _home(tester, user: user);
      await _tapStat(tester, 'bmi');
      expect(find.text('What is BMI?'), findsOneWidget);
      expect(
        find.text(
          'Body Mass Index (BMI) is a simple measurement that compares your weight to your height.',
        ),
        findsOneWidget,
      );
      for (final category in BmiCategory.values) {
        expect(find.text(category.range), findsOneWidget);
        final label = tester.widget<Text>(find.text(category.label));
        expect(
          label.style?.color,
          category == BmiCategory.overweight
              ? DigiGymDarkColors.softGreen
              : null,
        );
      }
      expect(find.text('Your BMI: 25.0 — Overweight'), findsOneWidget);
      expect(
        find.text(
          'BMI is a general screening tool and doesn’t directly measure body fat or overall health.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(
        tester
            .widget<FloatingBottomNavigationBar>(
              find.byType(FloatingBottomNavigationBar),
            )
            .selectedIndex,
        0,
      );
    },
  );

  testWidgets('unavailable BMI does not display a fabricated category', (
    tester,
  ) async {
    await _home(tester, user: testUser()..height = 0);
    final row = tester
        .widgetList<StatCard>(find.byType(StatCard))
        .singleWhere((row) => row.title == 'BMI');
    expect(row.value, 'Unavailable');
    await _tapStat(tester, 'bmi');
    expect(find.textContaining('Your BMI is unavailable'), findsOneWidget);
    for (final category in BmiCategory.values) {
      expect(
        tester.widget<Text>(find.text(category.label)).style?.color,
        isNull,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Home targets meal recommendations and nutrition details all use Cal',
    (tester) async {
      final user = testUser();
      await _home(tester, user: user);
      final calories = tester
          .widgetList<StatCard>(find.byType(StatCard))
          .singleWhere((card) => card.title == 'Daily calorie target');
      expect(calories.value, '${user.estimatedCalories} Cal');
      await _tapStat(tester, 'calories');
      final page = tester.widget<MealPage>(find.byType(MealPage));
      final meal = page.getMeals().first;
      final numbers = tester.widgetList<DashboardNumber>(
        find.byType(DashboardNumber),
      );
      expect(numbers.length, 4);
      expect(numbers.every((number) => number.value.endsWith(' Cal')), isTrue);
      for (final option in page.getMeals()) {
        expect(
          numbers.any((number) => number.value == '${option.calories} Cal'),
          isTrue,
        );
      }
      final first = find.byKey(ValueKey('meal-${meal.id}'));
      await tester.ensureVisible(first);
      await tester.pumpAndSettle();
      await tester.tap(first);
      await tester.pumpAndSettle();
      expect(find.byType(MealDetailsScreen), findsOneWidget);
      expect(
        tester.widget<DashboardNumber>(find.byType(DashboardNumber)).value,
        '${meal.calories} Cal',
      );
    },
  );

  testWidgets(
    'glass info dialogs scroll at narrow widths and through 3x text without overflow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [280.0, 320.0, 420.0]) {
        tester.view.physicalSize = Size(width, 640);
        for (final scale in [1.0, 2.0, 3.0]) {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: Column(
                    children: [
                      TextButton(
                        onPressed: () =>
                            showDashboardBmiDialog(context, bmi: double.nan),
                        child: const Text('BMI'),
                      ),
                      TextButton(
                        onPressed: () => showDashboardWeightDialog(
                          context,
                          weight: 123.456,
                          onEditWeight: () {},
                        ),
                        child: const Text('Weight'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          for (final (button, close) in [
            ('BMI', 'Got It'),
            ('Weight', 'Close'),
          ]) {
            await tester.tap(find.text(button));
            await tester.pumpAndSettle();
            final bounds = tester.getRect(find.byType(Dialog));
            expect(bounds.left, greaterThanOrEqualTo(0));
            expect(bounds.right, lessThanOrEqualTo(width));
            expect(
              find.widgetWithText(TextButton, close).hitTestable(),
              findsOneWidget,
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$button at $width / $scale',
            );
            final scroll = tester.state<ScrollableState>(
              find.descendant(
                of: find.byType(Dialog),
                matching: find.byType(Scrollable),
              ),
            );
            scroll.position.jumpTo(scroll.position.maxScrollExtent);
            await tester.pumpAndSettle();
            await tester.tap(find.widgetWithText(TextButton, close));
            await tester.pumpAndSettle();
            expect(find.byType(Dialog), findsNothing);
          }
        }
      }
    },
  );
}
