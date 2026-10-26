import 'package:flutter/material.dart';

import '../screens/workout_exercises_screen.dart';
import '../services/workout_scheduling.dart';
import '../theme/digigym_dashboard_theme.dart';

Future<void> showWorkoutDay(
  BuildContext context,
  AssignedWorkoutDay day, {
  VoidCallback? onSetUp,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) {
    const names = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final plan = day.plan;
    final base = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.dark(Theme.of(context)),
    );
    final theme = base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: DigiGymDarkColors.softGreen,
      ),
    );
    return Theme(
      data: theme,
      child: AlertDialog(
        title: Text(
          '${names[day.date.weekday % 7]} · ${day.date.month}/${day.date.day}',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                !day.configured
                    ? 'Schedule not configured'
                    : day.isWorkout
                    ? 'Workout'
                    : 'Rest Day',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (!day.configured)
                const Text(
                  'Choose your workout days to build your weekly schedule.',
                )
              else if (!day.isWorkout)
                const Text(
                  'A scheduled rest day. Take time to recover; no workout is assigned.',
                )
              else if (plan == null)
                const Text(
                  'No meaningful workout fits your available time. Increase your workout duration in Edit Profile.',
                )
              else ...[
                Text(plan.title),
                const SizedBox(height: 8),
                Text(
                  'Estimated ${plan.durationMinutes} min · ${plan.exercises.length} exercises',
                ),
                const SizedBox(height: 8),
                Text(plan.fitnessGoal),
                if (plan.isRecovery)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'A lighter recovery option between strength days.',
                    ),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          if (!day.configured && onSetUp != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onSetUp();
              },
              child: const Text('Set Up Schedule'),
            ),
          if (plan != null)
            FilledButton(
              key: const ValueKey('schedule-view-workout'),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => WorkoutExercisesScreen(plan: plan),
                  ),
                );
              },
              child: const Text('View Workout'),
            ),
        ],
      ),
    );
  },
);
