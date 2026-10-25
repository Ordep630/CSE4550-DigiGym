import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../services/dashboard_personalization.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/dashboard_progress_card.dart';
import '../utils/measurement_units.dart';
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
  final VoidCallback? onNotifications;
  final ValueChanged<int>? onSelectTab;
  final VoidCallback? onEditProfile;

  const DashboardPage({
    super.key,
    required this.user,
    this.motivationalMessage = DashboardPersonalization.defaultMessage,
    this.clock,
    this.streakDays,
    this.onNotifications,
    this.onSelectTab,
    this.onEditProfile,
  }) : assert(streakDays == null || streakDays >= 0);

  @override
  Widget build(BuildContext context) {
    // Dashboard-only typography; the sibling navigation bar retains its theme.
    final theme = DigiGymDashboardTheme.content(Theme.of(context));
    // A missing streak is neutral, never a fabricated workout count.
    final preview = DashboardHeaderPreview.enabled;
    final days = streakDays;
    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox.expand(
            child: SafeArea(
              bottom: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked =
                            constraints.maxWidth < 320 ||
                            MediaQuery.textScalerOf(context).scale(14) > 18.2;
                        final goal = DashboardCardAction(
                          key: const ValueKey('dashboard-progress-action'),
                          label: "Today's Progress: 0% complete. Open Workout",
                          onTap: onSelectTab == null
                              ? null
                              : () => onSelectTab!(1),
                          child: DashboardProgressCard(
                            // There are no dated workout-completion records yet.
                            progress: 0,
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
                        final workout = DashboardCardAction(
                          key: const ValueKey('dashboard-workout-action'),
                          label:
                              'Workout duration: ${user.workoutTime} minutes. Open Workout',
                          onTap: onSelectTab == null
                              ? null
                              : () => onSelectTab!(1),
                          child: StatCard(
                            title: 'Workout',
                            value: '${user.workoutTime} min',
                            icon: Icons.fitness_center,
                            dotted: false,
                            fitNumber: true,
                          ),
                        );
                        final statistics = DashboardGlassCard(
                          key: const ValueKey('dashboard-statistics-panel'),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DashboardCardAction(
                                key: const ValueKey(
                                  'dashboard-calories-action',
                                ),
                                label:
                                    'Daily calorie target: ${user.estimatedCalories}. Open Meals',
                                onTap: onSelectTab == null
                                    ? null
                                    : () => onSelectTab!(2),
                                child: StatCard(
                                  title: 'Daily calorie target',
                                  value: '${user.estimatedCalories}',
                                  icon: Icons.local_fire_department,
                                  iconColor: const Color(0xFFFFD35B),
                                  embedded: true,
                                  fitNumber: true,
                                ),
                              ),
                              const SizedBox(height: 14),
                              DashboardCardAction(
                                key: const ValueKey('dashboard-weight-action'),
                                label:
                                    'Weight: ${MeasurementUnits.formatWeight(user.weight)}. Edit Profile',
                                onTap: onEditProfile,
                                child: StatCard(
                                  title: 'Weight',
                                  value: MeasurementUnits.formatWeight(
                                    user.weight,
                                  ),
                                  fitNumber: true,
                                  embedded: true,
                                  compactNumber: true,
                                  icon: Icons.scale_outlined,
                                ),
                              ),
                              const SizedBox(height: 14),
                              DashboardCardAction(
                                key: const ValueKey('dashboard-bmi-action'),
                                label:
                                    'BMI: ${user.bmi.toStringAsFixed(1)}. Open Profile',
                                onTap: onSelectTab == null
                                    ? null
                                    : () => onSelectTab!(4),
                                child: StatCard(
                                  title: 'BMI',
                                  value: user.bmi.toStringAsFixed(1),
                                  icon: Icons.monitor_weight_outlined,
                                  embedded: true,
                                  compactNumber: true,
                                  fitNumber: true,
                                ),
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
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/digigym_workout_icon.png',
                                        width: 48,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.none,
                                        excludeFromSemantics: true,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _DashboardWordmark(
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontSize: 26,
                                                height: 1.2,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.7,
                                              ),
                                        ),
                                      ),
                                    ],
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
                                        child: DailyStreakIndicator(days: days),
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
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Development preview',
                                                      ),
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
                                    48 +
                                    10 +
                                    (48 * 331 / 796 * 1.05) * 862 / 189;
                                final actionsWidth =
                                    DailyStreakIndicator.preferredWidth(
                                      context,
                                      days,
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
                              statistics,
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
                                    Expanded(child: statistics),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 18),
                            WeeklyWorkoutSchedule(
                              clock: clock,
                              onSeeAll: onSelectTab == null
                                  ? null
                                  : () => onSelectTab!(1),
                            ),
                            const SizedBox(height: 18),
                            MonthlyActivityCalendar(clock: clock),
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

class _DashboardWordmark extends StatelessWidget {
  final TextStyle? style;

  const _DashboardWordmark({required this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep the previous title's line box, including text-scaling wraps,
        // so the artwork replacement does not move the dashboard below it.
        final title = TextPainter(
          text: TextSpan(text: 'DigiGym', style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          locale: Localizations.maybeLocaleOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final height = title.height;
        title.dispose();

        return SizedBox(
          height: height,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Image.asset(
              'assets/images/digigym_wordmark.png',
              key: const ValueKey('dashboard-wordmark'),
              // The unchanged 48px-wide dumbbell is 331/796 as tall.
              height: 48 * 331 / 796 * 1.05,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              semanticLabel: 'DigiGym',
            ),
          ),
        );
      },
    );
  }
}
