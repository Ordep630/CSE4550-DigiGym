import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import '../services/digigym_api.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/digigym_atmospheric_background.dart';
import '../widgets/workout_app_bar.dart';
import '../widgets/workout_exercise_list.dart';

/// Existing ordered instructions, or a read-only step-by-step walkthrough.
/// Navigation between steps does not mean an exercise has been completed.
class WorkoutExercisesScreen extends StatefulWidget {
  final WorkoutPlan plan;
  final bool walkthrough;
  final DigiGymApi api;
  final DateTime Function()? clock;

  const WorkoutExercisesScreen({
    super.key,
    required this.plan,
    this.walkthrough = false,
    this.api = digiGymApi,
    this.clock,
  });

  @override
  State<WorkoutExercisesScreen> createState() => _WorkoutExercisesScreenState();
}

class _WorkoutExercisesScreenState extends State<WorkoutExercisesScreen> {
  int _step = 0;
  bool _isSavingCompletion = false;
  bool _isCompleted = false;

  Future<void> _completeWorkout() async {
    if (_isSavingCompletion ||
        _isCompleted ||
        widget.plan.exercises.isEmpty ||
        widget.plan.isRecovery) {
      return;
    }

    setState(() => _isSavingCompletion = true);

    try {
      final details = jsonEncode(
        widget.plan.exercises.map((exercise) {
          return {
            'name': exercise.name,
            'sets': exercise.sets,
            'description': exercise.description,
          };
        }).toList(),
      );

      await widget.api.completeWorkout(
        workoutName: widget.plan.title,
        durationMinutes: widget.plan.durationMinutes,
        details: details,
      );

      // The workout is saved at this point; a streak failure must not undo it.
      int? streak;
      try {
        streak = await widget.api.recordWorkoutCompletion(
          (widget.clock ?? DateTime.now)(),
        );
      } catch (_) {
        streak = null;
      }

      if (!mounted) return;

      setState(() => _isCompleted = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            streak == null
                ? 'Workout completed! Your progress has been saved.'
                : 'Workout completed! Current streak: '
                    '$streak ${streak == 1 ? 'day' : 'days'}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save your workout. Check your connection and try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingCompletion = false);
      }
    }
  }

  Widget _completionButton() {
    return FilledButton.icon(
      key: const ValueKey('complete-workout-button'),
      onPressed: _isSavingCompletion || _isCompleted
          ? null
          : _completeWorkout,
      icon: _isSavingCompletion
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isCompleted ? Icons.check_circle : Icons.flag,
            ),
      label: Text(
        _isSavingCompletion
            ? 'Saving...'
            : _isCompleted
                ? 'Workout Completed'
                : 'Mark Workout as Completed',
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: DigiGymDarkColors.softGreen,
        foregroundColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.dark(Theme.of(context)),
    );
    final theme = baseTheme.copyWith(
      expansionTileTheme: baseTheme.expansionTileTheme.copyWith(
        textColor: DigiGymDarkColors.softGreen,
        iconColor: DigiGymDarkColors.softGreen,
      ),
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: DigiGymDarkColors.softGreen,
        primaryContainer: DigiGymDarkColors.softGreen.withValues(alpha: .12),
      ),
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
                  'Estimated ${plan.durationMinutes} min • ${plan.exercises.length} exercises',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.walkthrough && plan.exercises.isNotEmpty) ...[
                  Text(
                    plan.isRecovery
                        ? 'Follow the instructions at your own pace. Recovery workouts are not saved as completed workouts.'
                        : 'Follow the instructions at your own pace. When you finish, mark the workout as completed to save it to your history.',
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
                  if (_step == plan.exercises.length - 1 &&
                      !plan.isRecovery) ...[
                    const SizedBox(height: 12),
                    _completionButton(),
                  ],
                ] else ...[
                  WorkoutExerciseList(plan: plan),
                  if (plan.exercises.isNotEmpty && !plan.isRecovery) ...[
                    const SizedBox(height: 24),
                    _completionButton(),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}