import 'package:flutter/material.dart';

import '../services/workout_session_controller.dart';
import '../theme/digigym_dashboard_theme.dart';
import 'digigym_dialog.dart';

class WorkoutSessionControls extends StatelessWidget {
  final WorkoutSessionController session;

  const WorkoutSessionControls({super.key, required this.session});

  Future<void> _discard(BuildContext context) async {
    final unconfirmed = session.phase == WorkoutSessionPhase.unconfirmed;
    final confirmed = await showDialog<bool>(
      context: Navigator.of(context, rootNavigator: true).context,
      builder: (dialogContext) {
        final theme = DigiGymDashboardTheme.resolve(Theme.of(dialogContext));
        final light = theme.brightness == Brightness.light;
        return DigiGymDialog.workoutConfirmation(
          title: 'Discard workout?',
          content: Text(
            unconfirmed
                ? 'This clears the local session. If the save reached the server, the entry will still appear in History.'
                : 'Your unsaved workout and its timer will be cleared.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Workout'),
            ),
            FilledButton(
              key: const ValueKey('confirm-workout-discard'),
              style: FilledButton.styleFrom(
                backgroundColor: light
                    ? theme.colorScheme.error
                    : DigiGymDarkColors.destructive,
                foregroundColor: light
                    ? theme.colorScheme.onError
                    : DigiGymDarkColors.graphite,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );
    if (context.mounted && confirmed == true) await session.discard();
  }

  // Both side actions reserve the wider label so the primary stays centered.
  Widget _sideLabel(String label) => Stack(
    alignment: Alignment.center,
    children: [
      for (final reserved in const ['Resume', 'Discard'])
        if (reserved != label)
          Opacity(
            opacity: 0,
            child: Text(reserved, textAlign: TextAlign.center),
          ),
      Text(label, textAlign: TextAlign.center),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final phase = session.phase;
    if (phase == null) return const SizedBox.shrink();
    final running = phase == WorkoutSessionPhase.running;
    final paused = phase == WorkoutSessionPhase.paused;
    final saved = phase == WorkoutSessionPhase.saved;
    final canFinish = running || paused;
    final hasTimerControls = canFinish && session.timed;
    final label = switch (phase) {
      WorkoutSessionPhase.running => 'Workout in progress',
      WorkoutSessionPhase.paused => 'Workout paused',
      WorkoutSessionPhase.saving => 'Saving workout…',
      WorkoutSessionPhase.unconfirmed => 'Workout save unconfirmed',
      WorkoutSessionPhase.saved => 'Workout saved',
    };
    final theme = Theme.of(context);
    final discardColor = theme.brightness == Brightness.light
        ? theme.colorScheme.error
        : DigiGymDarkColors.destructive;
    final discard = TextButton(
      key: const ValueKey('discard-workout'),
      onPressed: session.canDiscard ? () => _discard(context) : null,
      style: TextButton.styleFrom(
        foregroundColor: discardColor,
        padding: hasTimerControls
            ? const EdgeInsets.symmetric(horizontal: 12)
            : null,
      ),
      child: hasTimerControls ? _sideLabel('Discard') : const Text('Discard'),
    );
    const timerActionStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
    );
    final finish = FilledButton(
      key: const ValueKey('finish-workout'),
      onPressed: session.busy ? null : session.finish,
      style: hasTimerControls ? timerActionStyle : null,
      child: Text(
        'Finish and Save',
        textAlign: hasTimerControls ? TextAlign.center : null,
      ),
    );

    return Column(
      key: const ValueKey('workout-session-controls'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(liveRegion: true, child: Text(label)),
        if (phase == WorkoutSessionPhase.unconfirmed) ...[
          const SizedBox(height: 8),
          const Text(
            'Could not confirm the save. Check Workout History before discarding this session.',
          ),
        ],
        if (saved && session.streakPending && !session.busy) ...[
          const SizedBox(height: 8),
          const Text('Workout saved. The streak could not be updated.'),
        ],
        if (session.storageFailed) ...[
          const SizedBox(height: 8),
          const Text('Could not save the session on this device.'),
        ],
        const SizedBox(height: 8),
        if (hasTimerControls)
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton(
                key: const ValueKey('pause-resume-workout'),
                onPressed: session.busy
                    ? null
                    : running
                    ? session.pause
                    : session.resume,
                style: timerActionStyle,
                child: _sideLabel(running ? 'Pause' : 'Resume'),
              ),
              finish,
              discard,
            ],
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (canFinish) finish,
              if (phase == WorkoutSessionPhase.unconfirmed)
                FilledButton(
                  key: const ValueKey('check-workout-save'),
                  onPressed: session.busy ? null : session.checkSave,
                  child: const Text('Check Save'),
                ),
              if (saved && session.streakPending)
                OutlinedButton(
                  key: const ValueKey('retry-workout-streak'),
                  onPressed: session.busy ? null : session.retryStreak,
                  child: const Text('Retry streak update'),
                ),
              if (saved)
                TextButton(
                  onPressed: session.canDiscard ? session.discard : null,
                  child: const Text('Dismiss'),
                )
              else if (phase != WorkoutSessionPhase.saving)
                discard,
            ],
          ),
      ],
    );
  }
}
