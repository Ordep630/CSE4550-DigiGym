import '../models/user_profile.dart';
import 'measurement_units.dart';

/// Calories burned by a workout, from a fixed per-exercise table scaled by the
/// user's body weight. The table values are for a 200 lb (90.7 kg) person.
///
/// Presentation of the totals is whole or one-decimal "Cal" (food Calories,
/// i.e. kcal), matching the rest of the app.
abstract final class WorkoutCalories {
  /// Table values correspond to this body weight.
  static const baselinePounds = 200.0;

  /// Keep very light or very heavy profiles from producing absurd results.
  static const minMultiplier = 0.25;
  static const maxMultiplier = 3.0;

  /// 0.01x per 2 lb relative to 200 lb, i.e. `pounds / 200`.
  /// 150 lb = 0.75x, 200 lb = 1.00x, 300 lb = 1.50x, 400 lb = 2.00x.
  /// [kilograms] is the unit UserProfile stores.
  static double weightMultiplier(double kilograms) {
    if (!kilograms.isFinite || kilograms <= 0) return 1;
    final pounds = MeasurementUnits.kilogramsToPounds(kilograms);
    return (pounds / baselinePounds)
        .clamp(minMultiplier, maxMultiplier)
        .toDouble();
  }

  /// Which table a goal uses. Mirrors the exercise library: Gain Weight shares
  /// Build Muscle, anything else falls to the Maintain Weight list.
  static String goalGroup(String goal) => switch (goal) {
    'Lose Weight' => 'lose',
    'Build Muscle' || 'Gain Weight' => 'build',
    _ => 'maintain',
  };

  static String levelGroup(String level) => switch (level) {
    'Intermediate' => 'intermediate',
    'Advanced' => 'advanced',
    _ => 'beginner',
  };

  /// Table calories for one exercise at 200 lb; null when it is not tracked
  /// (for example the Recovery & Mobility moves).
  static double? baseCalories({
    required String level,
    required String goal,
    required String exercise,
  }) => _table['${levelGroup(level)}/${goalGroup(goal)}']?[exercise];

  /// Calories for the named exercises, scaled to [bodyWeightKg].
  static double forExercises({
    required String level,
    required String goal,
    required Iterable<String> exercises,
    required double bodyWeightKg,
  }) {
    var total = 0.0;
    for (final name in exercises) {
      total += baseCalories(level: level, goal: goal, exercise: name) ?? 0;
    }
    return total * weightMultiplier(bodyWeightKg);
  }

  static double forUser(UserProfile user, Iterable<String> exercises) =>
      forExercises(
        level: user.fitnessLevel,
        goal: user.fitnessGoal,
        exercises: exercises,
        bodyWeightKg: user.weight,
      );

  /// "92 Cal" or "98.5 Cal": whole numbers stay whole, otherwise one decimal.
  static String format(double calories) {
    final rounded = (calories * 10).round() / 10;
    final text = rounded == rounded.roundToDouble()
        ? rounded.round().toString()
        : rounded.toStringAsFixed(1);
    return '$text Cal';
  }

  static const Map<String, Map<String, double>> _table = {
    'beginner/lose': {
      'Walking': 67.5,
      'Bodyweight Squats': 6.5,
      'Wall Push Ups': 4,
      'Step Ups': 11,
      'Plank': 3,
    },
    'beginner/build': {
      'Bodyweight Squats': 10.5,
      'Knee Push Ups': 8,
      'Glute Bridges': 8,
      'Bird Dog': 6.5,
      'Plank': 4,
    },
    'beginner/maintain': {
      'Bodyweight Squats': 6.5,
      'Wall Push Ups': 4,
      'Glute Bridges': 5.5,
      'Plank': 3,
    },
    'intermediate/lose': {
      'Jumping Jacks': 21.5,
      'Bodyweight Squats': 13,
      'Mountain Climbers': 9,
      'Reverse Lunges': 12,
      'Burpees': 20,
      'Plank': 6.5,
    },
    'intermediate/build': {
      'Push Ups': 16,
      'Bodyweight Squats': 16.5,
      'Walking Lunges': 20,
      'Pike Push Ups': 8.5,
      'Single Leg Glute Bridge': 9.5,
      'Plank': 6.5,
    },
    'intermediate/maintain': {
      'Push Ups': 13.5,
      'Bodyweight Squats': 13,
      'Reverse Lunges': 12,
      'Plank': 6.5,
    },
    'advanced/lose': {
      'Burpees': 45,
      'Jump Squats': 26,
      'Mountain Climbers': 20,
      'Walking Lunges': 32.5,
      'High Knees': 32.5,
      'Plank': 10.5,
    },
    'advanced/build': {
      'Decline Push Ups': 16,
      'Bulgarian Split Squats': 26,
      'Diamond Push Ups': 13.5,
      'Jump Squats': 26,
      'Single Leg Glute Bridges': 16,
      'Plank Shoulder Taps': 11.5,
    },
    'advanced/maintain': {
      'Decline Push Ups': 16,
      'Bulgarian Split Squats': 26,
      'Diamond Push Ups': 13.5,
      'Jump Squats': 26,
      'Plank Shoulder Taps': 11.5,
    },
  };
}
