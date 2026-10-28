import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/screens/grocery_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/meal_page.dart';
import 'package:digigym/screens/profile_screen.dart';
import 'package:digigym/screens/workouts_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/fitness_goal_card.dart';
import 'package:digigym/widgets/dashboard_progress_card.dart';
import 'package:digigym/widgets/segmented_progress_ring.dart';
import 'package:digigym/widgets/plan_card.dart';
import 'package:digigym/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    scaffoldBackgroundColor: const Color(0xFFF5F7F5),
  );

  UserProfile profile({
    double weight = 80,
    String name = 'Alex',
    String fitnessGoal = 'Maintain Weight',
  }) => UserProfile(
    name: name,
    email: 'alex@example.com',
    age: 31,
    height: 180,
    weight: weight,
    fitnessLevel: 'Intermediate',
    fitnessGoal: fitnessGoal,
    workoutTime: 35,
  );

  Widget host(UserProfile user) => MaterialApp(
    theme: lightTheme,
    home: HomeScreen(
      user: user,
      clock: () => DateTime(2026, 10, 20, 9),
      onLogout: () async {},
      onUpdateProfile: (_) {},
    ),
  );

  testWidgets(
    'dashboard keeps profile data and replaces redundant plans with monthly activity',
    (tester) async {
      await tester.pumpWidget(host(profile()));
      await tester.pumpAndSettle();

      expect(find.text('Good Morning,'), findsOneWidget);
      expect(
        find.text('Every workout brings you closer to your goals.'),
        findsOneWidget,
      );
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text("Today's Progress"), findsOneWidget);
      expect(find.text('24.7'), findsOneWidget);
      expect(find.text('1775 Cal'), findsOneWidget);
      expect(find.text('176.4 lb'), findsOneWidget);
      expect(find.text('35 min'), findsOneWidget);
      expect(find.byType(StatCard), findsNWidgets(4));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dashboard-statistics-panel')),
          matching: find.byType(StatCard),
        ),
        findsNWidgets(3),
      );
      expect(find.byType(DashboardGlassCard), findsNWidgets(5));
      expect(find.byType(PlanCard), findsNothing);
      expect(find.text('Your Plan'), findsNothing);
      expect(find.text('Your Week'), findsOneWidget);
      expect(find.text('Monthly Activity'), findsOneWidget);

      // A changed profile must reach the same dashboard without cached/mock data.
      await tester.pumpWidget(host(profile(weight: 90, name: 'Taylor')));
      await tester.pumpAndSettle();
      expect(find.text('Taylor'), findsOneWidget);
      expect(find.text('27.8'), findsOneWidget);
      expect(find.text('1875 Cal'), findsOneWidget);
      expect(find.text('198.4 lb'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('all five main tabs and navigation share the scoped dark theme', (
    tester,
  ) async {
    await tester.pumpWidget(host(profile()));
    await tester.pumpAndSettle();

    ThemeData navigationTheme() =>
        Theme.of(tester.element(find.byType(FloatingBottomNavigationBar)));
    Scaffold homeScaffold() => tester.widget<Scaffold>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scaffold &&
            widget.bottomNavigationBar is FloatingBottomNavigationBar,
      ),
    );
    final navigationRect = tester.getRect(
      find.byType(FloatingBottomNavigationBar),
    );
    expect(navigationTheme().brightness, Brightness.dark);
    expect(homeScaffold().extendBody, isTrue);
    expect(
      navigationTheme().scaffoldBackgroundColor,
      DigiGymDarkColors.graphite,
    );
    expect(
      navigationTheme().colorScheme.primary,
      DigiGymDarkColors.electricGreen,
    );
    expect(
      navigationTheme().colorScheme.onSurface,
      DigiGymDarkColors.primaryText,
    );
    expect(
      navigationTheme().colorScheme.onSurfaceVariant,
      DigiGymDarkColors.secondaryText,
    );
    expect(
      Theme.of(tester.element(find.byType(DashboardPage))).brightness,
      Brightness.dark,
    );

    final screens = <String, Type>{
      'Workout': WorkoutsScreen,
      'Meals': MealPage,
      'Groceries': GroceryScreen,
      'Profile': ProfilePage,
    };
    for (final entry in screens.entries) {
      await tester.tap(
        find.descendant(
          of: find.byType(FloatingBottomNavigationBar),
          matching: find.text(entry.key),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget);
      final pageTheme = Theme.of(tester.element(find.byType(entry.value)));
      expect(pageTheme.brightness, Brightness.dark);
      expect(pageTheme.colorScheme, navigationTheme().colorScheme);
      expect(pageTheme.scaffoldBackgroundColor, DigiGymDarkColors.graphite);
      expect(
        pageTheme.textTheme.bodyMedium?.fontFamily,
        DigiGymDashboardTheme.textFont,
      );
      expect(navigationTheme().brightness, Brightness.dark);
      expect(homeScaffold().extendBody, isTrue);
      expect(
        tester
            .getRect(
              find
                  .descendant(
                    of: find.byType(entry.value),
                    matching: find.byType(Scrollable),
                  )
                  .first,
            )
            .bottom,
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      );
      expect(
        tester.getRect(find.byType(FloatingBottomNavigationBar)),
        navigationRect,
      );
      expect(tester.takeException(), isNull);
    }

    await tester.tap(
      find.descendant(
        of: find.byType(FloatingBottomNavigationBar),
        matching: find.text('Home'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPage), findsOneWidget);
    expect(navigationTheme().brightness, Brightness.dark);
    expect(homeScaffold().extendBody, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dashboard content clears navigation for Android and iOS system insets',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1280, 2856);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final configuration in [
        (TargetPlatform.android, const EdgeInsets.only(top: 52, bottom: 24)),
        (TargetPlatform.iOS, const EdgeInsets.only(top: 59, bottom: 34)),
        (TargetPlatform.android, EdgeInsets.zero),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: lightTheme.copyWith(platform: configuration.$1),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(padding: configuration.$2),
              child: child!,
            ),
            home: HomeScreen(
              user: profile(),
              onLogout: () async {},
              onUpdateProfile: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final viewport = tester.getRect(find.byType(SingleChildScrollView));
        final navigation = tester.getRect(
          find.byType(FloatingBottomNavigationBar),
        );
        expect(viewport.top, configuration.$2.top);
        expect(viewport.bottom, 952);
        final scroll = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
        );
        expect(
          (scroll.padding! as EdgeInsets).bottom,
          14 + 952 - navigation.top,
        );
        expect(navigation.bottom, 952);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'progress and workout align with one tall calories weight and BMI panel',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host(profile()));
      await tester.pumpAndSettle();

      final goal = tester.getRect(find.byType(DashboardProgressCard));
      Rect stat(String label) =>
          tester.getRect(find.widgetWithText(StatCard, label));
      final calories = stat('Daily calorie target');
      final workout = stat('Workout');
      final bmi = stat('BMI');
      final weight = stat('Weight');
      expect(goal.left, 20);
      final panel = tester.getRect(
        find.byKey(const ValueKey('dashboard-statistics-panel')),
      );
      expect(goal.top, panel.top);
      expect(workout.left, goal.left);
      expect(workout.width, goal.width);
      expect(workout.top, greaterThanOrEqualTo(goal.bottom + 10));
      expect(panel.bottom, closeTo(workout.bottom, .01));
      expect(panel.width, goal.width);
      expect(panel.left - goal.right, 12);
      expect(calories.top, lessThan(weight.top));
      expect(weight.top, lessThan(bmi.top));
      for (final row in [calories, weight, bmi]) {
        expect(row.left, greaterThan(panel.left));
        expect(row.right, lessThan(panel.right));
      }
      // The real-font appearance test checks the compact composition. This
      // fallback-font test also permits content to grow without clipping.
      expect(goal.height, greaterThanOrEqualTo(190));
      final headerImage = tester.widget<Image>(
        find.descendant(
          of: find.byType(DashboardPage),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName ==
                    'assets/images/digigym_workout_icon.png',
          ),
        ),
      );
      expect(
        (headerImage.image as AssetImage).assetName,
        'assets/images/digigym_workout_icon.png',
      );
      expect(headerImage.filterQuality, FilterQuality.none);
      expect(headerImage.color, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'long numbers imperial units and three-digit workouts stay inside their cards',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final user = UserProfile(
        name: 'Alexandria Morgan Hernandez',
        email: 'layout@example.com',
        age: 31,
        height: 165,
        weight: 999.9,
        fitnessLevel: 'Intermediate',
        fitnessGoal: 'Build Muscle',
        workoutTime: 125,
      );
      for (final width in [280.0, 320.0, 390.0, 1280 / 3]) {
        tester.view.physicalSize = Size(width, 844);
        for (final scale in [1.0, 2.0, 3.0]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: HomeScreen(
                user: user,
                onLogout: () async {},
                onUpdateProfile: (_) {},
                clock: () => DateTime(2026, 10, 25, 9),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('125 min'), findsOneWidget);
          expect(find.text('2204.4 lb'), findsOneWidget);
          expect(find.text(user.bmi.toStringAsFixed(1)), findsOneWidget);
          expect(find.text('${user.estimatedCalories} Cal'), findsOneWidget);
          for (final card in tester.widgetList<StatCard>(
            find.byType(StatCard),
          )) {
            expect(card.fitNumber, isTrue);
          }
          final panel = find.byKey(
            const ValueKey('dashboard-statistics-panel'),
          );
          expect(
            find.descendant(of: panel, matching: find.byType(StatCard)),
            findsNWidgets(3),
          );
          await tester.ensureVisible(
            find.byKey(const ValueKey('month-day-2026-10-31')),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$width at $scale');
        }
      }
    },
  );

  testWidgets(
    'progress remains zero for every goal while calorie calculations remain real',
    (tester) async {
      for (final entry in {
        'Build Muscle': '2075',
        'Lose Weight': '1375',
        'Maintain Weight': '1775',
        'Gain Weight': '2275',
      }.entries) {
        await tester.pumpWidget(host(profile(fitnessGoal: entry.key)));
        await tester.pumpAndSettle();
        expect(find.text('${entry.value} Cal'), findsOneWidget);
        expect(
          tester
              .widget<SegmentedProgressRing>(find.byType(SegmentedProgressRing))
              .progress,
          0,
        );
        expect(find.text('Complete'), findsOneWidget);
        expect(find.byType(FitnessGoalCard), findsNothing);
      }
    },
  );

  testWidgets('optional goal visual takes space only when supplied', (
    tester,
  ) async {
    Widget card({Widget? visual}) => MaterialApp(
      theme: DigiGymDashboardTheme.dark(lightTheme),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 220,
            child: FitnessGoalCard(goal: 'Build Muscle', visual: visual),
          ),
        ),
      ),
    );
    await tester.pumpWidget(card());
    final initialHeight = tester.getSize(find.byType(FitnessGoalCard)).height;
    await tester.pumpWidget(
      card(
        visual: const SizedBox(
          key: ValueKey('future-goal-visual'),
          height: 64,
          width: 100,
        ),
      ),
    );
    expect(find.byKey(const ValueKey('future-goal-visual')), findsOneWidget);
    expect(
      tester.getSize(find.byType(FitnessGoalCard)).height,
      closeTo(initialHeight + 80, 0.01),
    );
    await tester.pumpWidget(card());
    expect(tester.getSize(find.byType(FitnessGoalCard)).height, initialHeight);
  });

  testWidgets(
    'narrow phones and enlarged text stack and scroll without overflow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final size in [const Size(320, 640), const Size(390, 844)]) {
        for (final scale in [1.0, 2.0, 3.0]) {
          tester.view.physicalSize = size;
          await tester.pumpWidget(
            MaterialApp(
              theme: lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: const EdgeInsets.only(top: 44, bottom: 34),
                  textScaler: TextScaler.linear(scale),
                ),
                child: child!,
              ),
              home: HomeScreen(
                user: profile(name: 'Alexandria Morgan Hernandez'),
                onLogout: () async {},
                onUpdateProfile: (_) {},
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$size at text scale $scale',
          );
          final goal = tester.getRect(find.byType(DashboardProgressCard));
          final calories = tester.getRect(
            find.widgetWithText(StatCard, 'Daily calorie target'),
          );
          if (size.width == 320 || scale > 1.3) {
            expect(calories.top, greaterThan(goal.bottom));
            expect(
              tester
                  .getRect(
                    find.byKey(const ValueKey('dashboard-statistics-panel')),
                  )
                  .width,
              goal.width,
            );
          }
          await tester.ensureVisible(
            find.byKey(const ValueKey('month-day-2026-10-31')),
          );
          await tester.pumpAndSettle();
          expect(find.text('Alexandria Morgan Hernandez'), findsOneWidget);
          expect(find.text('24.7'), findsOneWidget);
          expect(find.text('1775 Cal'), findsOneWidget);
          expect(find.text('176.4 lb'), findsOneWidget);
          expect(find.text('35 min'), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: '$size at text scale $scale',
          );
        }
      }
    },
  );

  testWidgets('removing Home plan cards preserves all existing main tabs', (
    tester,
  ) async {
    await tester.pumpWidget(host(profile()));
    await tester.pumpAndSettle();
    expect(find.byType(PlanCard), findsNothing);
    for (final destination in [
      ('Workout', 1, WorkoutsScreen),
      ('Meals', 2, MealPage),
      ('Groceries', 3, GroceryScreen),
    ]) {
      await tester.tap(
        find.descendant(
          of: find.byType(FloatingBottomNavigationBar),
          matching: find.text(destination.$1),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(destination.$3), findsOneWidget);
      expect(
        tester
            .widget<FloatingBottomNavigationBar>(
              find.byType(FloatingBottomNavigationBar),
            )
            .selectedIndex,
        destination.$2,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(FloatingBottomNavigationBar),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
