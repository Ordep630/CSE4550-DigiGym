import 'dart:convert';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/models/workout_record_details.dart';
import 'package:digigym/services/workout_calorie_summary.dart';
import 'package:digigym/utils/workout_calories.dart';
import 'package:digigym/widgets/workout_calorie_tracker.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout, UuidValue;
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 200 lb, where the calorie table applies at exactly 1.0x.
const _baselineKg = 200 * 0.45359237;

UserProfile _user(String level, String goal, {double weight = _baselineKg}) =>
    UserProfile(
      accountId: '123e4567-e89b-12d3-a456-426614174000',
      name: 'Test',
      email: 'test@example.com',
      fitnessLevel: level,
      fitnessGoal: goal,
      workoutTime: 120,
      weight: weight,
    );

CompletedWorkout _row(int id, DateTime at, double? calories) =>
    CompletedWorkout(
      id: id,
      authUserId: UuidValue.fromString('123e4567-e89b-12d3-a456-426614174000'),
      workoutName: 'Full Body Strength',
      durationMinutes: 30,
      details: jsonEncode(
        WorkoutRecordDetails(caloriesBurned: calories).toJson(),
      ),
      completedAt: at,
    );

void main() {
  group('calorie table totals match the spec at 200 lb', () {
    const expected = <(String, String, double)>[
      ('Beginner', 'Lose Weight', 92),
      ('Beginner', 'Build Muscle', 37),
      ('Beginner', 'Gain Weight', 37),
      ('Beginner', 'Maintain Weight', 19),
      ('Intermediate', 'Lose Weight', 82),
      ('Intermediate', 'Build Muscle', 77),
      ('Intermediate', 'Gain Weight', 77),
      ('Intermediate', 'Maintain Weight', 45),
      ('Advanced', 'Lose Weight', 166.5),
      ('Advanced', 'Build Muscle', 109),
      ('Advanced', 'Gain Weight', 109),
      ('Advanced', 'Maintain Weight', 93),
    ];
    for (final (level, goal, total) in expected) {
      test('$level / $goal = $total', () {
        final plan = WorkoutPlan.forUser(_user(level, goal));
        expect(plan.caloriesBurned, closeTo(total, 1e-6));
      });
    }
  });

  group('body weight multiplier', () {
    double lb(double pounds) =>
        WorkoutCalories.weightMultiplier(pounds * 0.45359237);

    test('follows 0.01x per 2 lb around 200 lb', () {
      expect(lb(150), closeTo(.75, 1e-9));
      expect(lb(175), closeTo(.875, 1e-9));
      expect(lb(200), closeTo(1, 1e-9));
      expect(lb(250), closeTo(1.25, 1e-9));
      expect(lb(300), closeTo(1.5, 1e-9));
      expect(lb(350), closeTo(1.75, 1e-9));
      expect(lb(400), closeTo(2, 1e-9));
    });

    test('scales plan calories and tolerates bad weights', () {
      final heavy = WorkoutPlan.forUser(
        _user('Beginner', 'Lose Weight', weight: 300 * 0.45359237),
      );
      expect(heavy.caloriesBurned, closeTo(92 * 1.5, 1e-6));
      expect(WorkoutCalories.weightMultiplier(0), 1);
      expect(WorkoutCalories.weightMultiplier(double.nan), 1);
    });
  });

  test('untracked exercises count as zero', () {
    expect(
      WorkoutCalories.forExercises(
        level: 'Beginner',
        goal: 'Lose Weight',
        exercises: ['Easy Walking', 'Plank'],
        bodyWeightKg: _baselineKg,
      ),
      closeTo(3, 1e-6),
    );
  });

  test('formats whole and fractional calories', () {
    expect(WorkoutCalories.format(92), '92 Cal');
    expect(WorkoutCalories.format(166.5), '166.5 Cal');
    expect(WorkoutCalories.format(0), '0 Cal');
  });

  group('daily summary from saved history', () {
    final today = DateTime(2026, 11, 18, 21);
    final history = [
      _row(1, DateTime(2026, 11, 18, 7), 40),
      _row(2, DateTime(2026, 11, 18, 20, 30), 52.5),
      _row(3, DateTime(2026, 11, 17, 22), 99),
      _row(4, DateTime(2026, 11, 18, 8), null),
    ];

    test('counts only today and keeps other days in history', () {
      final summary = caloriesBurnedOn(history, today);
      expect(summary.calories, 92.5);
      expect(summary.workouts, 3);
      expect(history, hasLength(4));
    });

    test('resets on the next day', () {
      final next = caloriesBurnedOn(history, DateTime(2026, 11, 19, 0, 1));
      expect(next.calories, 0);
      expect(next.workouts, 0);
      expect(
        caloriesBurnedOn(history, DateTime(2026, 11, 17, 12)).calories,
        99,
      );
    });
  });

  test('calories survive the saved details round trip', () {
    final details = WorkoutRecordDetails.decode(
      jsonEncode(const WorkoutRecordDetails(caloriesBurned: 37.5).toJson()),
    );
    expect(details.caloriesBurned, 37.5);
    expect(WorkoutRecordDetails.decode('[]').caloriesBurned, isNull);
  });

  testWidgets('tracker updates when a workout is added', (tester) async {
    final history = ValueNotifier<List<CompletedWorkout>>(const []);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutCalorieTracker(
            history: history,
            clock: () => DateTime(2026, 11, 18, 21),
          ),
        ),
      ),
    );
    Text value() => tester.widget<Text>(
      find.byKey(const ValueKey('workout-calories-today')),
    );
    expect(value().data, '0 Cal');

    history.value = [_row(1, DateTime(2026, 11, 18, 9), 92)];
    await tester.pump();
    expect(value().data, '92 Cal');
    expect(find.text('1 workout completed today'), findsOneWidget);

    history.value = [_row(1, DateTime(2026, 11, 17, 9), 92)];
    await tester.pump();
    expect(value().data, '0 Cal');
  });
}
