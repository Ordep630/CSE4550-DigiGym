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
      onLogout: () async {},
      onUpdateProfile: (_) {},
    ),
  );

  testWidgets('dashboard keeps profile data, derived values and plan content', (
    tester,
  ) async {
    await tester.pumpWidget(host(profile()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Maintain Weight'), findsOneWidget);
    expect(find.text('24.7'), findsOneWidget);
    expect(find.text('1775'), findsOneWidget);
    expect(find.text('80.0 kg'), findsOneWidget);
    expect(find.text('35 min'), findsOneWidget);
    expect(find.byType(StatCard), findsNWidgets(4));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('dashboard-statistics-panel')),
        matching: find.byType(StatCard),
      ),
      findsNWidgets(2),
    );
    expect(find.byType(DashboardGlassCard), findsNWidgets(7));
    expect(find.byType(PlanCard), findsNWidgets(3));
    expect(find.text('Intermediate 35-minute workout'), findsOneWidget);
    expect(find.text('Target approximately 1775 calories'), findsOneWidget);
    expect(find.text('View ingredients for your meal plan'), findsOneWidget);

    // A changed profile must reach the same dashboard without cached/mock data.
    await tester.pumpWidget(host(profile(weight: 90, name: 'Taylor')));
    await tester.pumpAndSettle();
    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('27.8'), findsOneWidget);
    expect(find.text('1875'), findsOneWidget);
    expect(find.text('90.0 kg'), findsOneWidget);
    expect(find.text('Target approximately 1875 calories'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('only Home and its navigation receive the dark theme', (
    tester,
  ) async {
    await tester.pumpWidget(host(profile()));
    await tester.pumpAndSettle();

    ThemeData navigationTheme() =>
        Theme.of(tester.element(find.byType(FloatingBottomNavigationBar)));
    final navigationRect = tester.getRect(
      find.byType(FloatingBottomNavigationBar),
    );
    expect(navigationTheme().brightness, Brightness.dark);
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
      expect(pageTheme.brightness, Brightness.light);
      expect(pageTheme.colorScheme, lightTheme.colorScheme);
      expect(
        pageTheme.scaffoldBackgroundColor,
        lightTheme.scaffoldBackgroundColor,
      );
      expect(navigationTheme().brightness, Brightness.light);
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
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'featured goal sits beside calories and workout above BMI and weight',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host(profile()));
      await tester.pumpAndSettle();

      final goal = tester.getRect(find.byType(FitnessGoalCard));
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
      expect(goal.right, lessThan(calories.left));
      expect(workout.top, greaterThan(calories.bottom));
      expect(goal.bottom, closeTo(panel.bottom, 0.01));
      expect(bmi.top, greaterThan(goal.bottom));
      expect(bmi.top, weight.top);
      expect(bmi.width, weight.width);
      expect(goal.height, lessThan(280));
      final headerImage = tester.widget<Image>(
        find.descendant(
          of: find.byType(DashboardPage),
          matching: find.byType(Image),
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
    'featured goal uses every saved goal and its existing calorie estimate',
    (tester) async {
      for (final entry in {
        'Build Muscle': '2075',
        'Lose Weight': '1375',
        'Maintain Weight': '1775',
        'Gain Weight': '2275',
      }.entries) {
        await tester.pumpWidget(host(profile(fitnessGoal: entry.key)));
        await tester.pumpAndSettle();
        expect(find.text(entry.key), findsOneWidget);
        expect(find.text(entry.value), findsOneWidget);
        expect(
          tester.widget<FitnessGoalCard>(find.byType(FitnessGoalCard)).visual,
          isNull,
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
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
          final goal = tester.getRect(find.byType(FitnessGoalCard));
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
          await tester.ensureVisible(find.text('Grocery List'));
          await tester.pumpAndSettle();
          expect(find.text('Alexandria Morgan Hernandez'), findsOneWidget);
          expect(find.text('24.7'), findsOneWidget);
          expect(find.text('1775'), findsOneWidget);
          expect(find.text('80.0 kg'), findsOneWidget);
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

  testWidgets(
    'plan cards remain informational without new navigation actions',
    (tester) async {
      await tester.pumpWidget(host(profile()));
      await tester.pumpAndSettle();
      for (final label in [
        "Today's Workout",
        "Today's Nutrition",
        'Grocery List',
      ]) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.byType(DashboardPage), findsOneWidget);
        expect(
          tester
              .widget<FloatingBottomNavigationBar>(
                find.byType(FloatingBottomNavigationBar),
              )
              .selectedIndex,
          0,
        );
      }
      expect(
        find.descendant(
          of: find.byType(PlanCard),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
