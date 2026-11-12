import 'dart:math' as math;

import 'exercise.dart';
import 'user_profile.dart';
import 'workout_schedule_day.dart';

/// Profile-based recommendation; all durations are workload estimates, not time
/// preferences relabelled as estimates. No session/completion state is created.
class WorkoutPlan {
  final String title;
  final String fitnessLevel;
  final String fitnessGoal;
  final int availableMinutes;
  final int warmUpSeconds = 120;
  final int coolDownSeconds = 60;
  final int minimumMinutes;
  final String description;
  final List<Exercise> exercises;
  final ScheduledWorkoutType workoutType;
  final bool isRecovery;

  WorkoutPlan._({
    required this.title,
    required this.fitnessLevel,
    required this.fitnessGoal,
    required this.availableMinutes,
    required this.description,
    required this.minimumMinutes,
    required List<Exercise> exercises,
    this.workoutType = ScheduledWorkoutType.fullBody,
    this.isRecovery = false,
  }) : exercises = List.unmodifiable(exercises);

  int get estimatedSeconds => exercises.isEmpty ? 0 : _duration(exercises);
  int get durationMinutes => (estimatedSeconds / 60).ceil();
  bool get fitsTimeBudget =>
      exercises.isNotEmpty && estimatedSeconds <= availableMinutes * 60;
  static int _duration(List<Exercise> exercises) => exercises.isEmpty
      ? 0
      : 180 +
            exercises.fold<int>(
              0,
              (total, exercise) => total + exercise.estimatedSeconds,
            ) +
            exercises
                .skip(1)
                .fold<int>(
                  0,
                  (total, exercise) => total + exercise.transitionSeconds,
                );

  factory WorkoutPlan.forUser(UserProfile user) {
    final library = _WorkoutExerciseLibrary(user);
    return _fit(
      user,
      title: user.fitnessGoal == 'Lose Weight'
          ? 'Cardio & Strength'
          : 'Full Body Strength',
      templates: library.getExercises(),
      description: library.getLevelDescription(),
    );
  }

  /// Curated variants of the same level-appropriate catalogue. The same fitter
  /// and original volume ceilings apply to all alternatives and scheduled days.
  static List<WorkoutPlan> alternativesForUser(UserProfile user) {
    final originals = _WorkoutExerciseLibrary(user).getExercises();
    if (originals.isEmpty) return const [];
    final lower = originals.where(
      (e) => RegExp(
        'Squat|Lunge|Bridge|Step',
        caseSensitive: false,
      ).hasMatch(e.name),
    );
    final upper = originals.where(
      (e) => RegExp(
        'Push|Plank|Bird Dog|Shoulder',
        caseSensitive: false,
      ).hasMatch(e.name),
    );
    return List.unmodifiable(
      [
        _fit(
          user,
          title: 'Lower Body Strength',
          templates: lower.toList(),
          description:
              'Controlled lower-body movements from your recommended level.',
          workoutType: ScheduledWorkoutType.lowerBody,
        ),
        _fit(
          user,
          title: 'Upper Body & Core',
          templates: upper.toList(),
          description:
              'Upper-body strength and core stability at your saved level.',
          workoutType: ScheduledWorkoutType.upperBody,
        ),
        _fit(
          user,
          title: 'Recovery & Mobility',
          isRecovery: true,
          description: 'A lighter option between strength days. Move comfortably; no completions are recorded.',
          templates: [
            Exercise(
              name: 'Easy Walking',
              sets: '5 minutes',
              restSeconds: 20,
              description: 'Walk at an easy conversational pace. Keep your posture upright and shoulders relaxed.',
            ),
            Exercise(
              name: 'Standing Shoulder Circles',
              sets: '1 x 30 seconds',
              restSeconds: 20,
              description: 'Stand tall with arms relaxed. Slowly roll your shoulders forward, then backward, without forcing the movement.',
            ),
            Exercise(
              name: 'Gentle Standing March',
              sets: '1 x 60 seconds',
              restSeconds: 20,
              description: 'March slowly in place with comfortable knee lifts. Use a stable support if needed and keep breathing evenly.',
            ),
          ],
        ),
      ].where((plan) => plan.fitsTimeBudget),
    );
  }

  static WorkoutPlan _fit(
    UserProfile user, {
    required String title,
    required List<Exercise> templates,
    required String description,
    ScheduledWorkoutType workoutType = ScheduledWorkoutType.fullBody,
    bool isRecovery = false,
  }) {
    final budget = math.max(0, user.workoutTime) * 60;
    Exercise minimum(Exercise exercise) => exercise.withVolume(
      count: 1,
      timedSeconds: exercise.secondsPerSet == null
          ? null
          : math.min(120, exercise.secondsPerSet!),
    );
    final minimumSeconds = templates.isEmpty
        ? 0
        : templates
              .map((exercise) => _duration([minimum(exercise)]))
              .reduce(math.min);
    final selected = <Exercise>[];
    final originals = <Exercise>[];
    for (final template in templates) {
      final exercise = minimum(template);
      if (_duration([...selected, exercise]) <= budget) {
        selected.add(exercise);
        originals.add(template);
      }
    }
    // Restore prescribed sets/timed intervals in rounds while budget permits.
    // Do not invent extra volume beyond the existing level/goal template just
    // to fill a long time preference.
    var changed = true;
    while (changed) {
      changed = false;
      for (var i = 0; i < selected.length; i++) {
        final current = selected[i];
        final original = originals[i];
        Exercise? upgrade;
        if (current.secondsPerSet != null &&
            current.secondsPerSet! < original.secondsPerSet!) {
          upgrade = current.withVolume(
            count: current.setCount,
            timedSeconds: math.min(
              original.secondsPerSet!,
              current.secondsPerSet! + 60,
            ),
          );
        } else if (current.setCount < original.setCount) {
          upgrade = current.withVolume(count: current.setCount + 1);
        }
        if (upgrade == null) continue;
        final candidate = [...selected]..[i] = upgrade;
        if (_duration(candidate) <= budget) {
          selected[i] = upgrade;
          changed = true;
        }
      }
    }
    return WorkoutPlan._(
      title: title,
      fitnessLevel: user.fitnessLevel,
      fitnessGoal: user.fitnessGoal,
      availableMinutes: user.workoutTime,
      description: description,
      workoutType: workoutType,
      isRecovery: isRecovery,
      minimumMinutes: (minimumSeconds / 60).ceil(),
      exercises: selected,
    );
  }
}

// Original instructions and exercise order are preserved. The fitter adjusts
// workload within these prescriptions; this remains the sole frontend engine.
class _WorkoutExerciseLibrary {
  final UserProfile user;
  _WorkoutExerciseLibrary(this.user);

  Exercise _exercise(String name, String sets, String description) {
    return Exercise(
      name: name,
      sets: sets,
      description: description,
      restSeconds: switch (user.fitnessLevel) {
        'Advanced' => 75,
        'Intermediate' => 60,
        _ => 45,
      },
    );
  }

  List<Exercise> beginnerWorkout() {
    if (user.fitnessGoal == 'Lose Weight') {
      return [
        _exercise(
          'Walking',
          '10-15 minutes',
          'Walk at a comfortable but consistent pace. '
              'Keep your posture upright.',
        ),
        _exercise(
          'Bodyweight Squats',
          '2 x 10',
          'Stand with your feet shoulder-width apart. '
              'Lower your hips slowly and return to standing.',
        ),
        _exercise(
          'Wall Push Ups',
          '2 x 10',
          'Place your hands against a wall and slowly '
              'bend your elbows. Push yourself back.',
        ),
        _exercise(
          'Step Ups',
          '2 x 10 each leg',
          'Step onto a stable platform and return to the '
              'starting position.',
        ),
        _exercise(
          'Plank',
          '2 x 20 seconds',
          'Keep your body straight while supporting '
              'yourself on your forearms.',
        ),
      ];
    }

    if (user.fitnessGoal == 'Build Muscle' ||
        user.fitnessGoal == 'Gain Weight') {
      return [
        _exercise(
          'Bodyweight Squats',
          '3 x 10',
          'Keep your chest up and lower your hips '
              'until your thighs are comfortable.',
        ),
        _exercise(
          'Knee Push Ups',
          '3 x 8',
          'Keep your knees on the floor and lower '
              'your chest toward the ground.',
        ),
        _exercise(
          'Glute Bridges',
          '3 x 12',
          'Lie on your back and drive your hips upward '
              'while squeezing your glutes.',
        ),
        _exercise(
          'Bird Dog',
          '3 x 8 each side',
          'From your hands and knees, extend the opposite '
              'arm and leg while keeping your core stable.',
        ),
        _exercise(
          'Plank',
          '3 x 20 seconds',
          'Keep your core tight and your body in a '
              'straight line.',
        ),
      ];
    }

    return [
      _exercise(
        'Bodyweight Squats',
        '2 x 10',
        'Keep your feet shoulder-width apart and '
            'perform controlled squats.',
      ),
      _exercise(
        'Wall Push Ups',
        '2 x 10',
        'Use a wall to perform an easier push-up variation.',
      ),
      _exercise(
        'Glute Bridges',
        '2 x 12',
        'Lift your hips while lying on your back.',
      ),
      _exercise(
        'Plank',
        '2 x 20 seconds',
        'Keep your core tight and maintain a straight body.',
      ),
    ];
  }

  List<Exercise> intermediateWorkout() {
    if (user.fitnessGoal == 'Lose Weight') {
      return [
        _exercise(
          'Jumping Jacks',
          '3 x 30 seconds',
          'Perform jumping jacks at a steady pace. '
              'Keep your movements controlled.',
        ),
        _exercise(
          'Bodyweight Squats',
          '3 x 15',
          'Perform controlled squats while keeping '
              'your knees aligned with your feet.',
        ),
        _exercise(
          'Mountain Climbers',
          '3 x 20',
          'Start in a plank position and alternate '
              'driving your knees toward your chest.',
        ),
        _exercise(
          'Reverse Lunges',
          '3 x 10 each leg',
          'Step backward and lower your body until '
              'your front leg is comfortably bent.',
        ),
        _exercise(
          'Burpees',
          '3 x 8',
          'Perform a squat, move into a plank, return '
              'to a squat and stand or jump.',
        ),
        _exercise(
          'Plank',
          '3 x 40 seconds',
          'Keep your core engaged and maintain a '
              'straight body position.',
        ),
      ];
    }

    if (user.fitnessGoal == 'Build Muscle' ||
        user.fitnessGoal == 'Gain Weight') {
      return [
        _exercise(
          'Push Ups',
          '4 x 12',
          'Keep your body straight and lower your chest '
              'under control.',
        ),
        _exercise(
          'Bodyweight Squats',
          '4 x 15',
          'Lower your hips while keeping your chest upright.',
        ),
        _exercise(
          'Walking Lunges',
          '3 x 12 each leg',
          'Take controlled steps forward while lowering '
              'your back knee.',
        ),
        _exercise(
          'Pike Push Ups',
          '3 x 8',
          'Position your body in an inverted V and '
              'perform a controlled push-up.',
        ),
        _exercise(
          'Single Leg Glute Bridge',
          '3 x 10 each leg',
          'Lift your hips using one leg while keeping '
              'your core stable.',
        ),
        _exercise(
          'Plank',
          '3 x 45 seconds',
          'Maintain a strong core and neutral spine.',
        ),
      ];
    }

    return [
      _exercise(
        'Push Ups',
        '3 x 12',
        'Keep your body straight and perform controlled push-ups.',
      ),
      _exercise(
        'Bodyweight Squats',
        '3 x 15',
        'Perform controlled squats through a comfortable '
            'range of motion.',
      ),
      _exercise(
        'Reverse Lunges',
        '3 x 10 each leg',
        'Step backward and lower your body under control.',
      ),
      _exercise(
        'Plank',
        '3 x 40 seconds',
        'Keep your core tight and your hips level.',
      ),
    ];
  }

  List<Exercise> advancedWorkout() {
    if (user.fitnessGoal == 'Lose Weight') {
      return [
        _exercise(
          'Burpees',
          '4 x 15',
          'Perform each repetition with controlled '
              'movement and good technique.',
        ),
        _exercise(
          'Jump Squats',
          '4 x 15',
          'Perform a squat and explosively jump upward. '
              'Land softly and repeat.',
        ),
        _exercise(
          'Mountain Climbers',
          '4 x 30',
          'Maintain a strong plank position while '
              'alternating your knees rapidly.',
        ),
        _exercise(
          'Walking Lunges',
          '4 x 15 each leg',
          'Perform controlled walking lunges while '
              'maintaining good balance.',
        ),
        _exercise(
          'High Knees',
          '4 x 45 seconds',
          'Drive your knees upward while maintaining '
              'a fast but controlled pace.',
        ),
        _exercise(
          'Plank',
          '4 x 60 seconds',
          'Keep your core fully engaged and avoid '
              'letting your hips drop.',
        ),
      ];
    }

    if (user.fitnessGoal == 'Build Muscle' ||
        user.fitnessGoal == 'Gain Weight') {
      return [
        _exercise(
          'Decline Push Ups',
          '4 x 12',
          'Place your feet on a stable elevated surface '
              'and perform controlled push-ups.',
        ),
        _exercise(
          'Bulgarian Split Squats',
          '4 x 10 each leg',
          'Place your rear foot on a stable surface '
              'and lower your body under control.',
        ),
        _exercise(
          'Diamond Push Ups',
          '4 x 10',
          'Place your hands close together and perform '
              'controlled push-ups.',
        ),
        _exercise(
          'Jump Squats',
          '4 x 15',
          'Squat down and jump explosively. Land softly.',
        ),
        _exercise(
          'Single Leg Glute Bridges',
          '4 x 15 each leg',
          'Drive your hips upward while using one leg.',
        ),
        _exercise(
          'Plank Shoulder Taps',
          '4 x 20',
          'From a plank position, alternate tapping '
              'each shoulder while minimizing hip movement.',
        ),
      ];
    }

    return [
      _exercise(
        'Decline Push Ups',
        '4 x 12',
        'Keep your body straight and perform controlled '
            'decline push-ups.',
      ),
      _exercise(
        'Bulgarian Split Squats',
        '4 x 10 each leg',
        'Perform controlled single-leg squats with '
            'your rear foot elevated.',
      ),
      _exercise(
        'Diamond Push Ups',
        '4 x 10',
        'Keep your hands close together and maintain good form.',
      ),
      _exercise(
        'Jump Squats',
        '4 x 15',
        'Explosively jump from the bottom of each squat.',
      ),
      _exercise(
        'Plank Shoulder Taps',
        '4 x 20',
        'Alternate touching your shoulders from a '
            'stable plank position.',
      ),
    ];
  }

  List<Exercise> getExercises() {
    // Maintain Weight uses the balanced template; Gain Weight intentionally
    // shares strength-oriented movements with Build Muscle.
    if (!{
      'Lose Weight',
      'Maintain Weight',
      'Gain Weight',
      'Build Muscle',
    }.contains(user.fitnessGoal)) {
      return [];
    }
    switch (user.fitnessLevel) {
      case 'Intermediate':
        return intermediateWorkout();
      case 'Advanced':
        return advancedWorkout();
      case 'Beginner':
      default:
        return beginnerWorkout();
    }
  }

  String getLevelDescription() {
    switch (user.fitnessLevel) {
      case 'Intermediate':
        return 'Moderate intensity with increased volume '
            'and more challenging exercises.';
      case 'Advanced':
        return 'High intensity with challenging movements '
            'and higher training volume.';
      case 'Beginner':
      default:
        return 'Easy-to-follow exercises designed to build '
            'strength, movement skills and consistency.';
    }
  }
}
