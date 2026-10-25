import 'dart:ui' as ui;

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/utils/measurement_units.dart';
import 'package:digigym/screens/edit_profile_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/screens/meal_page.dart';
import 'package:digigym/screens/profile_screen.dart';
import 'package:digigym/screens/profile_details_screen.dart';
import 'package:digigym/screens/workouts_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/digigym_atmospheric_background.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/profile_information.dart';
import 'package:digigym/widgets/monthly_activity_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

UserProfile profile({String level = 'Intermediate'}) => UserProfile(
  name: 'Isaac',
  email: 'test@example.com',
  age: 31,
  height: 174,
  weight: 58,
  fitnessLevel: level,
  fitnessGoal: 'Build Muscle',
  workoutTime: 30,
);

Widget host({
  UserProfile? user,
  double scale = 1,
  EdgeInsets insets = const EdgeInsets.only(top: 52, bottom: 24),
  TargetPlatform platform = TargetPlatform.android,
  FakeDigiGymApi? api,
  Future<void> Function()? onLogout,
  ValueChanged<UserProfile>? onUpdateProfile,
}) => MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    platform: platform,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    scaffoldBackgroundColor: const Color(0xFFF5F7F5),
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(padding: insets, textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: HomeScreen(
    user: user ?? profile(),
    api: api ?? FakeDigiGymApi(),
    onLogout: onLogout ?? () async {},
    onUpdateProfile: onUpdateProfile ?? (_) {},
  ),
);

Future<void> selectTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FloatingBottomNavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      DigiGymDashboardTheme.textFont,
    )..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'))).load();
  });

  testWidgets(
    'all tabs share one full-screen background and protected content',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1280, 2856);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final configuration in [
        (TargetPlatform.android, const EdgeInsets.only(top: 52, bottom: 24)),
        (TargetPlatform.iOS, const EdgeInsets.only(top: 59, bottom: 34)),
      ]) {
        await tester.pumpWidget(
          host(platform: configuration.$1, insets: configuration.$2),
        );
        await tester.pumpAndSettle();
        final initialNavigation = tester.getRect(
          find.byType(FloatingBottomNavigationBar),
        );
        final initialFilter = tester
            .widget<BackdropFilter>(find.byType(BackdropFilter))
            .filter;
        Material surface() => tester.widget<Material>(
          find.descendant(
            of: find.byType(BackdropFilter),
            matching: find.byType(Material),
          ),
        );
        final initialSurface = surface();
        final initialPill = tester.getRect(find.byType(BackdropFilter));
        for (final label in [
          'Home',
          'Workout',
          'Meals',
          'Groceries',
          'Profile',
        ]) {
          await selectTab(tester, label);
          expect(find.byType(DigiGymAtmosphericBackground), findsOneWidget);
          expect(
            tester.getRect(find.byType(DigiGymAtmosphericBackground)),
            Rect.fromLTWH(0, 0, 1280 / 3, 952),
          );
          final navigation = tester.getRect(
            find.byType(FloatingBottomNavigationBar),
          );
          expect(navigation, initialNavigation);
          expect(find.byType(BackdropFilter), findsOneWidget);
          expect(
            tester.widget<BackdropFilter>(find.byType(BackdropFilter)).filter,
            initialFilter,
          );
          expect(surface().color, initialSurface.color);
          expect(surface().shape, initialSurface.shape);
          expect(tester.getRect(find.byType(BackdropFilter)), initialPill);
          expect(
            Theme.of(tester.element(find.byType(FloatingBottomNavigationBar)))
                .brightness,
            Brightness.dark,
          );
          final viewport = tester.getRect(find.byType(Scrollable).first);
          expect(viewport.bottom, 952);
          if (label != 'Home') {
            final appBar = tester.getRect(find.byType(AppBar));
            expect(appBar.height, 56 + configuration.$2.top);
            expect(viewport.top, appBar.bottom);
            expect(find.byType(Card), findsNothing);
            if (label != 'Workout' && label != 'Profile') {
              for (final glass in tester.widgetList<DashboardGlassCard>(
                find.byType(DashboardGlassCard),
              )) {
                expect(glass.cornerRadius, 12);
                expect(glass.padding, EdgeInsets.zero);
              }
            }
          }
          expect(
            tester.takeException(),
            isNull,
            reason: '$label ${configuration.$1}',
          );
        }
      }
    },
  );

  testWidgets(
    'iPhone Home glass continues behind navigation and Monthly Activity scrolls clear',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(420, 912);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(
          platform: TargetPlatform.iOS,
          insets: const EdgeInsets.only(top: 62, bottom: 34),
        ),
      );
      await tester.pumpAndSettle();
      final navigation = tester.getRect(
        find.byType(FloatingBottomNavigationBar),
      );
      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(viewport.top, 62);
      expect(viewport.bottom, 912);
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      final padding =
          tester
                  .widget<SingleChildScrollView>(
                    find.byType(SingleChildScrollView),
                  )
                  .padding!
              as EdgeInsets;
      expect(padding.bottom, 14 + 912 - navigation.top);
      final calendar = find.byType(MonthlyActivityCalendar);
      scroll.position.jumpTo(
        (scroll.position.pixels +
                tester.getRect(calendar).center.dy -
                navigation.top)
            .clamp(0, scroll.position.maxScrollExtent),
      );
      await tester.pumpAndSettle();
      final card = tester.getRect(calendar);
      expect(card.contains(Offset(24, navigation.top - 2)), isTrue);
      expect(card.contains(Offset(24, navigation.top + 2)), isTrue);
      final pixels = await tester.runAsync(() async {
        final image = await captureImage(
          tester.element(find.byType(DigiGymAtmosphericBackground)),
        );
        try {
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          return [
            for (final y in [
              navigation.top.toInt() - 2,
              navigation.top.toInt() + 2,
            ])
              [
                for (var channel = 0; channel < 3; channel++)
                  bytes.getUint8((y * image.width + 24) * 4 + channel),
              ],
          ];
        } finally {
          image.dispose();
        }
      });
      for (var channel = 0; channel < 3; channel++) {
        expect(
          (pixels![0][channel] - pixels[1][channel]).abs(),
          lessThan(12),
          reason: 'Home must not clip its glass at a horizontal navigation boundary',
        );
      }
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(calendar).bottom,
        lessThanOrEqualTo(navigation.top),
      );
      expect(
        tester.getRect(find.byType(FloatingBottomNavigationBar)),
        navigation,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'workout glass is not cut off at the navigation safe-area boundary',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1280, 2856);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host());
      await selectTab(tester, 'Workout');
      final navigation = tester.getRect(
        find.byType(FloatingBottomNavigationBar),
      );
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      final card = tester.getRect(find.byType(DashboardGlassCard).last);
      // Put a glass card across the old cutoff, in the gap above the pill.
      scroll.position.jumpTo(
        (scroll.position.pixels + card.center.dy - navigation.top).clamp(
          0,
          scroll.position.maxScrollExtent,
        ),
      );
      await tester.pumpAndSettle();
      final pixels = await tester.runAsync(() async {
        final image = await captureImage(
          tester.element(find.byType(DigiGymAtmosphericBackground)),
        );
        try {
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          return [
            for (final y in [
              navigation.top.toInt() - 2,
              navigation.top.toInt() + 2,
            ])
              [
                for (var channel = 0; channel < 3; channel++)
                  bytes.getUint8((y * image.width + 24) * 4 + channel),
              ],
          ];
        } finally {
          image.dispose();
        }
      });
      for (var channel = 0; channel < 3; channel++) {
        expect(
          (pixels![0][channel] - pixels[1][channel]).abs(),
          lessThan(12),
          reason: 'A hard viewport clip must not create a rectangular edge',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a real workout card remains recognizable through the shared glass',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      // A shorter viewport puts the new compact Today content behind the pill.
      tester.view.physicalSize = const Size(1280 / 3, 640);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Widget scene({
        required bool navigation,
        required bool workout,
      }) => MaterialApp(
        theme: DigiGymDashboardTheme.content(
          DigiGymDashboardTheme.dark(ThemeData(useMaterial3: true)),
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(padding: const EdgeInsets.only(top: 52, bottom: 24)),
          child: child!,
        ),
        home: DigiGymAtmosphericBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            body: Opacity(
              opacity: workout ? 1 : 0,
              child: WorkoutsScreen(user: profile()),
            ),
            // Opacity preserves the measured navigation inset in every sample.
            bottomNavigationBar: Opacity(
              opacity: navigation ? 1 : 0,
              child: FloatingBottomNavigationBar(
                selectedIndex: 1,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(scene(navigation: false, workout: true));
      await tester.pumpAndSettle();
      final pill = tester.getRect(find.byType(BackdropFilter));
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      final card = find.byKey(const ValueKey('workout-goal'));
      await tester.scrollUntilVisible(card, 100);
      await tester.pumpAndSettle();
      scroll.position.jumpTo(
        (scroll.position.pixels +
                tester.getRect(card).center.dy -
                pill.center.dy)
            .clamp(0, scroll.position.maxScrollExtent),
      );
      await tester.pumpAndSettle();
      final cardBounds = tester.getRect(card);
      final region = pill.deflate(12);
      expect(cardBounds.contains(region.topLeft), isTrue);
      expect(cardBounds.contains(region.bottomRight), isTrue);

      final samples = <double>[];
      for (final stage in [
        (false, false),
        (false, true),
        (true, false),
        (true, true),
      ]) {
        await tester.pumpWidget(scene(navigation: stage.$1, workout: stage.$2));
        await tester.pumpAndSettle();
        expect(tester.getRect(card), cardBounds);
        expect(tester.getRect(find.byType(BackdropFilter)), pill);
        samples.add(
          (await tester.runAsync(() async {
            final image = await captureImage(
              tester.element(find.byType(DigiGymAtmosphericBackground)),
            );
            try {
              final bytes = (await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!;
              // Average a region rather than a single numeral or reflection:
              // frosting should soften details while retaining card contrast.
              var total = 0;
              var count = 0;
              for (var y = region.top.ceil(); y < region.bottom.floor(); y++) {
                for (
                  var x = region.left.ceil();
                  x < region.right.floor();
                  x++
                ) {
                  total += bytes.getUint8((y * image.width + x) * 4 + 1);
                  count++;
                }
              }
              return total / count;
            } finally {
              image.dispose();
            }
          }))!,
        );
      }
      final unobstructedCardContrast = samples[1] - samples[0];
      final glassCardContrast = samples[3] - samples[2];
      expect(unobstructedCardContrast, greaterThan(4));
      // Unlike a uniform backdrop, this region includes softened lettering and
      // the opaque navigation glyphs. Retain at least 40% of its average card
      // contrast; the previous filled-shadow surface retained only about 24%.
      expect(
        glassCardContrast,
        greaterThan(unobstructedCardContrast * .40),
        reason: 'The real card must remain visible through the composited pill, rather than being hidden by an opaque layer.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'workout data, semantic colors and exercise expansion are intact',
    (tester) async {
      await tester.pumpWidget(host());
      await selectTab(tester, 'Workout');
      expect(find.text('Build Muscle'), findsOneWidget);
      expect(find.text('Intermediate Plan'), findsOneWidget);
      expect(find.text('6 exercises'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Intermediate')).style?.color,
        DigiGymFitnessLevelColors.intermediate,
      );
      final firstExercise = WorkoutPlan.forUser(profile()).exercises.first;
      await tester.ensureVisible(
        find.byKey(const ValueKey('workout-view-exercises')),
      );
      await tester.tap(find.byKey(const ValueKey('workout-view-exercises')));
      await tester.pumpAndSettle();
      expect(find.text(firstExercise.description), findsNothing);
      await tester.tap(find.text(firstExercise.name));
      await tester.pumpAndSettle();
      expect(find.text(firstExercise.description), findsOneWidget);
      expect(find.text(firstExercise.sets), findsWidgets);
      await tester.tap(find.text(firstExercise.name));
      await tester.pumpAndSettle();
      expect(find.text(firstExercise.description), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pumpWidget(host(user: profile(level: 'Advanced')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('Advanced')).style?.color,
        DigiGymFitnessLevelColors.advanced,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('meal data, card margins and existing type sizes are preserved', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await selectTab(tester, 'Meals');
    expect(find.text('Estimated target: 1818 calories'), findsOneWidget);
    expect(find.text('Goal: Build Muscle'), findsOneWidget);
    expect(find.text('Diet: No Preference'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Daily Nutrition')).style?.fontSize,
      21,
    );
    final page = tester.widget<MealPage>(find.byType(MealPage));
    for (final meal in page.getMeals()) {
      expect(find.text(meal.name), findsOneWidget);
      expect(
        find.text(
          '${MeasurementUnits.formatFoodPortion(meal.portion)}\n${meal.protein}',
        ),
        findsOneWidget,
      );
      expect(find.text('${meal.calories}\n kcal'), findsOneWidget);
    }
    final glass = tester
        .widgetList<DashboardGlassCard>(find.byType(DashboardGlassCard))
        .toList();
    expect(glass.length, 4);
    expect(glass.first.margin, const EdgeInsets.all(4));
    for (final mealCard in glass.skip(1)) {
      expect(mealCard.margin, const EdgeInsets.only(bottom: 12));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('grocery rows still toggle and the final row clears navigation', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await selectTab(tester, 'Groceries');
    final chicken = find.widgetWithText(CheckboxListTile, 'Chicken breast');
    expect(tester.widget<CheckboxListTile>(chicken).value, isFalse);
    await tester.tap(find.text('Chicken breast'));
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(chicken).value, isTrue);
    await tester.tap(find.text('Chicken breast'));
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(chicken).value, isFalse);
    expect(find.byType(DashboardGlassCard), findsNothing);
    await tester.scrollUntilVisible(find.text('Cucumber'), 250);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.text('Cucumber')).bottom,
      lessThan(tester.getRect(find.byType(FloatingBottomNavigationBar)).top),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile values, edit route and logout callbacks remain intact', (
    tester,
  ) async {
    final api = FakeDigiGymApi();
    var logoutCalls = 0;
    UserProfile? updated;
    await tester.pumpWidget(
      host(
        api: api,
        onLogout: () async {
          logoutCalls++;
        },
        onUpdateProfile: (user) {
          updated = user;
        },
      ),
    );
    await selectTab(tester, 'Profile');
    expect(find.byType(ProfileInformation), findsNothing);
    expect(find.text('Isaac'), findsOneWidget);
    expect(find.text('Intermediate'), findsOneWidget);
    expect(find.text('Build Muscle'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('profile-user-card')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileDetailsScreen), findsOneWidget);
    expect(find.byType(ProfileInformation), findsNWidgets(11));
    expect(find.text('19.2'), findsOneWidget);
    expect(find.text('127.9 lb'), findsOneWidget);
    expect(find.text('5 ft 8.5 in'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Edit Profile'));
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(EditProfileScreen))).brightness,
      Brightness.light,
    );
    await tester.enterText(find.byType(TextField).first, 'Updated Isaac');
    await tester.ensureVisible(find.text('SAVE CHANGES'));
    await tester.tap(find.text('SAVE CHANGES'));
    await tester.pumpAndSettle();
    expect(api.updateRequest?.name, 'Updated Isaac');
    expect(updated?.name, 'Updated Isaac');
    expect(find.byType(ProfilePage), findsOneWidget);
    await tester.ensureVisible(find.text('Log Out'));
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(logoutCalls, 0);
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(logoutCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'login receives its own dark theme outside the approved tab shell',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          home: LoginScreen(onLogin: (_) {}, api: FakeDigiGymApi()),
        ),
      );
      await tester.pumpAndSettle();
      final theme = Theme.of(tester.element(find.byType(TextField).first));
      expect(theme.brightness, Brightness.dark);
      expect(
        theme.textTheme.bodyMedium?.fontFamily,
        DigiGymDashboardTheme.textFont,
      );
      expect(find.byType(DigiGymAtmosphericBackground), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'main tabs retain scrolling on narrow screens and enlarged text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [320.0, 390.0]) {
        tester.view.physicalSize = Size(width, 844);
        for (final scale in [1.0, 1.5, 2.0]) {
          await tester.pumpWidget(host(scale: scale));
          await tester.pumpAndSettle();
          for (final tab in [
            'Home',
            'Workout',
            'Meals',
            'Groceries',
            'Profile',
          ]) {
            await selectTab(tester, tab);
            expect(
              tester.takeException(),
              isNull,
              reason: '$tab $width at $scale',
            );
            final scroll = tester.state<ScrollableState>(
              find.byType(Scrollable).first,
            );
            // Lazy lists refine their extent as wrapped rows are laid out.
            for (var attempt = 0; attempt < 5; attempt++) {
              scroll.position.jumpTo(scroll.position.maxScrollExtent);
              await tester.pumpAndSettle();
              if (scroll.position.extentAfter < 0.01) break;
            }
            final viewport = tester.getRect(find.byType(Scrollable).first);
            final navigation = tester.getRect(
              find.byType(FloatingBottomNavigationBar),
            );
            expect(viewport.bottom, 844);
            final lastContent = switch (tab) {
              'Home' =>
                find
                    .byWidgetPredicate(
                      (w) =>
                          w is Semantics &&
                          w.key is ValueKey<String> &&
                          (w.key! as ValueKey<String>).value.startsWith(
                            'month-day-',
                          ),
                    )
                    .last,
              'Workout' => find.byType(DashboardGlassCard).last,
              'Meals' => find.byType(DashboardGlassCard).last,
              'Groceries' => find.widgetWithText(CheckboxListTile, 'Cucumber'),
              'Profile' => find.byKey(const ValueKey('profile-logout')),
              _ => throw StateError('Unexpected tab: $tab'),
            };
            expect(
              tester.getRect(lastContent).bottom,
              lessThanOrEqualTo(navigation.top),
              reason: '$tab content clears navigation at $width / $scale',
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$tab $width at $scale',
            );
          }
        }
      }
    },
  );
}
