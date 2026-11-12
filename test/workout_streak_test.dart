import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/screens/workout_exercises_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

final _user = UserProfile(
  accountId: '123e4567-e89b-12d3-a456-426614174000',
  name: 'Isaac',
  email: 'test@example.com',
  fitnessLevel: 'Intermediate',
  fitnessGoal: 'Build Muscle',
  workoutTime: 30,
);

Future<void> _complete(
  WidgetTester tester,
  FakeDigiGymApi api,
  DateTime day,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WorkoutExercisesScreen(
        plan: WorkoutPlan.forUser(_user),
        api: api,
        clock: () => day,
      ),
    ),
  );
  final button = find.byKey(const ValueKey('complete-workout-button'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first completion starts a streak at 1 day', (tester) async {
    final api = FakeDigiGymApi()..authenticated = true;
    await _complete(tester, api, DateTime(2026, 11, 10, 9));
    expect(find.textContaining('Current streak: 1 day.'), findsOneWidget);
    expect(api.streak, 1);
  });

  testWidgets('consecutive days increase the streak', (tester) async {
    final api = FakeDigiGymApi()..authenticated = true;
    await _complete(tester, api, DateTime(2026, 11, 10, 9));
    await _complete(tester, api, DateTime(2026, 11, 11, 18));
    expect(find.textContaining('Current streak: 2 days.'), findsOneWidget);
  });

  testWidgets('a second completion on the same day does not add to it',
      (tester) async {
    final api = FakeDigiGymApi()..authenticated = true;
    await _complete(tester, api, DateTime(2026, 11, 10, 9));
    await _complete(tester, api, DateTime(2026, 11, 10, 20));
    expect(api.streak, 1);
    expect(find.textContaining('Current streak: 1 day.'), findsOneWidget);
  });

  testWidgets('a missed day restarts the streak', (tester) async {
    final api = FakeDigiGymApi()..authenticated = true;
    await _complete(tester, api, DateTime(2026, 11, 10, 9));
    await _complete(tester, api, DateTime(2026, 11, 12, 9));
    expect(api.streak, 1);
    expect(await api.getWorkoutStreak(DateTime(2026, 11, 14)), 0);
  });

  testWidgets('a streak failure still shows the workout as saved',
      (tester) async {
    final api = FakeDigiGymApi()
      ..authenticated = true
      ..streakError = StateError('offline');
    await _complete(tester, api, DateTime(2026, 11, 10, 9));
    expect(find.text('Workout Completed'), findsOneWidget);
    expect(find.textContaining('progress has been saved'), findsOneWidget);
  });
}
