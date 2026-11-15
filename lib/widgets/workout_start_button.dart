import 'dart:async';

import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import '../models/workout_record_details.dart';
import '../services/workout_session_controller.dart';
import '../services/workout_start_preference.dart';
import 'digigym_dialog.dart';
import 'weekly_workout_schedule.dart';

class WorkoutStartButton extends StatefulWidget {
  final WorkoutPlan plan;
  final WorkoutSessionController session;
  final WorkoutStartPreference? preference;

  const WorkoutStartButton({
    super.key,
    required this.plan,
    required this.session,
    this.preference,
  });

  @override
  State<WorkoutStartButton> createState() => _WorkoutStartButtonState();
}

class _WorkoutStartButtonState extends State<WorkoutStartButton> {
  bool _starting = false;

  Future<bool?> _confirmStart(WorkoutPlan plan) {
    var skip = false;
    var closed = false;
    void close(BuildContext dialogContext, bool? result) {
      if (closed) return;
      closed = true;
      Navigator.pop(dialogContext, result);
    }

    final duration = formatWorkoutTime(
      Duration(seconds: plan.estimatedSeconds),
    );
    return showDialog<bool>(
      // Let the dialog inherit the app's live appearance from the navigator.
      context: Navigator.of(context, rootNavigator: true).context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => DigiGymDialog.workoutConfirmation(
          title: 'Start Workout?',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "You're about to begin ${plan.title}. Your workout timer will start when you confirm.",
              ),
              const SizedBox(height: 12),
              Text('Planned duration · $duration'),
              const SizedBox(height: 8),
              CheckboxListTile(
                key: const ValueKey('skip-workout-start-confirmation'),
                title: const Text("Don't ask me again"),
                value: skip,
                onChanged: (value) =>
                    setDialogState(() => skip = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              key: const ValueKey('cancel-workout-start'),
              onPressed: () => close(dialogContext, null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const ValueKey('confirm-workout-start'),
              onPressed: () => close(dialogContext, skip),
              child: const Text('Start Workout'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _start() async {
    final session = widget.session;
    if (_starting || !session.canStart) return;
    setState(() => _starting = true);
    final plan = widget.plan;
    final preference =
        widget.preference ??
        WorkoutStartPreference(accountId: session.accountId);
    try {
      final shouldConfirm = await preference.confirmationEnabled();
      if (!mounted || widget.session != session || !session.canStart) return;
      final skip = shouldConfirm ? await _confirmStart(plan) : false;
      if (!mounted ||
          widget.session != session ||
          !session.canStart ||
          skip == null) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      final scroll = Scrollable.maybeOf(context);
      session.start(plan);
      unawaited(
        scroll?.position.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      );
      if (skip) {
        try {
          await preference.setConfirmationEnabled(false);
        } catch (_) {
          if (messenger != null && messenger.mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Could not save the workout preference. DigiGym will ask again next time.',
                ),
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return SizedBox.square(
      dimension: 53,
      child: DecoratedBox(
        decoration: WeeklyWorkoutSchedule.dayBadgeDecoration(
          context,
          selected: true,
          currentDayColor: accent,
        ),
        child: IconButton(
          key: const ValueKey('start-live-workout'),
          tooltip: 'Start Workout',
          onPressed: _starting ? null : _start,
          style: IconButton.styleFrom(
            foregroundColor: accent,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.play_arrow_rounded),
        ),
      ),
    );
  }
}
