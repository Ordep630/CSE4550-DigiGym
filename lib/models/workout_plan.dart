import 'exercise.dart';
import 'user_profile.dart';

/// The existing profile-based exercise recommendation, with no session state.
/// Duration remains the saved assessment preference, as in the original screen.
class WorkoutPlan {
  final String title;
  final String fitnessLevel;
  final String fitnessGoal;
  final int durationMinutes;
  final String description;
  final List<Exercise> exercises;

  WorkoutPlan._({
    required this.title,
    required this.fitnessLevel,
    required this.fitnessGoal,
    required this.durationMinutes,
    required this.description,
    required List<Exercise> exercises,
  }) : exercises = List.unmodifiable(exercises);

  factory WorkoutPlan.forUser(UserProfile user) {
    final library = _WorkoutExerciseLibrary(user);
    return WorkoutPlan._(
      title: '${user.fitnessLevel} Workout',
      fitnessLevel: user.fitnessLevel,
      fitnessGoal: user.fitnessGoal,
      durationMinutes: user.workoutTime,
      description: library.getLevelDescription(),
      exercises: library.getExercises(),
    );
  }
}

// Moved verbatim from WorkoutsScreen. Keep these instructions, sets and ordering
// until a shared backend exercise catalogue is explicitly introduced.
class _WorkoutExerciseLibrary {
  final UserProfile user;
  _WorkoutExerciseLibrary(this.user);

  Exercise _exercise(String name, String sets, String description) {
    return Exercise(name: name, sets: sets, description: description);
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

    if (user.fitnessGoal == 'Build Muscle') {
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

    if (user.fitnessGoal == 'Build Muscle') {
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

    if (user.fitnessGoal == 'Build Muscle') {
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
