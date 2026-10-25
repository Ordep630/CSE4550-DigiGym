import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/digigym_atmospheric_background.dart';
import '../widgets/workout_app_bar.dart';

/// Existing ordered instructions, or a read-only step-by-step walkthrough.
/// Navigation between steps does not mean an exercise has been completed.
class WorkoutExercisesScreen extends StatefulWidget {
  final WorkoutPlan plan;
  final bool walkthrough;

  const WorkoutExercisesScreen({
    super.key,
    required this.plan,
    this.walkthrough = false,
  });

  @override
  State<WorkoutExercisesScreen> createState() => _WorkoutExercisesScreenState();
}

class _WorkoutExercisesScreenState extends State<WorkoutExercisesScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final theme = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.dark(Theme.of(context)),
    );
    final plan = widget.plan;
    return Theme(
      data: theme,
      child: DigiGymAtmosphericBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: workoutAppBar(
            context,
            title: widget.walkthrough ? 'Workout walkthrough' : 'Exercises',
            showBack: true,
            theme: theme,
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              key: PageStorageKey(
                widget.walkthrough ? 'walkthrough' : 'exercises',
              ),
              padding: const EdgeInsets.all(20),
              children: [
                Text(plan.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '${plan.durationMinutes} min • ${plan.exercises.length} exercises',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.walkthrough) ...[
                  Text(
                    'Follow the instructions at your own pace. No workout session or completions are recorded.',
                    key: const ValueKey('workout-walkthrough-notice'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DashboardGlassCard(
                    key: const ValueKey('workout-walkthrough-step'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Exercise ${_step + 1} of ${plan.exercises.length}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          plan.exercises[_step].name,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          plan.exercises[_step].sets,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(plan.exercises[_step].description),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_step > 0) ...[
                    OutlinedButton(
                      key: const ValueKey('workout-step-previous'),
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Text('Previous Exercise'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    key: const ValueKey('workout-step-next'),
                    onPressed: _step < plan.exercises.length - 1
                        ? () => setState(() => _step++)
                        : () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: Text(
                      _step < plan.exercises.length - 1
                          ? 'Next Exercise'
                          : 'Back to Workout',
                    ),
                  ),
                ] else ...[
                  for (var index = 0; index < plan.exercises.length; index++)
                    DashboardGlassCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.zero,
                      child: Material(
                        type: MaterialType.transparency,
                        child: ExpansionTile(
                          key: PageStorageKey('exercise-$index'),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.primary,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            plan.exercises[index].name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(plan.exercises[index].sets),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(plan.exercises[index].description),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
