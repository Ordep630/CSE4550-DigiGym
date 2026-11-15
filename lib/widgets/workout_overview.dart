import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../models/workout_plan.dart';
import '../models/workout_record_details.dart';
import '../services/workout_session_controller.dart';
import '../services/workout_start_preference.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../theme/digigym_dot_typography.dart';
import 'dot_matrix_text.dart';
import 'recommended_workout_glass_card.dart';
import 'workout_glass_card.dart';
import 'workout_session_controls.dart';
import 'workout_start_button.dart';

/// The recommendation and, while in use, its workout session.
class WorkoutOverview extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onViewExercises;
  final WorkoutSessionController? session;
  final WorkoutStartPreference? startPreference;

  const WorkoutOverview({
    super.key,
    required this.plan,
    required this.onViewExercises,
    this.session,
    this.startPreference,
  });

  @override
  Widget build(BuildContext context) {
    final controller = session;
    if (controller == null) return _card(context, null);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _card(context, controller),
    );
  }

  Widget _card(BuildContext context, WorkoutSessionController? controller) {
    final theme = Theme.of(context);
    final phase = controller?.phase;
    final showCountdown =
        controller != null &&
        controller.timed &&
        phase != null &&
        phase != WorkoutSessionPhase.saved;
    if (plan.exercises.isEmpty && phase == null) {
      return WorkoutGlassCard(
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

    final duration = WorkoutDurationDisplay(
      key: const ValueKey('workout-duration'),
      minutes: plan.durationMinutes,
      isLiveTimer: controller != null,
    );
    return RecommendedWorkoutGlassCard(
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
          if (showCountdown) ...[
            RepaintBoundary(
              child: _WorkoutCountdown(
                key: const ValueKey('workout-countdown'),
                session: controller,
                running: phase == WorkoutSessionPhase.running,
              ),
            ),
            Text(
              'Planned duration · ${formatWorkoutTime(controller.planned)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else if (controller != null &&
              controller.canStart &&
              plan.exercises.isNotEmpty &&
              !plan.isRecovery)
            Row(
              children: [
                Expanded(child: duration),
                const SizedBox(width: 12),
                WorkoutStartButton(
                  plan: plan,
                  session: controller,
                  preference: startPreference,
                ),
              ],
            )
          else if (plan.exercises.isNotEmpty)
            duration,
          const SizedBox(height: 12),
          Text(
            showCountdown || plan.exercises.isEmpty
                ? controller!.title!
                : plan.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (plan.exercises.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${showCountdown ? controller.exercises.length : plan.exercises.length} exercises · ${plan.fitnessGoal}',
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
          ],
          if (controller != null && phase != null) ...[
            const SizedBox(height: 12),
            WorkoutSessionControls(session: controller),
          ],
          if (controller != null &&
              controller.storageFailed &&
              !controller.ready)
            TextButton(
              onPressed: controller.retryStorage,
              child: const Text('Retry loading workout session'),
            ),
        ],
      ),
    );
  }
}

/// Rendering ticks only sample the controller. Elapsed time, pause and
/// persistence still belong to the controller.
class _WorkoutCountdown extends StatefulWidget {
  final WorkoutSessionController session;
  final bool running;

  const _WorkoutCountdown({
    super.key,
    required this.session,
    required this.running,
  });

  @override
  State<_WorkoutCountdown> createState() => _WorkoutCountdownState();
}

class _WorkoutCountdownState extends State<_WorkoutCountdown>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  ({int hundredths, bool overtime})? _rendered;

  ({int hundredths, bool overtime}) _read() {
    final remaining =
        (widget.session.planned - widget.session.elapsed).inMicroseconds;
    const microsPerHundredth = 10000;
    // Round remaining time up so zero is shown only at the target. Overtime
    // counts full hundredths since crossing it.
    return (
      hundredths: remaining < 0
          ? -remaining ~/ microsPerHundredth
          : (remaining + microsPerHundredth - 1) ~/ microsPerHundredth,
      overtime: remaining < 0,
    );
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (_read() != _rendered) setState(() {});
    });
    if (widget.running) _ticker.start();
  }

  @override
  void didUpdateWidget(_WorkoutCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.running && !_ticker.isActive) {
      _ticker.start();
    } else if (!widget.running && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = _read();
    _rendered = value;
    String two(int number) => number.toString().padLeft(2, '0');
    final whole =
        '${two(value.hundredths ~/ 6000)}:${two(value.hundredths ~/ 100 % 60)}';
    final digits = '$whole.${two(value.hundredths % 100)}';
    final color = DigiGymSurfaces.of(context).numeralInk;
    final height = MediaQuery.textScalerOf(context)
        .scale(DigiGymDotTypography.workoutHeight);
    return _WorkoutDurationSlot(
      label: value.overtime ? '+$digits overtime' : '$digits remaining',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Keep the same leading space at zero and in overtime.
          SizedBox(
            width: height * .55,
            height: height,
            child: value.overtime
                ? Center(
                    child: Text(
                      '+',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        fontFamily: DigiGymDashboardTheme.numberFont,
                        fontSize: height * .78,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: color,
                      ),
                    ),
                  )
                : null,
          ),
          _WorkoutTimerDigits(
            text: digits,
            height: height,
            hundredthsStart: whole.length,
          ),
        ],
      ),
    );
  }
}

class _WorkoutTimerDigits extends StatelessWidget {
  final String text;
  final double height;
  final int? hundredthsStart;

  const _WorkoutTimerDigits({
    required this.text,
    required this.height,
    this.hundredthsStart,
  });

  @override
  Widget build(BuildContext context) {
    final color = DigiGymSurfaces.of(context).numeralInk;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: height * .20,
      children: [
        for (var i = 0; i < text.length; i++)
          DotMatrixText.standard(
            text: text[i],
            height: i < (hundredthsStart ?? text.length)
                ? height
                : height * .85,
            fillRatio: .84,
            color: color,
            scaleWithText: false,
          ),
      ],
    );
  }
}

/// Shared corrected glyphs, retaining the former 48sp number's line box.
class WorkoutDurationDisplay extends StatelessWidget {
  final int minutes;
  final bool isLiveTimer;
  const WorkoutDurationDisplay({
    super.key,
    required this.minutes,
    this.isLiveTimer = false,
  });

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final color = Theme.of(context).colorScheme.onSurface;
    final height = scaler.scale(DigiGymDotTypography.workoutHeight);
    return _WorkoutDurationSlot(
      label: '$minutes minutes',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isLiveTimer)
            _WorkoutTimerDigits(text: '$minutes', height: height)
          else
            DotMatrixText.standard(
              text: '$minutes',
              height: height,
              color: color,
              scaleWithText: false,
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
    );
  }
}

class _WorkoutDurationSlot extends StatelessWidget {
  final String label;
  final Widget child;

  const _WorkoutDurationSlot({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: scaler.scale(57)),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            // Match the previous text paragraph's logical-pixel rounding.
            height: scaler.scale(48 * 1.2).ceilToDouble(),
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
        ),
      ),
    );
  }
}
