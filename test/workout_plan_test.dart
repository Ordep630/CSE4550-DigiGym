import 'dart:convert';
import 'dart:io';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final original = jsonDecode(
    File('test/fixtures/workout_plans.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  for (final level in ['Beginner', 'Intermediate', 'Advanced']) {
    for (final goal in [
      'Lose Weight',
      'Build Muscle',
      'Maintain Weight',
      'Gain Weight',
    ]) {
      test(
        '$level / $goal preserves level-appropriate exercises and original instructions',
        () {
          final user = UserProfile(
            name: 'Test',
            email: 'test@example.com',
            fitnessLevel: level,
            fitnessGoal: goal,
            workoutTime: 75,
          );
          final plan = WorkoutPlan.forUser(user);
          final branch = goal == 'Gain Weight'
              ? 'Build Muscle'
              : (['Lose Weight', 'Build Muscle'].contains(goal)
                    ? goal
                    : 'Default');
          expect(
            plan.exercises
                .map((e) => {'name': e.name, 'description': e.description})
                .toList(),
            (original['$level / $branch'] as List)
                .map(
                  (e) => {'name': e['name'], 'description': e['description']},
                )
                .toList(),
          );
          expect(plan.fitnessLevel, level);
          expect(plan.fitnessGoal, goal);
          expect(
            plan.title,
            goal == 'Lose Weight' ? 'Cardio & Strength' : 'Full Body Strength',
          );
          expect(plan.durationMinutes, lessThanOrEqualTo(75));
          expect(plan.fitsTimeBudget, isTrue);
          expect(plan.estimatedSeconds, greaterThan(0));
          expect(plan.description, isNotEmpty);
          expect(() => plan.exercises.clear(), throwsUnsupportedError);
        },
      );
    }
  }
}
