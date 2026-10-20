import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/screens/grocery_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/meal_page.dart';
import 'package:digigym/screens/profile_screen.dart';
import 'package:digigym/screens/workouts_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
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

  UserProfile profile({double weight = 80, String name = 'Alex'}) =>
      UserProfile(
        name: name,
        email: 'alex@example.com',
        age: 31,
        height: 180,
        weight: weight,
        fitnessLevel: 'Intermediate',
        fitnessGoal: 'Maintain Weight',
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

    expect(find.text('Welcome, Alex! 👋'), findsOneWidget);
    expect(
      find.text("Let's work toward your maintain weight goal."),
      findsOneWidget,
    );
    expect(find.text('24.7'), findsOneWidget);
    expect(find.text('1775'), findsOneWidget);
    expect(find.text('80.0 kg'), findsOneWidget);
    expect(find.text('35 min'), findsOneWidget);
    expect(find.byType(StatCard), findsNWidgets(4));
    expect(find.byType(PlanCard), findsNWidgets(3));
    expect(find.text('Intermediate 35-minute workout'), findsOneWidget);
    expect(find.text('Target approximately 1775 calories'), findsOneWidget);
    expect(find.text('View ingredients for your meal plan'), findsOneWidget);

    // A changed profile must reach the same dashboard without cached/mock data.
    await tester.pumpWidget(host(profile(weight: 90, name: 'Taylor')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Taylor! 👋'), findsOneWidget);
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

  testWidgets('dashboard retains its rows and padding on a phone display', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(profile()));
    await tester.pumpAndSettle();

    final cards = find.byType(StatCard);
    expect(
      tester.getTopLeft(cards.at(0)).dy,
      tester.getTopLeft(cards.at(1)).dy,
    );
    expect(
      tester.getTopLeft(cards.at(2)).dy,
      tester.getTopLeft(cards.at(3)).dy,
    );
    expect(tester.getTopLeft(cards.at(0)).dx, 20);
    expect(
      tester.getSize(cards.at(0)).width,
      tester.getSize(cards.at(1)).width,
    );
    await tester.scrollUntilVisible(
      find.text('View ingredients for your meal plan'),
      100,
      scrollable: find.descendant(
        of: find.byType(DashboardPage),
        matching: find.byType(Scrollable),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
