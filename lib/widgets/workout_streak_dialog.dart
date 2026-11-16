import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../models/workout_record_details.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../theme/digigym_workout_theme.dart';
import 'dashboard_glass_card.dart';
import 'weekly_workout_schedule.dart';

/// The streak endpoint supplies the count; confirmed history supplies the dates.
class WorkoutStreakDialog extends StatefulWidget {
  final ValueListenable<Future<int>?> streak;
  final ValueListenable<List<CompletedWorkout>>? history;
  final bool Function() isCurrentAccount;
  final DateTime Function() clock;
  final VoidCallback retryStreak;
  final Future<void> Function() loadHistory;

  const WorkoutStreakDialog({
    super.key,
    required this.streak,
    required this.history,
    required this.isCurrentAccount,
    required this.clock,
    required this.retryStreak,
    required this.loadHistory,
  });

  @override
  State<WorkoutStreakDialog> createState() => _WorkoutStreakDialogState();
}

class _WorkoutStreakDialogState extends State<WorkoutStreakDialog> {
  late Future<void>? _historyLoad;

  @override
  void initState() {
    super.initState();
    _historyLoad = widget.isCurrentAccount() ? widget.loadHistory() : null;
  }

  void _close({bool viewHistory = false}) {
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      Navigator.pop(context, viewHistory);
    }
  }

  Widget _retry(String label, VoidCallback onPressed) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      minimumSize: const Size(48, 48),
    ),
    child: Text(label),
  );

  Widget _currentStreak(Future<int> request) => FutureBuilder<int>(
    future: request,
    builder: (context, snapshot) {
      if (!widget.isCurrentAccount()) return const SizedBox.shrink();
      final theme = Theme.of(context);
      final loading = snapshot.connectionState != ConnectionState.done;
      final days = loading ? null : snapshot.data;
      return Column(
        children: [
          const _StreakFlame(size: 82),
          const SizedBox(height: 8),
          if (days != null) ...[
            Text(
              '$days',
              key: const ValueKey('streak-count'),
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 68,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              days == 1 ? 'Day Streak' : 'Days Streak',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Keep building your workout consistency!',
              textAlign: TextAlign.center,
            ),
          ] else
            Semantics(
              liveRegion: true,
              child: Text(
                loading
                    ? 'Loading current streak…'
                    : 'Current streak unavailable',
                textAlign: TextAlign.center,
              ),
            ),
          if (!loading && days == null)
            _retry('Retry streak', widget.retryStreak),
        ],
      );
    },
  );

  Widget _recentActivity() => FutureBuilder<void>(
    future: _historyLoad,
    builder: (context, snapshot) {
      if (!widget.isCurrentAccount()) return const SizedBox.shrink();
      if (snapshot.connectionState != ConnectionState.done) {
        return Semantics(
          liveRegion: true,
          child: const Text('Loading workout activity…'),
        );
      }
      if (snapshot.hasError) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              liveRegion: true,
              child: const Text('Recent workout activity is unavailable.'),
            ),
            _retry('Retry activity', () {
              if (widget.isCurrentAccount()) {
                final request = widget.loadHistory();
                setState(() {
                  _historyLoad = request;
                });
              }
            }),
          ],
        );
      }
      return ValueListenableBuilder<List<CompletedWorkout>>(
        valueListenable: widget.history!,
        builder: (context, rows, _) {
          if (!widget.isCurrentAccount()) return const SizedBox.shrink();
          final today = workoutLocalDate(widget.clock());
          final completed = rows
              .map((row) => workoutLocalDate(row.completedAt))
              .toSet();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var daysAgo = 6; daysAgo >= 0; daysAgo--)
                    Expanded(
                      child: _ActivityDay(
                        date: DateTime(
                          today.year,
                          today.month,
                          today.day - daysAgo,
                        ),
                        isToday: daysAgo == 0,
                        completedDates: completed,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              _ActivityStatus(recorded: completed.contains(today)),
            ],
          );
        },
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.resolve(Theme.of(context)),
    );
    final dialogTheme = DigiGymWorkoutTheme.confirmation(theme);
    final surfaces = DigiGymSurfaces.of(context);
    final accent = surfaces.streakAccent;
    return Theme(
      data: dialogTheme,
      child: LayoutBuilder(
        builder: (context, constraints) => Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          constraints: BoxConstraints(
            maxWidth: 440,
            maxHeight: constraints.maxHeight * .75,
          ),
          child: DashboardGlassCard(
            padding: const EdgeInsets.all(20),
            backdropSigma: DigiGymWorkoutTheme.confirmationBackdropSigma,
            lightingOpacity: DigiGymWorkoutTheme.confirmationLightingOpacity,
            child: SingleChildScrollView(
              key: const ValueKey('workout-streak-scroll'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            'Your Workout Streak',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _StreakFlame(size: 25),
                      SizedBox.square(
                        dimension: 48,
                        child: IconButton(
                          tooltip: 'Close',
                          color: theme.colorScheme.onSurfaceVariant,
                          onPressed: _close,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<Future<int>?>(
                    valueListenable: widget.streak,
                    builder: (context, request, _) {
                      if (request == null || !widget.isCurrentAccount()) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Sign in to view your workout streak and recent activity.',
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _currentStreak(request),
                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 20),
                          Semantics(
                            header: true,
                            child: Text(
                              'Your Last 7 Days',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _recentActivity(),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            key: const ValueKey('streak-view-history'),
                            onPressed: () => _close(viewHistory: true),
                            style: OutlinedButton.styleFrom(
                              side: surfaces.streak.border?.top,
                              backgroundColor: accent.withValues(alpha: .10),
                              foregroundColor: theme.colorScheme.onSurface,
                              minimumSize: const Size(48, 52),
                              padding: const EdgeInsets.all(12),
                            ),
                            icon: Icon(Icons.history_rounded, color: accent),
                            label: const Text(
                              'View Workout History',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
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

class _StreakFlame extends StatelessWidget {
  final double size;

  const _StreakFlame({required this.size});

  @override
  Widget build(BuildContext context) {
    final surfaces = DigiGymSurfaces.of(context);
    return Icon(
      Icons.local_fire_department_rounded,
      size: size,
      color: surfaces.streakAccent,
      shadows: surfaces.streak.boxShadow,
    );
  }
}

class _ActivityDay extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final Set<DateTime> completedDates;

  const _ActivityDay({
    required this.date,
    required this.isToday,
    required this.completedDates,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final surfaces = DigiGymSurfaces.of(context);
    final labels = MaterialLocalizations.of(context);
    final completed = completedDates.contains(date);
    final accent = surfaces.streakAccent;
    final id = date.toIso8601String().split('T').first;
    return Semantics(
      label:
          '${labels.formatFullDate(date)}${isToday ? ', Today' : ''}, ${completed ? 'Workout recorded' : 'No workout recorded'}',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = WeeklyWorkoutSchedule.dayBadgeSize(constraints.maxWidth);
          final badge = WeeklyWorkoutSchedule.dayBadgeDecoration(
            context,
            selected: completed,
            currentDayColor: accent,
          );
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.textScalerOf(context).scale(13) * 1.2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    labels.narrowWeekdays[date.weekday % 7],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: isToday ? FontWeight.w600 : null,
                      color: isToday
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox.square(
                dimension: size,
                child: DecoratedBox(
                  key: ValueKey('streak-badge-$id'),
                  decoration: completed
                      ? badge.copyWith(
                          color: accent.withValues(alpha: .12),
                          border: surfaces.streak.border,
                          boxShadow: surfaces.streak.boxShadow,
                        )
                      : badge,
                  child: Icon(
                    completed ? Icons.check_rounded : Icons.remove_rounded,
                    size: size * .5,
                    color: completed ? accent : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityStatus extends StatelessWidget {
  final bool recorded;

  const _ActivityStatus({required this.recorded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DashboardGlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          if (recorded)
            const _StreakFlame(size: 26)
          else
            Icon(
              Icons.event_outlined,
              color: theme.colorScheme.onSurfaceVariant,
              size: 26,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recorded
                      ? 'Workout recorded today!'
                      : 'No workout recorded today',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  recorded
                      ? 'Your consistency is building one day at a time.'
                      : "Complete a workout to add today's activity.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
