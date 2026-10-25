import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import '../theme/digigym_dashboard_theme.dart';
import 'dashboard_glass_card.dart';
import 'dashboard_number.dart';

/// Read-only recommendation and real actions; never creates a workout session.
class WorkoutOverview extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onViewExercises;
  final VoidCallback onStartWalkthrough;

  const WorkoutOverview({
    super.key,
    required this.plan,
    required this.onViewExercises,
    required this.onStartWalkthrough,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;
    final intensity = DigiGymFitnessLevelColors.forLevel(plan.fitnessLevel);
    final start = _QuickAction(
      actionKey: const ValueKey('workout-start'),
      title: 'Start Workout',
      subtitle: 'Guided walkthrough',
      icon: Icons.play_arrow_rounded,
      onTap: onStartWalkthrough,
    );
    final exercises = _QuickAction(
      actionKey: const ValueKey('workout-view-exercises'),
      title: 'View Exercises',
      subtitle: '${plan.exercises.length} exercises',
      icon: Icons.format_list_bulleted_rounded,
      onTap: onViewExercises,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardGlassCard(
          key: const ValueKey('workout-featured'),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "TODAY'S WORKOUT",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: secondary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 18),
              DashboardNumber(
                key: const ValueKey('workout-duration'),
                value: '${plan.durationMinutes} MIN',
                fontSize: 48,
                unitFontSize: 22,
                fitToWidth: true,
              ),
              const SizedBox(height: 12),
              Text(
                plan.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.fitnessLevel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: intensity,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    key: const ValueKey('workout-featured-exercises'),
                    onPressed: onViewExercises,
                    tooltip: "View today's exercises",
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Quick Actions'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 320 ||
                MediaQuery.textScalerOf(context).scale(14) > 20) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [start, const SizedBox(height: 12), exercises],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: start),
                  const SizedBox(width: 12),
                  Expanded(child: exercises),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const _Heading('Your Goals'),
        const SizedBox(height: 12),
        DashboardGlassCard(
          key: const ValueKey('workout-goal'),
          child: Row(
            children: [
              const DashboardIconBadge(icon: Icons.flag_outlined, size: 42),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  plan.fitnessGoal,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          plan.description,
          style: theme.textTheme.bodySmall?.copyWith(color: secondary),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontSize: 19, fontWeight: FontWeight.w600),
  );
}

class _QuickAction extends StatelessWidget {
  final Key actionKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickAction({
    required this.actionKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => DashboardGlassCard(
    padding: EdgeInsets.zero,
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: actionKey,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DashboardIconBadge(icon: icon, size: 46),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
