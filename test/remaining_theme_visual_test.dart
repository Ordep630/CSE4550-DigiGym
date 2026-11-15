import 'package:digigym/screens/coming_soon_screen.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/services/meal_recommendation_service.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/utils/measurement_units.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';
import 'meals_groceries_screen_test.dart' as shopping;
import 'workout_theme_visual_test.dart' as fixtures;
import 'workouts_screen_test.dart' as actions;

Future<void> openThemeScene(
  WidgetTester tester,
  String scene, {
  required bool light,
  required TargetPlatform platform,
  double scale = 1,
}) async {
  if (scene == 'login') {
    final base = ThemeData(useMaterial3: true, platform: platform);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: light
            ? DigiGymDashboardTheme.light(base)
            : DigiGymDashboardTheme.dark(base),
        home: LoginScreen(api: FakeDigiGymApi(), onLogin: (_) {}),
      ),
    );
    await tester.runAsync(() async {
      for (final asset in ['digigym_workout_icon', 'digigym_wordmark']) {
        await precacheImage(
          AssetImage('assets/images/$asset.png'),
          tester.element(find.byType(LoginScreen)),
        );
      }
    });
    await tester.pumpAndSettle();
    return;
  }
  await fixtures.pumpWorkoutTheme(
    tester,
    light: light,
    platform: platform,
    scale: scale,
  );
  if (scene.startsWith('meal')) {
    await actions.tab(tester, 'Meals');
  } else if (scene.startsWith('grocer')) {
    await actions.tab(tester, 'Groceries');
  } else {
    await actions.tab(tester, 'Profile');
  }
  final target = switch (scene) {
    'meal_details' => find.byKey(
      ValueKey(
        'meal-${const MealRecommendationService().recommend(actions.profile()).first.id}',
      ),
    ),
    'grocery_dialog' => find.byKey(const ValueKey('grocery-add')),
    'profile_details' => find.byKey(const ValueKey('profile-user-card')),
    'profile_edit' => find.text('Edit Profile'),
    'profile_logout' => find.text('Log Out'),
    _ => null,
  };
  if (target != null) {
    if (scale > 1) {
      await shopping.press(tester, target);
      return;
    }
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }
}

const _scenes = [
  'meals',
  'meal_details',
  'groceries',
  'grocery_dialog',
  'profile',
  'profile_details',
  'profile_edit',
  'profile_logout',
  'login',
];

void main() {
  setUpAll(fixtures.loadWorkoutVisualFonts);
  testWidgets('remaining screens keep numeric text and painted glyph metrics', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(426, 952);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    TextStyle metrics(Finder finder) {
      final context = tester.element(finder);
      final text = tester.widget<Text>(finder);
      final style = DefaultTextStyle.of(context).style.merge(text.style);
      return TextStyle(
        fontFamily: style.fontFamily,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
        letterSpacing: style.letterSpacing,
        height: style.height,
        fontVariations: style.fontVariations,
      );
    }

    final snapshots = <List<Object?>>[];
    for (final light in [false, true]) {
      await openThemeScene(
        tester,
        'meals',
        light: light,
        platform: TargetPlatform.android,
      );
      final calorieTarget = find.byKey(const ValueKey('meal-calorie-target'));
      final dots = tester.widget<DotMatrixText>(
        find.descendant(
          of: calorieTarget,
          matching: find.byType(DotMatrixText),
        ),
      );
      final regularCalories = tester
          .widgetList<DashboardNumber>(find.byType(DashboardNumber))
          .where((number) => !number.dotted)
          .first;
      final regularSpans =
          tester
                  .widget<Text>(
                    find.descendant(
                      of: find.byWidget(regularCalories),
                      matching: find.byType(Text),
                    ),
                  )
                  .textSpan!
              as TextSpan;
      final calorieStyles = regularSpans.children!.cast<TextSpan>().map(
        (span) => (
          span.text,
          span.style!.fontFamily,
          span.style!.fontSize,
          span.style!.fontWeight,
        ),
      );
      expect(
        tester.widgetList<DotMatrixText>(find.byType(DotMatrixText)),
        hasLength(1),
      );
      await actions.tab(tester, 'Groceries');
      expect(find.byType(DotMatrixText), findsNothing);
      final quantity = metrics(find.text('2.5 oz'));
      await actions.tab(tester, 'Profile');
      await shopping.press(
        tester,
        find.byKey(const ValueKey('profile-user-card')),
      );
      final weight = find.text(
        MeasurementUnits.formatWeight(actions.profile().weight),
      );
      expect(find.byType(DotMatrixText), findsNothing);
      snapshots.add([
        dots.text,
        dots.height,
        dots.fillRatio,
        dots.softenedDigits,
        ...calorieStyles,
        quantity,
        metrics(weight),
      ]);
      expect(tester.takeException(), isNull);
    }
    expect(snapshots.last, snapshots.first);
  });

  testWidgets('light profile details and edit choices fit at 3x text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await openThemeScene(
      tester,
      'profile_details',
      light: true,
      platform: TargetPlatform.iOS,
      scale: 3,
    );
    final weight = find.text(
      MeasurementUnits.formatWeight(actions.profile().weight),
    );
    await tester.ensureVisible(weight);
    await tester.pumpAndSettle();
    expect(weight.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await openThemeScene(
      tester,
      'profile_edit',
      light: true,
      platform: TargetPlatform.iOS,
      scale: 3,
    );
    final field = find.byType(DropdownButtonFormField<String>).first;
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beginner').last);
    await tester.pumpAndSettle();
    expect(find.text('Beginner'), findsOneWidget);
    final save = find.widgetWithText(ElevatedButton, 'SAVE CHANGES');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'light login routes and profile placeholders inherit the palette',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(426, 952);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await openThemeScene(
        tester,
        'login',
        light: true,
        platform: TargetPlatform.android,
      );
      for (final link in ['Sign Up', 'Forgot Password?']) {
        await tester.tap(find.text(link));
        await tester.pumpAndSettle();
        final field = find.byType(TextField).first;
        final theme = Theme.of(tester.element(field));
        expect(theme.brightness, Brightness.light);
        expect(theme.colorScheme.primary, DigiGymSurfaces.light.accent);
        expect(tester.takeException(), isNull);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      await openThemeScene(
        tester,
        'profile',
        light: true,
        platform: TargetPlatform.android,
      );
      await shopping.press(tester, find.text('Preferences'));
      final artwork = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image ==
                const AssetImage(ComingSoonScreen.illustrationAsset),
      );
      expect(Theme.of(tester.element(artwork)).brightness, Brightness.light);
      expect(tester.takeException(), isNull);
    },
  );

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final light in [false, true]) {
      testWidgets(
        '${light ? 'Light' : 'Protected dark'} remaining screens ${platform.name}',
        (tester) async {
          final shadows = debugDisableShadows;
          debugDisableShadows = false;
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(426, 952);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          try {
            for (final scene in _scenes) {
              await openThemeScene(
                tester,
                scene,
                light: light,
                platform: platform,
              );
              expect(tester.takeException(), isNull, reason: scene);
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile(
                  'goldens/remaining_${light ? 'light' : 'dark_baseline'}_${scene}_${platform.name}.png',
                ),
              );
            }
          } finally {
            debugDisableShadows = shadows;
          }
        },
      );
    }
  }
}
