import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../services/workout_calorie_summary.dart';
import '../utils/workout_calories.dart';
import 'workout_glass_card.dart';

/// Calories burned today, from the exercises in workouts saved today.
/// Resets each local day because it only counts today's history entries.
class WorkoutCalorieTracker extends StatelessWidget {
  final ValueListenable<List<CompletedWorkout>> history;
  final DateTime Function()? clock;

  const WorkoutCalorieTracker({super.key, required this.history, this.clock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<List<CompletedWorkout>>(
      valueListenable: history,
      builder: (context, rows, _) {
        final today = caloriesBurnedOn(rows, (clock ?? DateTime.now)());
        final caption = today.workouts == 0
            ? 'Complete a workout to start burning calories today.'
            : '${today.workouts} ${today.workouts == 1 ? 'workout' : 'workouts'} completed today';
        return WorkoutGlassCard(
          key: const ValueKey('workout-calorie-tracker'),
          child: Semantics(
            container: true,
            label:
                'Calories burned today: ${WorkoutCalories.format(today.calories)}. $caption',
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calories burned today',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          WorkoutCalories.format(today.calories),
                          key: const ValueKey('workout-calories-today'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          caption,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
