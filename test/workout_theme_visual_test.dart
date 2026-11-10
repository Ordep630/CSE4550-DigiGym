import 'dart:convert';
import 'dart:io';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/services/workout_schedule_controller.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/recommended_workout_glass_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';
import 'support/golden_region_checks.dart';
import 'workouts_screen_test.dart' as actions;

Future<void> loadWorkoutVisualFonts() async {
  for (final font in {
    DigiGymDashboardTheme.textFont: 'assets/fonts/Inter-Variable.ttf',
    DigiGymDashboardTheme.numberFont: 'assets/fonts/Doto-Variable.ttf',
    'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    'CupertinoSystemText': 'assets/fonts/Inter-Variable.ttf',
    'CupertinoSystemDisplay': 'assets/fonts/Inter-Variable.ttf',
  }.entries) {
    await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
  }
  final configuration = File('.dart_tool/package_config.json');
  final packages =
      jsonDecode(await configuration.readAsString())['packages'] as List;
  final flutter = packages.firstWhere((entry) => entry['name'] == 'flutter');
  final sdk = Directory.fromUri(
    configuration.uri.resolve(flutter['rootUri'] as String),
  ).parent.parent;
  final roboto = FontLoader('Roboto');
  for (final face in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(
      Future.value(
        ByteData.sublistView(
          await File(
            '${sdk.path}/bin/cache/artifacts/material_fonts/Roboto-$face.ttf',
          ).readAsBytes(),
        ),
      ),
    );
  }
  await roboto.load();
}

Future<WorkoutScheduleController> pumpWorkoutTheme(
  WidgetTester tester, {
  required bool light,
  TargetPlatform platform = TargetPlatform.android,
  double scale = 1,
  bool configured = true,
  UserProfile? user,
}) async {
  final profile = user ?? actions.profile();
  final api = FakeDigiGymApi()
    ..authenticated = true
    ..restoredProfile = profile;
  final schedule = WorkoutScheduleController(
    accountId: profile.accountId,
    api: api,
  );
  addTearDown(schedule.dispose);
  await schedule.initialize();
  if (configured) await schedule.save({0, 2, 4});
  final base = ThemeData(useMaterial3: true, platform: platform);
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      debugShowCheckedModeBanner: false,
      theme: light
          ? DigiGymDashboardTheme.light(base)
          : DigiGymDashboardTheme.dark(base),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: platform == TargetPlatform.iOS
              ? const EdgeInsets.only(top: 59, bottom: 34)
              : const EdgeInsets.only(top: 52, bottom: 24),
          textScaler: TextScaler.linear(scale),
        ),
        child: child!,
      ),
      home: HomeScreen(
        user: profile,
        api: api,
        workoutSchedule: schedule,
        clock: () => DateTime(2026, 10, 25, 9),
        onLogout: () async {},
        onUpdateProfile: (_) {},
      ),
    ),
  );
  await tester.runAsync(() async {
    for (final asset in [
      'assets/images/digigym_workout_icon.png',
      'assets/images/digigym_wordmark.png',
    ]) {
      await precacheImage(
        AssetImage(asset),
        tester.element(find.byType(HomeScreen)),
      );
    }
  });
  await tester.pumpAndSettle();
  await actions.tab(tester, 'Workout');
  return schedule;
}

Future<void> showWorkoutVisualState(WidgetTester tester, String state) async {
  switch (state) {
    case 'my_plan':
    case 'unconfigured':
      break;
    case 'weekly_preview':
      await actions.activate(tester, 'workout-edit-schedule');
      await tester.tap(find.byKey(const ValueKey('schedule-cancel')));
      await tester.pumpAndSettle();
      break;
    case 'exercises':
    case 'expanded':
      await actions.activate(tester, 'workout-view-exercises');
      if (state == 'expanded') {
        await tester.tap(find.byType(ExpansionTile).first);
        await tester.pumpAndSettle();
      }
      break;
    case 'more':
      await actions.activate(tester, 'workout-view-moreWorkouts');
      break;
    case 'exercise_route':
      await actions.activate(tester, 'workout-featured-exercises');
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      break;
    case 'walkthrough':
      await actions.activate(tester, 'workout-start');
      break;
    case 'schedule_editor':
      await actions.activate(tester, 'workout-edit-schedule');
      break;
    case 'day_dialog':
      final day = find.byKey(const ValueKey('week-day-2026-10-25'));
      await tester.ensureVisible(day);
      await tester.pumpAndSettle();
      await tester.tap(day);
      await tester.pumpAndSettle();
      break;
  }
}

const workoutVisualStates = [
  'my_plan',
  'weekly_preview',
  'exercises',
  'expanded',
  'more',
  'exercise_route',
  'walkthrough',
  'schedule_editor',
  'day_dialog',
  'unconfigured',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadWorkoutVisualFonts);
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    final darkGeometry = <String, List<Rect>>{};
    for (final light in [false, true]) {
      testWidgets(
        '${light ? 'Light' : 'Protected dark'} Workout states ${platform.name}',
        (tester) async {
          final shadows = debugDisableShadows;
          debugDisableShadows = false;
          try {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = const Size(426, 952);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(tester.view.resetPhysicalSize);
            for (final state in workoutVisualStates) {
              await pumpWorkoutTheme(
                tester,
                light: light,
                platform: platform,
                configured: state != 'unconfigured',
              );
              await showWorkoutVisualState(tester, state);
              final geometry = [
                for (final key in [
                  'workout-featured',
                  'workout-view-myPlan',
                  'workout-view-exercises',
                  'workout-view-moreWorkouts',
                  'workout-walkthrough-step',
                ])
                  if (find.byKey(ValueKey(key)).evaluate().isNotEmpty)
                    tester.getRect(find.byKey(ValueKey(key))),
                for (final type in [
                  FloatingBottomNavigationBar,
                  Dialog,
                  DashboardGlassCard,
                ])
                  for (final element in find.byType(type).evaluate())
                    tester.getRect(find.byWidget(element.widget)),
              ];
              if (!light) {
                darkGeometry[state] = geometry;
              } else if (darkGeometry.containsKey(state)) {
                expect(
                  geometry,
                  darkGeometry[state],
                  reason: '$state preserves layout across themes',
                );
              }
              if (light) {
                // Only this experiment's recommendation interior may change.
                // All other cards must match the immediately prior captures.
                final cardRegions = [
                  for (final element
                      in find.byType(RecommendedWorkoutGlassCard).evaluate())
                    tester.getRect(
                      find
                          .descendant(
                            of: find.byWidget(element.widget),
                            matching: find.byType(ClipRRect),
                          )
                          .first,
                    ),
                ];
                // Include one raster pixel for fractional clip-edge coverage.
                final regions = <Rect>[
                  for (final card in cardRegions) card.inflate(1),
                ];
                final navigation = find.byType(FloatingBottomNavigationBar);
                if (navigation.evaluate().isNotEmpty) {
                  final navGlass = tester.getRect(
                    find.descendant(
                      of: navigation,
                      matching: find.byType(BackdropFilter),
                    ),
                  );
                  if (cardRegions.any(
                    (card) => card.inflate(3 * 16).overlaps(navGlass),
                  )) {
                    regions.add(navGlass);
                  }
                }
                final dialog = find.byType(Dialog);
                if (dialog.evaluate().isNotEmpty &&
                    find
                        .descendant(
                          of: dialog,
                          matching: find.byType(BackdropFilter),
                        )
                        .evaluate()
                        .isNotEmpty) {
                  final popup = tester.getRect(dialog);
                  for (final card in cardRegions) {
                    regions.add(
                      card
                          .inflate(3 * DigiGymSurfaces.light.bmiBackdropSigma)
                          .intersect(popup),
                    );
                  }
                }
                await expectOnlyRegionsChanged(
                  tester,
                  find.byType(MaterialApp),
                  reference:
                      'test/goldens/workout_light_stage2a_glass_${state}_${platform.name}.png',
                  regions: regions,
                  reason: 'Only the Recommended Workout glass and its contribution to existing frost may change; every other card, navigation, header and background must match.',
                );
              }
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile(
                  'goldens/workout_${!light
                      ? 'dark_stage2a_baseline'
                      : find.byType(RecommendedWorkoutGlassCard).evaluate().isNotEmpty
                      ? 'light_recommended_glass'
                      : 'light_stage2a_glass'}_${state}_${platform.name}.png',
                ),
              );
              expect(tester.takeException(), isNull, reason: state);
            }
          } finally {
            debugDisableShadows = shadows;
          }
        },
      );
    }
  }
}
