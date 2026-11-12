import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import 'dashboard_glass_card.dart';

/// Shared read-only prescriptions. Expanding instructions records no work.
class WorkoutExerciseList extends StatelessWidget {
  final WorkoutPlan plan;
  final int? limit;
  const WorkoutExerciseList({super.key, required this.plan, this.limit});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = limit == null || limit! > plan.exercises.length
        ? plan.exercises.length
        : limit!;
    return Column(
      key: PageStorageKey('exercise-list-${plan.title}'),
      children: [
        for (var i = 0; i < count; i++)
          DashboardGlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              child: ExpansionTile(
                key: PageStorageKey('exercise-$i'),
                title: Text(
                  plan.exercises[i].name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(plan.exercises[i].sets),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to perform',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(plan.exercises[i].description),
                        const SizedBox(height: 10),
                        Text(
                          'Estimated work and set rests: ${(plan.exercises[i].estimatedSeconds / 60).ceil()} min. '
                          '${plan.exercises[i].restSeconds} seconds rest between sets.',
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
      ],
    );
  }
}
