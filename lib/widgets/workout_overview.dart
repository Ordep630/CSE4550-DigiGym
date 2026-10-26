import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import 'dashboard_glass_card.dart';
import '../theme/digigym_dashboard_theme.dart';
import 'dot_matrix_text.dart';

/// The authoritative recommendation, with no completion or session side effects.
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
    if (plan.exercises.isEmpty) {
      return DashboardGlassCard(
        key: const ValueKey('workout-time-empty'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No workout fits your current time budget.',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              plan.minimumMinutes == 0
                  ? 'No recommendation is available for the saved profile. Review your fitness preferences in Edit Profile.'
                  : 'Allow at least ${plan.minimumMinutes} minutes, including a brief warm-up and cool-down. Update your available time in Edit Profile.',
            ),
          ],
        ),
      );
    }
    return DashboardGlassCard(
      key: const ValueKey('workout-featured'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'RECOMMENDED WORKOUT',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          WorkoutDurationDisplay(
            key: const ValueKey('workout-duration'),
            minutes: plan.durationMinutes,
          ),
          const SizedBox(height: 12),
          Text(
            plan.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${plan.exercises.length} exercises · ${plan.fitnessGoal}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('workout-featured-exercises'),
            onPressed: onViewExercises,
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('View Plan'),
          ),
          TextButton(
            key: const ValueKey('workout-start'),
            onPressed: onStartWalkthrough,
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: const Text('Guided walkthrough'),
          ),
        ],
      ),
    );
  }
}

/// Shared corrected glyphs, retaining the former 48sp number's line box.
class WorkoutDurationDisplay extends StatelessWidget {
  final int minutes;
  const WorkoutDurationDisplay({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final color = Theme.of(context).colorScheme.onSurface;
    // Doto's bundled cap height is 700/1000: 48sp drew ~33.6px numerals.
    // 43.2px custom dots are ~29% taller without growing the card's line box.
    final digitHeight = scaler.scale(43.2);
    return Semantics(
      label: '$minutes minutes',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: scaler.scale(57)),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            // Match the previous text paragraph's logical-pixel rounding.
            height: scaler.scale(48 * 1.2).ceilToDouble(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DotMatrixText(
                    text: '$minutes',
                    height: digitHeight,
                    color: color,
                    softenedDigits: true,
                    scaleWithText: false,
                    fillRatio: .74,
                  ),
                  SizedBox(width: scaler.scale(12)),
                  Text(
                    'MIN',
                    style: TextStyle(
                      fontFamily: DigiGymDashboardTheme.textFont,
                      fontSize: 22,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
