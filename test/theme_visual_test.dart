import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/widgets/monthly_activity_calendar.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:digigym/widgets/soft_glow_icon.dart';
import 'package:digigym/widgets/daily_streak_indicator.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dashboard_appearance_test.dart' as fixtures;
import 'support/golden_region_checks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final font in {
      DigiGymDashboardTheme.textFont: 'assets/fonts/Inter-Variable.ttf',
      DigiGymDashboardTheme.numberFont: 'assets/fonts/Doto-Variable.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
    // Flutter's test engine has no native San Francisco font. Use bundled
    // Inter under the iOS aliases for readable, portable visual fixtures only.
    for (final family in ['CupertinoSystemText', 'CupertinoSystemDisplay']) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'))).load();
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
      final bytes = await File(
        '${sdk.path}/bin/cache/artifacts/material_fonts/Roboto-$face.ttf',
      ).readAsBytes();
      roboto.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await roboto.load();
  });

  for (final light in [false, true]) {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets(
        '${light ? 'Restored light navigation and calorie shadow' : 'Unchanged dark appearance'} ${platform.name}',
        (tester) async {
          final shadows = debugDisableShadows;
          final originalPlatform = debugDefaultTargetPlatformOverride;
          debugDisableShadows = false;
          debugDefaultTargetPlatformOverride = platform;
          try {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = const Size(426, 952);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              fixtures.dashboard(
                theme: light
                    ? DigiGymDashboardTheme.light(
                        ThemeData(
                          useMaterial3: true,
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: Colors.green,
                          ),
                          scaffoldBackgroundColor: const Color(0xFFF5F7F5),
                        ),
                      )
                    : null,
                safeArea: platform == TargetPlatform.iOS
                    ? const EdgeInsets.only(top: 59, bottom: 34)
                    : const EdgeInsets.only(top: 52, bottom: 24),
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
            await _expectProtectedAppearance(tester, platform, light: light);
            await _expectTypographyCorrectionPreserved(
              tester,
              platform,
              light: light,
            );
            if (light) {
              await expectOnlyRegionsChanged(
                tester,
                find.byType(HomeScreen),
                reference:
                    'test/goldens/dashboard_sprint3_light_calorie_shadow_${platform.name}.png',
                regions: [
                  tester.getRect(
                    find.descendant(
                      of: find.byType(FloatingBottomNavigationBar),
                      matching: find.byType(BackdropFilter),
                    ),
                  ),
                ],
                reason: 'Home background, cards, icons, flame and typography must remain unchanged outside shared navigation.',
              );
            }
            await expectLater(
              find.byType(HomeScreen),
              matchesGoldenFile(
                'goldens/dashboard_sprint3_${light ? 'light_nav30' : 'dark_typography_correction'}_${platform.name}.png',
              ),
            );
            if (light) {
              await tester.tap(
                find.byKey(const ValueKey('dashboard-bmi-action')),
              );
              await tester.pumpAndSettle();
              await expectOnlyRegionsChanged(
                tester,
                find.byType(MaterialApp),
                reference:
                    'test/goldens/dashboard_sprint3_light_bmi_calorie_shadow_${platform.name}.png',
                regions: [
                  tester.getRect(
                    find.descendant(
                      of: find.byType(FloatingBottomNavigationBar),
                      matching: find.byType(BackdropFilter),
                    ),
                  ),
                ],
                reason: 'The BMI popup and all content outside navigation must remain unchanged.',
              );
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile(
                  'goldens/dashboard_sprint3_light_bmi_nav30_${platform.name}.png',
                ),
              );
            }
            expect(tester.takeException(), isNull);
          } finally {
            debugDisableShadows = shadows;
            debugDefaultTargetPlatformOverride = originalPlatform;
          }
        },
      );
    }
  }
  testWidgets(
    'Android and iOS retain responsive geometry and contain enlarged numerals',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final originalPlatform = debugDefaultTargetPlatformOverride;
      try {
        for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
          debugDefaultTargetPlatformOverride = platform;
          for (final size in [
            const Size(320, 640),
            const Size(390, 844),
            const Size(426, 952),
          ]) {
            tester.view.physicalSize = size;
            for (final scale in [1.0, 2.0, 3.0]) {
              List<Rect>? darkBounds;
              for (final light in [false, true]) {
                final base = ThemeData(useMaterial3: true);
                await tester.pumpWidget(
                  fixtures.dashboard(
                    theme: light
                        ? DigiGymDashboardTheme.light(base)
                        : DigiGymDashboardTheme.dark(base),
                    textScale: scale,
                    name: 'Alexandria Morgan Hernandez',
                    user: UserProfile(
                      name: 'Alexandria Morgan Hernandez',
                      email: 'layout@example.com',
                      age: 31,
                      height: 165,
                      weight: 999.9,
                      workoutTime: 125,
                      fitnessLevel: 'Intermediate',
                      fitnessGoal: 'Build Muscle',
                    ),
                  ),
                );
                await tester.pumpAndSettle();
                tester
                    .state<ScrollableState>(find.byType(Scrollable))
                    .position
                    .jumpTo(0);
                await tester.pumpAndSettle();
                final bounds = [
                  for (final key in [
                    'dashboard-wordmark',
                    'dashboard-progress-action',
                    'dashboard-workout-action',
                    'dashboard-statistics-panel',
                  ])
                    tester.getRect(find.byKey(ValueKey(key))),
                  tester.getRect(find.byType(FloatingBottomNavigationBar)),
                  tester.getRect(find.byType(MonthlyActivityCalendar)),
                ];
                if (!light) {
                  darkBounds = bounds;
                } else {
                  expect(bounds, darkBounds, reason: '$size at $scale');
                }
                await tester.ensureVisible(
                  find.byKey(const ValueKey('month-day-2026-10-31')),
                );
                await tester.pumpAndSettle();
                final calendar = find.byType(MonthlyActivityCalendar);
                final calendarCard = tester.getRect(
                  find.descendant(
                    of: calendar,
                    matching: find.byType(DashboardGlassCard),
                  ),
                );
                final date = tester.getRect(
                  find.byKey(const ValueKey('activity-date')),
                );
                final month = tester.getRect(
                  find.byKey(const ValueKey('activity-month')),
                );
                expect(calendarCard.contains(date.topLeft), isTrue);
                expect(calendarCard.contains(date.bottomRight), isTrue);
                expect(date.top, greaterThanOrEqualTo(month.bottom));
                for (final element in find.byType(DashboardNumber).evaluate()) {
                  final number = find.byWidget(element.widget);
                  final rendered = tester.getRect(
                    find
                        .descendant(
                          of: number,
                          matching: find.byType(DotMatrixText),
                        )
                        .first,
                  );
                  final slot = tester.getRect(number);
                  expect(rendered.left, greaterThanOrEqualTo(slot.left - .01));
                  expect(rendered.right, lessThanOrEqualTo(slot.right + .01));
                  expect(rendered.top, greaterThanOrEqualTo(slot.top - .01));
                  expect(rendered.bottom, lessThanOrEqualTo(slot.bottom + .01));
                }
                expect(
                  tester.takeException(),
                  isNull,
                  reason: '$size at $scale / light=$light',
                );
              }
            }
          }
        }
      } finally {
        debugDefaultTargetPlatformOverride = originalPlatform;
      }
    },
  );
}

/// Stage 1C typography is restored everywhere except the three statistics.
/// Light Stage 1D icon, flame and navigation improvements remain allowed here;
/// the separate pre-experiment check freezes everything outside Stage 1E regions.
Future<void> _expectProtectedAppearance(
  WidgetTester tester,
  TargetPlatform platform, {
  required bool light,
}) async {
  final fixtures = jsonDecode(
    File('test/fixtures/dashboard_stage1b_visual_regions.json')
        .readAsStringSync(),
  ) as Map;
  final baseline = fixtures[platform.name] as Map;
  Rect rect(List values) => Rect.fromLTRB(
    (values[0] as num).toDouble(),
    (values[1] as num).toDouble(),
    (values[2] as num).toDouble(),
    (values[3] as num).toDouble(),
  );
  final layout = baseline['layout'] as Map;
  for (final entry in layout.entries) {
    final finder = switch (entry.key) {
      'navigation' => find.byType(FloatingBottomNavigationBar),
      'calendar' => find.byType(MonthlyActivityCalendar),
      _ => find.byKey(ValueKey(entry.key as String)),
    };
    expect(
      tester.getRect(finder),
      rect(entry.value as List),
      reason: '${platform.name}: ${entry.key} geometry',
    );
  }
  final masks = [
    for (final value in (baseline['numerals'] as List).skip(1).take(3))
      rect(value as List).inflate(1),
    for (final element
        in find
            .byWidgetPredicate(
              (w) => w is DashboardNumber && w.statisticTypography,
            )
            .evaluate())
      tester.getRect(find.byWidget(element.widget)).inflate(1),
    if (light) ...[
      tester.getRect(find.byType(FloatingBottomNavigationBar)),
      for (final type in [SoftGlowIcon, DailyStreakIndicator])
        for (final element in find.byType(type).evaluate())
          tester.getRect(find.byWidget(element.widget)).inflate(10),
    ],
  ];
  await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(
      await File(
        'test/goldens/dashboard_sprint3_${light ? 'light' : 'dark_stage1c'}_${platform.name}.png',
      ).readAsBytes(),
    );
    final before = (await codec.getNextFrame()).image;
    final after = await captureImage(tester.element(find.byType(HomeScreen)));
    try {
      expect(after.width, before.width);
      expect(after.height, before.height);
      final oldBytes = (await before.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      final newBytes = (await after.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      var changedOutsideNumerals = 0;
      for (var y = 0; y < after.height; y++) {
        for (var x = 0; x < after.width; x++) {
          if (masks.any((mask) => mask.contains(Offset(x + .5, y + .5)))) {
            continue;
          }
          final pixel = (y * after.width + x) * 4;
          if ([0, 1, 2, 3].any(
            (channel) => oldBytes[pixel + channel] != newBytes[pixel + channel],
          )) {
            changedOutsideNumerals++;
          }
        }
      }
      expect(
        changedOutsideNumerals,
        0,
        reason: light
            ? 'Stage 1C typography, silver background, cards and layout must match exactly outside the three statistics and Stage 1D icon/flame/navigation regions.'
            : 'Every dark pixel outside the three statistics must match Stage 1C, including progress, monthly date and workout typography.',
      );
    } finally {
      before.dispose();
      after.dispose();
      codec.dispose();
    }
  });
}

/// The accepted typography correction is frozen, along with all other visuals
/// outside the light calorie shadow. Statistics also
/// retain their checked 5% reduction relative to the Stage 1D geometry fixture.
Future<void> _expectTypographyCorrectionPreserved(
  WidgetTester tester,
  TargetPlatform platform, {
  required bool light,
}) async {
  final data = jsonDecode(
    File('test/fixtures/dashboard_stage1d_numeral_regions.json')
        .readAsStringSync(),
  ) as Map;
  final baseline = data['${light ? 'light' : 'dark'}-${platform.name}'] as Map;
  Rect rect(List values) => Rect.fromLTRB(
    (values[0] as num).toDouble(),
    (values[1] as num).toDouble(),
    (values[2] as num).toDouble(),
    (values[3] as num).toDouble(),
  );
  final masks = <Rect>[];
  for (final element in find.byType(DashboardNumber).evaluate()) {
    final widget = element.widget as DashboardNumber;
    final number = find.byWidget(widget);
    final previous = baseline[widget.value] as Map;
    final slot = tester.getRect(number);
    expect(slot, rect(previous['slot'] as List));
    if (widget.statisticTypography) {
      final digits = tester.getRect(
        find.descendant(of: number, matching: find.byType(DotMatrixText)),
      );
      final oldDigits = rect(previous['digits'] as List);
      expect(
        digits.height / oldDigits.height,
        closeTo(.95, .000001),
        reason: widget.value,
      );
      expect(
        digits.width / oldDigits.width,
        closeTo(.95, .000001),
        reason: widget.value,
      );
      expect(digits.left, closeTo(oldDigits.left, .000001));
      expect(digits.bottom, closeTo(oldDigits.bottom, .000001));
      final units = find
          .descendant(of: number, matching: find.byType(Text))
          .evaluate()
          .toList();
      final oldUnits = previous['units'] as List;
      expect(units.length, oldUnits.length);
      for (var i = 0; i < units.length; i++) {
        expect(
          tester.getRect(find.byWidget(units[i].widget)),
          rect(oldUnits[i] as List),
          reason: '${widget.value} unit alignment',
        );
      }
    }
  }
  if (light) {
    final calorie = find.descendant(
      of: find.byKey(const ValueKey('dashboard-calories-action')),
      matching: find.byType(SoftGlowIcon),
    );
    masks.add(tester.getRect(calorie).inflate(4));
    masks.add(
      tester.getRect(
        find.descendant(
          of: find.byType(FloatingBottomNavigationBar),
          matching: find.byType(BackdropFilter),
        ),
      ),
    );
  }
  await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(
      await File(
        'test/goldens/dashboard_sprint3_${light ? 'light' : 'dark'}_typography_correction_${platform.name}.png',
      ).readAsBytes(),
    );
    final before = (await codec.getNextFrame()).image;
    final after = await captureImage(tester.element(find.byType(HomeScreen)));
    try {
      final oldBytes = (await before.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      final newBytes = (await after.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      var changed = 0;
      final changedPixels = <Offset>[];
      for (var y = 0; y < after.height; y++) {
        for (var x = 0; x < after.width; x++) {
          if (masks.any((mask) => mask.contains(Offset(x + .5, y + .5)))) {
            continue;
          }
          final pixel = (y * after.width + x) * 4;
          if ([0, 1, 2, 3].any(
            (channel) => oldBytes[pixel + channel] != newBytes[pixel + channel],
          )) {
            changed++;
            if (changedPixels.length < 60) {
              changedPixels.add(Offset(x.toDouble(), y.toDouble()));
            }
          }
        }
      }
      expect(
        changed,
        0,
        reason:
            'All pre-Stage-1E pixels outside the calorie shadow must match exactly, including active/inactive navigation, typography, streak, other icons, glass and background. First differences: $changedPixels',
      );
    } finally {
      before.dispose();
      after.dispose();
      codec.dispose();
    }
  });
}
