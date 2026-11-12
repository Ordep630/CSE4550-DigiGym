import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/workout_schedule_controller.dart';
import '../services/workout_scheduling.dart';
import '../theme/digigym_dashboard_theme.dart';
import 'dashboard_glass_card.dart';
import 'weekly_workout_schedule.dart';
import 'workout_schedule_editor.dart';
import 'workout_schedule_details.dart';

class WorkoutWeekView extends StatelessWidget {
  final UserProfile user;
  final WorkoutScheduleController controller;
  final DateTime Function()? clock;
  const WorkoutWeekView({
    super.key,
    required this.user,
    required this.controller,
    this.clock,
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WeeklyWorkoutSchedule(
            title: 'Weekly Schedule',
            showAction: controller.configured,
            actionLabel: controller.configured
                ? 'Edit Schedule'
                : 'Set Up Schedule',
            actionKey: const ValueKey('workout-edit-schedule'),
            clock: clock,
            daysForWeek: (date) => WorkoutScheduling.week(
              user: user,
              workoutDays: controller.workoutDays,
              date: date,
            ).map((day) => day.presentation).toList(),
            currentDayColor: DigiGymDarkColors.softGreen,
            scheduledColor: DigiGymDarkColors.softGreen,
            seeAllColor: DigiGymDarkColors.softGreen,
            onSeeAll: controller.canEdit
                ? () => editWorkoutSchedule(context, controller)
                : null,
            onDaySelected: (day) => showWorkoutDay(
              context,
              WorkoutScheduling.week(
                user: user,
                workoutDays: controller.workoutDays,
                date: day.date,
              ).firstWhere((assignment) => assignment.date == day.date),
              onSetUp: controller.canEdit
                  ? () => editWorkoutSchedule(context, controller)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          if (controller.loading)
            const Text('Loading your saved schedule…')
          else if (!controller.configured)
            DashboardGlassCard(
              key: const ValueKey('workout-week-empty'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choose your workout days to build your weekly schedule.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const ValueKey('workout-edit-schedule'),
                    onPressed: controller.canEdit
                        ? () => editWorkoutSchedule(context, controller)
                        : null,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Set Up Schedule'),
                  ),
                ],
              ),
            )
          else
            Text(
              'Tap a day to view its workout or rest day.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (controller.error != null) ...[
            const SizedBox(height: 8),
            Semantics(liveRegion: true, child: Text(controller.error!)),
            if (controller.hasIdentity)
              TextButton(
                onPressed: controller.loading ? null : controller.reload,
                child: const Text('Retry loading schedule'),
              ),
          ],
        ],
      );
    },
  );
}
