import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import '../services/digigym_api.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../theme/digigym_workout_theme.dart';
import '../widgets/workout_glass_card.dart';
import '../widgets/digigym_atmospheric_background.dart';
import '../widgets/workout_app_bar.dart';
import '../widgets/workout_exercise_list.dart';

/// Ordered instructions with explicit completion for signed-in workouts.
/// Navigation between steps does not mean an exercise has been completed.
class WorkoutExercisesScreen extends StatefulWidget {
  final WorkoutPlan plan;
  final bool walkthrough;
  final DigiGymApi? completionApi;
  final VoidCallback? onStreakUpdated;

  const WorkoutExercisesScreen({
    super.key,
    required this.plan,
    this.walkthrough = false,
    this.completionApi,
    this.onStreakUpdated,
  });

  @override
  State<WorkoutExercisesScreen> createState() => _WorkoutExercisesScreenState();
}

class _WorkoutExercisesScreenState extends State<WorkoutExercisesScreen> {
  int _step = 0;
  bool _saving = false;
  bool _updatingStreak = false;
  DateTime? _completedAt;
  String? _completedAccount;
  bool _saveUnconfirmed = false;
  bool _streakFailed = false;

  bool get _busy => _saving || _updatingStreak;
  bool get _canSave =>
      widget.completionApi != null &&
      !widget.plan.isRecovery &&
      widget.plan.exercises.isNotEmpty;

  Future<void> _completeWorkout() async {
    if (!_canSave || _busy || _completedAt != null) return;
    setState(() {
      _saving = true;
      _saveUnconfirmed = false;
    });

    final plan = widget.plan;
    try {
      final saved = await widget.completionApi!.completeWorkout(
        workoutName: plan.title,
        durationMinutes: plan.durationMinutes,
        details: jsonEncode([
          for (final exercise in plan.exercises)
            {
              'name': exercise.name,
              'sets': exercise.sets,
              'description': exercise.description,
            },
        ]),
      );
      if (!mounted) return;
      setState(() {
        _completedAt = saved.completedAt;
        _completedAccount = saved.authUserId.toString();
      });
    } catch (_) {
      if (mounted) setState(() => _saveUnconfirmed = true);
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    await _updateStreak();
  }

  Future<void> _updateStreak() async {
    final completedAt = _completedAt;
    if (completedAt == null || _updatingStreak) return;
    setState(() => _updatingStreak = true);
    try {
      // Use the confirmed completion timestamp even if the request or its
      // retry crosses local midnight. The API converts it to a local day.
      final api = widget.completionApi!;
      if (api.authenticatedAccountId != _completedAccount) {
        throw StateError('The workout account changed.');
      }
      await api.recordWorkoutCompletion(completedAt);
    } catch (_) {
      if (mounted) {
        setState(() {
          _streakFailed = true;
          _updatingStreak = false;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _streakFailed = false;
      _updatingStreak = false;
    });
    widget.onStreakUpdated?.call();
  }

  Widget _completionControls() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 16),
      FilledButton.icon(
        key: const ValueKey('complete-workout-button'),
        onPressed: _busy || _completedAt != null ? null : _completeWorkout,
        icon: Icon(_completedAt == null ? Icons.flag_outlined : Icons.check),
        label: Text(
          _completedAt != null
              ? 'Workout saved'
              : _saving
              ? 'Saving workout…'
              : 'Mark Workout as Completed',
        ),
      ),
      if (_saveUnconfirmed)
        const Text(
          'Could not confirm the save. Check Workout History before trying again.',
          textAlign: TextAlign.center,
        ),
      if (_updatingStreak)
        const Text('Updating streak…', textAlign: TextAlign.center),
      if (_streakFailed && !_updatingStreak) ...[
        const Text(
          'Workout saved. The streak could not be updated.',
          textAlign: TextAlign.center,
        ),
        TextButton(
          key: const ValueKey('retry-workout-streak'),
          onPressed: _busy ? null : _updateStreak,
          child: const Text('Retry streak update'),
        ),
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final resolved = DigiGymDashboardTheme.resolve(base);
    final baseTheme = DigiGymDashboardTheme.content(
      resolved.brightness == Brightness.light
          ? resolved
          : DigiGymDashboardTheme.dark(base),
    );
    final theme = DigiGymWorkoutTheme.apply(baseTheme);
    final plan = widget.plan;
    return Theme(
      data: theme,
      child: PopScope(
        canPop: !_busy,
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
                      _canSave
                          ? 'Follow the instructions at your own pace. Mark it complete to save the planned workout to history.'
                          : 'Follow the instructions at your own pace. No workout session or completions are recorded.',
                      key: const ValueKey('workout-walkthrough-notice'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    WorkoutGlassCard(
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
                        onPressed: _busy ? null : () => setState(() => _step--),
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
                      onPressed: _busy
                          ? null
                          : _step < plan.exercises.length - 1
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
                    if (_canSave && _step == plan.exercises.length - 1)
                      _completionControls(),
                  ] else ...[
                    WorkoutExerciseList(plan: plan),
                    if (_canSave) _completionControls(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
