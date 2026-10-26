import 'package:digigym/models/exercise.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:flutter_test/flutter_test.dart';

UserProfile user(String level, String goal, int minutes) => UserProfile(
  name: 'Test',
  email: 'test@example.com',
  fitnessLevel: level,
  fitnessGoal: goal,
  workoutTime: minutes,
);

void main() {
  test('timing includes repetitions, sets, sides and rests with conservative timed ranges', () {
    final reps = Exercise(
      name: 'Squat',
      sets: '2 x 10',
      description: 'Original instructions',
      restSeconds: 45,
    );
    expect(reps.workSeconds, 60);
    expect(reps.estimatedSeconds, 105);
    final sides = Exercise(
      name: 'Lunge',
      sets: '4 x 10 each leg',
      description: 'Original',
      restSeconds: 75,
    );
    expect(sides.workSeconds, 240);
    expect(sides.estimatedSeconds, 465);
    final walking = Exercise(
      name: 'Walking',
      sets: '10-15 minutes',
      description: 'Original',
    );
    expect(walking.estimatedSeconds, 900);
    final plank = Exercise(
      name: 'Plank',
      sets: '3 x 20 seconds',
      description: 'Original',
    );
    expect(plank.estimatedSeconds, 180);
    expect(
      () => Exercise(
        name: 'Unknown',
        sets: 'unstructured',
        description: 'Original',
      ),
      throwsArgumentError,
    );
  });
  for (final level in ['Beginner', 'Intermediate', 'Advanced']) {
    for (final goal in [
      'Lose Weight',
      'Maintain Weight',
      'Gain Weight',
      'Build Muscle',
    ]) {
      test(
        '$level $goal respects short medium long and insufficient budgets',
        () {
          for (final minutes in [0, 1, 3, 5, 15, 30, 45, 60, 125]) {
            final plan = WorkoutPlan.forUser(user(level, goal, minutes));
            expect(plan.availableMinutes, minutes);
            expect(plan.estimatedSeconds, lessThanOrEqualTo(minutes * 60));
            expect(plan.durationMinutes, lessThanOrEqualTo(minutes));
            if (plan.exercises.isEmpty) {
              expect(plan.fitsTimeBudget, isFalse);
              expect(plan.minimumMinutes, greaterThan(minutes));
            } else {
              expect(plan.fitsTimeBudget, isTrue);
              final sum =
                  plan.warmUpSeconds +
                  plan.coolDownSeconds +
                  plan.exercises.fold<int>(
                    0,
                    (sum, item) => sum + item.estimatedSeconds,
                  ) +
                  plan.exercises
                      .skip(1)
                      .fold<int>(
                        0,
                        (sum, item) => sum + item.transitionSeconds,
                      );
              expect(plan.estimatedSeconds, sum);
              expect(plan.durationMinutes, (sum / 60).ceil());
              expect(
                plan.exercises.every(
                  (item) => item.description.isNotEmpty && item.setCount > 0,
                ),
                isTrue,
              );
            }
          }
        },
      );
    }
  }
  test('additional time changes actual workload rather than just the duration label', () {
    final plans = [5, 15, 30, 60]
        .map(
          (minutes) =>
              WorkoutPlan.forUser(user('Advanced', 'Build Muscle', minutes)),
        )
        .toList();
    for (var i = 1; i < plans.length; i++) {
      expect(
        plans[i].estimatedSeconds,
        greaterThan(plans[i - 1].estimatedSeconds),
      );
      final prior = plans[i - 1].exercises
          .map(
            (exercise) =>
                (exercise.name, exercise.setCount, exercise.secondsPerSet),
          )
          .toList();
      final next = plans[i].exercises
          .map(
            (exercise) =>
                (exercise.name, exercise.setCount, exercise.secondsPerSet),
          )
          .toList();
      expect(next, isNot(prior));
    }
  });
  test('a long budget never fabricates extra workload beyond the existing template', () {
    final sixty = WorkoutPlan.forUser(user('Beginner', 'Maintain Weight', 60));
    final longer = WorkoutPlan.forUser(
      user('Beginner', 'Maintain Weight', 125),
    );
    expect(longer.estimatedSeconds, sixty.estimatedSeconds);
    expect(longer.durationMinutes, lessThan(60));
  });
  test('Gain Weight intentionally shares strength work and Maintain Weight stays balanced', () {
    for (final level in ['Beginner', 'Intermediate', 'Advanced']) {
      final gain = WorkoutPlan.forUser(user(level, 'Gain Weight', 60));
      final muscle = WorkoutPlan.forUser(user(level, 'Build Muscle', 60));
      final maintain = WorkoutPlan.forUser(user(level, 'Maintain Weight', 60));
      expect(
        gain.exercises.map((exercise) => exercise.name),
        muscle.exercises.map((exercise) => exercise.name),
      );
      expect(
        maintain.exercises.map((exercise) => exercise.name).toList(),
        isNot(muscle.exercises.map((exercise) => exercise.name).toList()),
      );
    }
  });
}
