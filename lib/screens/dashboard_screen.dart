import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../models/workout_record_details.dart';
import '../services/dashboard_personalization.dart';
import '../services/workout_schedule_controller.dart';
import '../services/workout_session_controller.dart';
import '../services/workout_scheduling.dart';
import '../models/workout_schedule_day.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/dashboard_progress_card.dart';
import '../widgets/digigym_dialog.dart';
import '../widgets/digigym_brand_logo.dart';
import '../widgets/monthly_activity_calendar.dart';
import '../widgets/stat_card.dart';
import '../widgets/dashboard_greeting.dart';
import '../widgets/daily_streak_indicator.dart';
import '../widgets/dashboard_notification_button.dart';
import '../widgets/dashboard_card_action.dart';
import '../widgets/weekly_workout_schedule.dart';

/// Opt-in visual review only. The flag cannot enable samples in profile/release.
abstract final class DashboardHeaderPreview {
  static const enabled =
      kDebugMode && bool.fromEnvironment('DIGIGYM_HEADER_PREVIEW');
}

class DashboardPage extends StatelessWidget {
  final UserProfile user;
  final String motivationalMessage;
  final DateTime Function()? clock;
  final int? streakDays;
  final bool streakUnavailable;
  final VoidCallback? onViewStreak;
  final VoidCallback? onNotifications;
  final ValueChanged<int>? onSelectTab;
  final VoidCallback? onEditProfile;
  final WorkoutScheduleController? workoutSchedule;
  final VoidCallback? onSeeWeek;
  final ValueChanged<WorkoutScheduleDay>? onScheduleDay;
  final WorkoutSessionController? session;
  final ValueChanged<DateTime>? onActivitySelected;
  final VoidCallback? onActivityDayChanged;

  const DashboardPage({
    super.key,
    required this.user,
    this.motivationalMessage = DashboardPersonalization.defaultMessage,
    this.clock,
    this.streakDays,
    this.streakUnavailable = false,
    this.onViewStreak,
    this.onNotifications,
    this.onSelectTab,
    this.onEditProfile,
    this.workoutSchedule,
    this.onSeeWeek,
    this.onScheduleDay,
    this.session,
    this.onActivitySelected,
    this.onActivityDayChanged,
  }) : assert(streakDays == null || streakDays >= 0);

  ({double progress, String? caption, Duration? elapsed}) _workoutProgress() {
    final workout = session;
    if (workout != null) {
      if (workout.phase != null &&
          workout.phase != WorkoutSessionPhase.saved &&
          workout.timed) {
        final elapsed = workout.elapsed;
        return (
          progress: _percentage(elapsed, workout.planned),
          caption: 'Time target',
          elapsed: elapsed,
        );
      }
      final today = workoutLocalDate((clock ?? DateTime.now)());
      for (final entry in workout.history.value) {
        if (workoutLocalDate(entry.completedAt) != today) continue;
        final details = WorkoutRecordDetails.decode(entry.details);
        final elapsed = details.activeTime;
        final planned = details.plannedSeconds;
        if (elapsed != null && planned != null) {
          return (
            progress: _percentage(elapsed, Duration(seconds: planned)),
            caption: 'Saved',
            elapsed: null,
          );
        }
      }
    }
    return (progress: 0, caption: null, elapsed: null);
  }

  static double _percentage(Duration elapsed, Duration planned) =>
      (100 * elapsed.inMilliseconds / planned.inMilliseconds).clamp(0.0, 100.0);

  Widget _liveMetric(WidgetBuilder build) {
    final workout = session;
    return workout == null
        ? Builder(builder: build)
        : ListenableBuilder(
            listenable: Listenable.merge([workout, workout.history]),
            builder: (context, _) => build(context),
          );
  }

  Widget _monthlyActivity(Color accent) {
    final workout = session;
    return workout == null
        ? MonthlyActivityCalendar(clock: clock, highlightColor: accent)
        : ValueListenableBuilder(
            valueListenable: workout.history,
            builder: (context, history, _) => MonthlyActivityCalendar(
              clock: clock,
              highlightColor: accent,
              days: [
                for (final date
                    in history
                        .map((row) => workoutLocalDate(row.completedAt))
                        .toSet())
                  WorkoutScheduleDay(date: date, isCompleted: true),
              ],
              onCompletedDate: onActivitySelected,
              onTodayChanged: onActivityDayChanged,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    // Dashboard-only typography; the sibling navigation bar retains its theme.
    final theme = DigiGymDashboardTheme.content(Theme.of(context));
    final surfaces = DigiGymSurfaces.of(context);
    // A missing streak is neutral, never a fabricated workout count.
    final preview = DashboardHeaderPreview.enabled;
    final days = streakDays;
    // HomeScreen supplies the measured pill + system inset through extendBody.
    // Keep it in scroll content, not an outer SafeArea that clips glass/shadows
    // along a rectangular boundary above the pill (especially visible on iOS).
    final navigationInset = MediaQuery.paddingOf(context).bottom;
    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox.expand(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 14 + navigationInset),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked =
                            constraints.maxWidth < 320 ||
                            MediaQuery.textScalerOf(context).scale(14) > 18.2;
                        final goal = _liveMetric((context) {
                          final metric = _workoutProgress();
                          return DashboardCardAction(
                            key: const ValueKey('dashboard-progress-action'),
                            label: metric.caption == null
                                ? "Today's Progress: 0% complete. Open Workout"
                                : "Today's Progress: ${metric.progress.round()}% of planned time. ${metric.caption == 'Saved' ? 'Workout saved. ' : ''}Open Workout",
                            onTap: onSelectTab == null
                                ? null
                                : () => onSelectTab!(1),
                            child: DashboardProgressCard(
                              progress: metric.progress,
                              caption: metric.caption,
                              ringDiameter:
                                  (148 *
                                          MediaQuery.textScalerOf(context)
                                              .scale(12) /
                                          12)
                                      .clamp(
                                        1.0,
                                        (stacked
                                                ? constraints.maxWidth
                                                : (constraints.maxWidth - 12) /
                                                      2) -
                                            24,
                                      ),
                              // Match the reference proportion at a 390px-wide
                              // display. This is a minimum, never a clipping height.
                              minimumHeight:
                                  MediaQuery.sizeOf(context).width
                                      .clamp(320.0, 430.0) *
                                  (190 / 390),
                            ),
                          );
                        });
                        final workout = _liveMetric((context) {
                          final elapsed = _workoutProgress().elapsed;
                          final active = elapsed == null
                              ? null
                              : formatWorkoutTime(elapsed);
                          return DashboardCardAction(
                            key: const ValueKey('dashboard-workout-action'),
                            label: active == null
                                ? 'Workout duration: ${user.workoutTime} minutes. Open Workout'
                                : 'Active workout time: $active. Open Workout',
                            onTap: onSelectTab == null
                                ? null
                                : () => onSelectTab!(1),
                            child: StatCard(
                              title: active == null ? 'Workout' : 'Active time',
                              iconGlowOnly: true,
                              iconColor: surfaces.accent,
                              value: active ?? '${user.workoutTime} min',
                              icon: Icons.fitness_center,
                              dotted: true,
                              fitNumber: true,
                            ),
                          );
                        });
                        // Quick navigation replaces profile/meal statistics so
                        // the dashboard stays an overview, not a duplicate tab.
                        final quickAccess = DashboardGlassCard(
                          key: const ValueKey('dashboard-quick-access'),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Quick Access',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _DashboardShortcut(
                                icon: Icons.fitness_center,
                                title: 'Workouts',
                                subtitle: 'View your exercises',
                                color: surfaces.accent,
                                onTap: onSelectTab == null
                                    ? null
                                    : () => onSelectTab!(1),
                              ),
                              _DashboardShortcut(
                                icon: Icons.restaurant_outlined,
                                title: 'Meals',
                                subtitle: 'Plan your nutrition',
                                color: surfaces.accent,
                                onTap: onSelectTab == null
                                    ? null
                                    : () => onSelectTab!(2),
                              ),
                              _DashboardShortcut(
                                icon: Icons.person_outline,
                                title: 'Profile',
                                subtitle: 'Your personal details',
                                color: surfaces.accent,
                                onTap: onSelectTab == null
                                    ? null
                                    : () => onSelectTab!(4),
                              ),
                            ],
                          ),
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LayoutBuilder(
                              builder: (context, headerConstraints) {
                                final branding = Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  child: _DashboardBranding(
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontSize: 26,
                                      height: 1.2,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.7,
                                    ),
                                  ),
                                );
                                final hasBell =
                                    onNotifications != null || preview;
                                final actions = ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: headerConstraints.maxWidth,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: DailyStreakIndicator(
                                          days: days,
                                          unavailable: streakUnavailable,
                                          onTap: onViewStreak,
                                        ),
                                      ),
                                      if (hasBell) const SizedBox(width: 6),
                                      if (hasBell)
                                        DashboardNotificationButton(
                                          isPreview:
                                              onNotifications == null &&
                                              preview,
                                          onPressed:
                                              onNotifications ??
                                              () => showDialog<void>(
                                                context: context,
                                                builder: (context) =>
                                                    DigiGymDialog(
                                                      title:
                                                          'Development preview',
                                                      content: const Text(
                                                        'Workout streaks are not available until '
                                                        'workout completion is tracked. '
                                                        'Notifications are not connected.',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            'Close',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              ),
                                        ),
                                    ],
                                  ),
                                );
                                // Measure actual lettering at the active text
                                // scale. Artwork keeps its approved dimensions.
                                const brandWidth =
                                    DigiGymBrandLogo.dashboardWidth;
                                final actionsWidth =
                                    DailyStreakIndicator.preferredWidth(
                                      context,
                                      days,
                                      unavailable: streakUnavailable,
                                    ) +
                                    (hasBell ? 6 : 0) +
                                    (hasBell ? 48 : 0);
                                if (brandWidth + 12 + actionsWidth >
                                    headerConstraints.maxWidth) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      branding,
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 18,
                                        ),
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: actions,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                // Keep the original 18px branding gaps and bell
                                // center; actions occupy the existing free area.
                                return Stack(
                                  children: [
                                    branding,
                                    PositionedDirectional(
                                      end: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(child: actions),
                                    ),
                                  ],
                                );
                              },
                            ),
                            DashboardGreeting(
                              clock: clock,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _DashboardName(name: user.name),
                            const SizedBox(height: 5),
                            Text(
                              motivationalMessage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (stacked) ...[
                              goal,
                              const SizedBox(height: 10),
                              workout,
                              const SizedBox(height: 12),
                              quickAccess,
                            ] else
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          goal,
                                          const SizedBox(height: 10),
                                          workout,
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: quickAccess),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 18),
                            WeeklyWorkoutSchedule(
                              clock: clock,
                              daysForWeek: workoutSchedule == null
                                  ? null
                                  : (date) => WorkoutScheduling.week(
                                      user: user,
                                      workoutDays: workoutSchedule!.workoutDays,
                                      date: date,
                                    ).map((day) => day.presentation).toList(),
                              onDaySelected: onScheduleDay,
                              scheduledColor: surfaces.accent,
                              seeAllColor: surfaces.accent,
                              currentDayColor: surfaces.accent,
                              onSeeAll:
                                  onSeeWeek ??
                                  (onSelectTab == null
                                      ? null
                                      : () => onSelectTab!(1)),
                            ),
                            const SizedBox(height: 18),
                            _monthlyActivity(surfaces.accent),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardName extends StatelessWidget {
  final String name;

  const _DashboardName({required this.name});

  @override
  Widget build(BuildContext context) => Text(
    name,
    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontSize: 32,
      height: 1.12,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.9,
    ),
  );
}

class _DashboardBranding extends StatelessWidget {
  final TextStyle? style;

  const _DashboardBranding({required this.style});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Preserve the prior wordmark line box and the responsive header height.
      // The original icon and gap occupied 58 logical pixels beside that box.
      final title =
          TextPainter(
            text: TextSpan(text: 'DigiGym', style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            locale: Localizations.maybeLocaleOf(context),
          )..layout(
            maxWidth: (constraints.maxWidth - 58).clamp(0, double.infinity),
          );
      final height = title.height.clamp(48 * 331 / 796, double.infinity);
      title.dispose();
      return SizedBox(
        height: height,
        child: const Align(
          alignment: AlignmentDirectional.centerStart,
          child: DigiGymBrandLogo(
            key: ValueKey('dashboard-brand-logo'),
            layout: DigiGymLogoLayout.horizontal,
            width: DigiGymBrandLogo.dashboardWidth,
            height: DigiGymBrandLogo.dashboardHeight,
          ),
        ),
      );
    },
  );
}

/// Compact shortcut matching the dashboard's existing glass-card styling.
class _DashboardShortcut extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _DashboardShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
