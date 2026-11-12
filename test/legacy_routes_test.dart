import 'dart:async';

import 'package:digigym/main.dart';
import 'package:digigym/models/session.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/screens/meal_page.dart';
import 'package:digigym/screens/meals_screen.dart';
import 'package:digigym/screens/grocery_screen.dart';
import 'package:digigym/widgets/digigym_atmospheric_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

void main() {
  tearDown(() {
    DigiGymSession.currentUser = null;
  });

  testWidgets(
    'legacy meals uses the approved profile plan and keeps route compatibility',
    (tester) async {
      final api = FakeDigiGymApi()
        ..authenticated = true
        ..restoredProfile = testUser();
      await tester.pumpWidget(DigiGymApp(api: api));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(DashboardPage)))
          .pushNamed('/meals');
      await tester.pumpAndSettle();
      final plan = tester.widget<MealPage>(find.byType(MealPage));
      expect(plan.user.fitnessGoal, 'Build Muscle');
      expect(find.byKey(const ValueKey('daily-nutrition')), findsOneWidget);
      expect(find.text('DAILY CALORIE TARGET'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.text('DAILY CALORIE TARGET'))).brightness,
        Brightness.dark,
      );
      expect(find.byType(DigiGymAtmosphericBackground), findsOneWidget);
      Navigator.pop(tester.element(find.byType(MealPage)));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
    },
  );

  testWidgets(
    'unauthenticated legacy meals does not invent a user or meal plan',
    (tester) async {
      DigiGymSession.currentUser = null;
      await tester.pumpWidget(const MaterialApp(home: MealsScreen()));
      expect(find.text('Sign in to view your meal plan.'), findsOneWidget);
      expect(find.byType(MealPage), findsNothing);
    },
  );

  testWidgets(
    'standalone groceries is dark and checklist interactions remain functional',
    (tester) async {
      final api = FakeDigiGymApi()
        ..restoredProfile = testUser()
        ..authenticated = true;
      await tester.pumpWidget(DigiGymApp(api: api));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(DashboardPage)))
          .pushNamed('/groceries');
      await tester.pumpAndSettle();
      expect(find.byType(GroceryScreen), findsOneWidget);
      final screen = tester.widget<GroceryScreen>(find.byType(GroceryScreen));
      expect(
        screen.controller,
        isNull,
      ); // Standalone compatibility route owns its list.
      await tester.scrollUntilVisible(find.byType(CheckboxListTile).first, 250);
      final first = find.byType(CheckboxListTile).first;
      expect(Theme.of(tester.element(first)).brightness, Brightness.dark);
      expect(tester.widget<CheckboxListTile>(first).value, isFalse);
      await tester.tap(first);
      await tester.pumpAndSettle();
      expect(tester.widget<CheckboxListTile>(first).value, isTrue);
      final scroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      for (var i = 0; i < 10; i++) {
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
        await tester.pumpAndSettle();
      }
      final last = find.byType(CheckboxListTile).last;
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(tester.widget<CheckboxListTile>(last).value, isTrue);
    },
  );

  testWidgets(
    'session loading, failure, retry and sign-out use dark presentation without changing lifecycle',
    (tester) async {
      final gate = Completer<void>();
      final api = FakeDigiGymApi()
        ..restoreWait = gate.future
        ..restoreError = StateError('offline')
        ..authenticated = true;
      await tester.pumpWidget(DigiGymApp(api: api));
      expect(find.text('Restoring your session...'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(CircularProgressIndicator)))
            .brightness,
        Brightness.dark,
      );
      gate.complete();
      await tester.pumpAndSettle();
      expect(
        find.textContaining('could not restore your session'),
        findsOneWidget,
      );
      expect(api.signOutCalls, 0);
      api.restoreError = null;
      api.restoredProfile = testUser();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(api.signOutCalls, 0);
    },
  );
}
