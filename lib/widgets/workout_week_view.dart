import 'package:flutter/material.dart';

import '../models/workout_schedule_day.dart';
import 'dashboard_glass_card.dart';
import 'weekly_workout_schedule.dart';

/// Presentation of the shared schedule input. Empty data stays explicitly empty.
class WorkoutWeekView extends StatelessWidget {
  final List<WorkoutScheduleDay> days;
  final DateTime Function()? clock;
  final VoidCallback onBrowseWorkouts;

  const WorkoutWeekView({
    super.key,
    this.days = const [],
    this.clock,
    required this.onBrowseWorkouts,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      WeeklyWorkoutSchedule(
        days: days,
        clock: clock,
        onSeeAll: onBrowseWorkouts,
      ),
      if (days.isEmpty) ...[
        const SizedBox(height: 20),
        DashboardGlassCard(
          key: const ValueKey('workout-week-empty'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardIconBadge(icon: Icons.calendar_month_outlined),
              const SizedBox(height: 18),
              Text(
                'Your week is open',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'A weekly schedule has not been configured. Your recommended workout is available in Today and All Workouts.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
