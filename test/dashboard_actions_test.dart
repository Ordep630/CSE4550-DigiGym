import 'dart:ui' as ui;

import 'package:digigym/main.dart';
import 'package:digigym/models/session.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/screens/edit_profile_screen.dart';
import 'package:digigym/screens/meal_page.dart';
import 'package:digigym/screens/workouts_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/dashboard_card_action.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/monthly_activity_calendar.dart';
import 'package:digigym/widgets/soft_glow_icon.dart';
import 'package:digigym/widgets/stat_card.dart';
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
    ('progress', 1, WorkoutsScreen),
    ('calories', 2, MealPage),
    ('workout', 1, WorkoutsScreen),
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

  testWidgets(
    'Home statistic icons use larger glyphs and faint borderless wells',
    (tester) async {
      await startDashboard(tester);
      final rows = find.byType(StatCard);
      expect(rows, findsNWidgets(4));
      for (final row in rows.evaluate()) {
        final card = row.widget as StatCard;
        final content = find.byWidget(card);
        final glow = find.descendant(
          of: content,
          matching: find.byType(SoftGlowIcon),
        );
        expect(glow, findsOneWidget);
        expect(
          find.descendant(
            of: content,
            matching: find.byType(DashboardIconBadge),
          ),
          findsNothing,
        );
        expect(tester.getSize(glow), const Size(32, 32));
        expect(tester.widget<SoftGlowIcon>(glow).glowIntensity, .82);
        final icon = tester.widget<Icon>(
          find.descendant(of: glow, matching: find.byType(Icon)),
        );
        expect(icon.icon, card.icon);
        expect(icon.size, closeTo(32 * .64, .001));
        expect(icon.size! / (32 * .52), inInclusiveRange(1.20, 1.25));
        expect(
          icon.color,
          card.title == 'Daily calorie target'
              ? SoftGlowIcon.warmAmber
              : DigiGymDarkColors.softGreen,
        );
        expect(icon.shadows, isNotEmpty);
        expect(icon.shadows!.first.color.a, closeTo(.22 * .82, .005));
        final well =
            tester
                    .widget<DecoratedBox>(
                      find.descendant(
                        of: glow,
                        matching: find.byType(DecoratedBox),
                      ),
                    )
                    .decoration
                as BoxDecoration;
        expect(well.shape, BoxShape.circle);
        expect(well.border, isNull);
        expect(well.color, isNull);
        expect(well.gradient!.colors.every((color) => color.a <= .17), isTrue);
        expect(well.gradient!.colors.last.a, 0);
        expect(well.boxShadow!.every((shadow) => shadow.color.a <= .1), isTrue);
        expect(well.boxShadow!.single.color.a, closeTo(.09 * .82, .005));
        expect(
          tester
              .widget<IgnorePointer>(
                find.descendant(of: glow, matching: find.byType(IgnorePointer)),
              )
              .ignoring,
          isTrue,
        );
      }
    },
  );

  testWidgets('glow opt-in preserves stat geometry and the default badge', (
    tester,
  ) async {
    Future<(Rect, Offset)> render(bool glowOnly) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DigiGymDashboardTheme.dark(ThemeData(useMaterial3: true)),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: StatCard(
                  title: 'Workout',
                  value: '30 min',
                  icon: Icons.fitness_center,
                  dotted: false,
                  iconGlowOnly: glowOnly,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(DashboardIconBadge),
        glowOnly ? findsNothing : findsOneWidget,
      );
      return (
        tester.getRect(find.byType(StatCard)),
        tester.getCenter(find.byIcon(Icons.fitness_center)),
      );
    }

    final original = await render(false);
    expect(await render(true), original);
    expect(tester.takeException(), isNull);
  });

  testWidgets('only requested Home calendar accents use the Login soft green', (
    tester,
  ) async {
    await startDashboard(tester);
    expect(DigiGymDarkColors.softGreen, const Color(0xFF67E780));
    final seeAll = tester.widget<TextButton>(
      find.byKey(const ValueKey('dashboard-week-see-all')),
    );
    expect(
      seeAll.style!.foregroundColor!.resolve({}),
      DigiGymDarkColors.softGreen,
    );
    expect(
      seeAll.style!.foregroundColor!.resolve({WidgetState.disabled}),
      DigiGymDarkColors.softGreen,
    );
    final monthly = find.byType(MonthlyActivityCalendar);
    expect(
      tester
          .widget<DotMatrixText>(
            find.descendant(
              of: monthly,
              matching: find.byKey(const ValueKey('activity-date')),
            ),
          )
          .color,
      DigiGymDarkColors.softGreen,
    );
    final today = find.byKey(const ValueKey('month-day-2026-10-24'));
    final well =
        tester
                .widget<Container>(
                  find.descendant(of: today, matching: find.byType(Container)),
                )
                .decoration
            as BoxDecoration;
    expect(
      (well.border! as Border).top.color,
      DigiGymDarkColors.softGreen.withValues(alpha: .45),
    );
    expect(well.color, DigiGymDarkColors.softGreen.withValues(alpha: .06));
    // The current-day ring uses the softer green without a brighter fill.
    final weekBadge =
        tester
                .widget<Container>(
                  find.byKey(const ValueKey('week-badge-2026-10-24')),
                )
                .decoration
            as BoxDecoration;
    expect(
      (weekBadge.border! as Border).top.color,
      DigiGymDarkColors.softGreen.withValues(alpha: .65),
    );
    expect((weekBadge.border! as Border).top.width, 1);
    expect(
      weekBadge.color,
      DigiGymDarkColors.primaryText.withValues(alpha: .035),
    );
    expect(
      weekBadge.boxShadow!.single.color,
      DigiGymDarkColors.softGreen.withValues(alpha: .09),
    );
    expect(weekBadge.boxShadow!.single.blurRadius, 12);
    final initial = tester.widget<Text>(
      find.byKey(const ValueKey('week-label-2026-10-24')),
    );
    expect(initial.style!.color, DigiGymDarkColors.softGreen);
    expect(initial.style!.shadows, isNotEmpty);
    expect(
      tester.getSize(find.byKey(const ValueKey('week-badge-2026-10-24'))),
      const Size(34, 34),
    );
    final otherDay =
        tester
                .widget<Container>(
                  find.byKey(const ValueKey('week-badge-2026-10-23')),
                )
                .decoration
            as BoxDecoration;
    expect(otherDay.boxShadow, isNull);
    expect(
      (otherDay.border! as Border).top.color,
      DigiGymDarkColors.primaryText.withValues(alpha: .10),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Your Week See All opens the existing Workout tab', (
    tester,
  ) async {
    await startDashboard(tester);
    final target = find.byKey(const ValueKey('dashboard-week-see-all'));
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutsScreen), findsOneWidget);
    expect(
      tester
          .widget<FloatingBottomNavigationBar>(
            find.byType(FloatingBottomNavigationBar),
          )
          .selectedIndex,
      1,
    );
    expect(
      Navigator.canPop(tester.element(find.byType(WorkoutsScreen))),
      isFalse,
    );
  });

  testWidgets(
    'unified statistics panel keeps three separate accessible actions',
    (tester) async {
      await startDashboard(tester);
      final panel = find.byKey(const ValueKey('dashboard-statistics-panel'));
      final rows = tester.widgetList<StatCard>(
        find.descendant(of: panel, matching: find.byType(StatCard)),
      );
      expect(rows.map((row) => row.title), [
        'Daily calorie target',
        'Weight',
        'BMI',
      ]);
      expect(
        find.descendant(of: panel, matching: find.byType(InkWell)),
        findsNWidgets(3),
      );
      for (final name in ['calories', 'weight', 'bmi']) {
        final action = find.byKey(ValueKey('dashboard-$name-action'));
        expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
        expect(
          tester
              .getSemantics(action)
              .getSemanticsData()
              .hasAction(ui.SemanticsAction.tap),
          isTrue,
        );
      }
    },
  );

  for (final action in ['weight']) {
    testWidgets(
      '$action dialog opens Edit Profile and returned data refreshes dashboard calculations',
      (tester) async {
        final api = await startDashboard(tester);
        final target = find.byKey(ValueKey('dashboard-$action-action'));
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(find.text('Your Weight'), findsOneWidget);
        expect(find.byType(EditProfileScreen), findsNothing);
        await tester.tap(find.text('Edit Weight'));
        await tester.pumpAndSettle();
        expect(find.byType(EditProfileScreen), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byType(TextField).at(0))
              .controller!
              .text,
          'Test User',
        );
        await tester.enterText(find.byKey(const ValueKey('weight-lb')), '160');
        await tester.pumpAndSettle();
        final save = find.widgetWithText(ElevatedButton, 'SAVE CHANGES');
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        await tester.tap(save);
        await tester.pumpAndSettle();
        final dashboard = tester.widget<DashboardPage>(
          find.byType(DashboardPage),
        );
        expect(dashboard.user.weight, closeTo(72.5747792, 1e-9));
        expect(dashboard.user.bmi, api.updateRequest!.bmi);
        expect(
          dashboard.user.estimatedCalories,
          api.updateRequest!.estimatedCalories,
        );
        expect(DigiGymSession.currentUser!.weight, closeTo(72.5747792, 1e-9));
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
      expect(find.byType(DashboardCardAction), findsNWidgets(5));
    },
  );
}
