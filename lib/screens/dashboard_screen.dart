import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../services/dashboard_personalization.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/fitness_goal_card.dart';
import '../widgets/plan_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/dashboard_greeting.dart';
import '../widgets/daily_streak_indicator.dart';
import '../widgets/dashboard_notification_button.dart';

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

  const DashboardPage({
    super.key,
    required this.user,
    this.motivationalMessage = DashboardPersonalization.defaultMessage,
    this.clock,
    this.streakDays,
    this.onNotifications,
  }) : assert(streakDays == null || streakDays >= 0);

  @override
  Widget build(BuildContext context) {
    // Dashboard-only typography; the sibling navigation bar retains its theme.
    final theme = DigiGymDashboardTheme.content(Theme.of(context));
    // Missing real data/actions stay hidden unless explicitly previewing a
    // debug build. No streak sample is written to a profile or local storage.
    final preview = DashboardHeaderPreview.enabled;
    final days = streakDays ?? (preview ? 7 : null);
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
                        final goal = FitnessGoalCard(
                          goal: user.fitnessGoal,
                          // Match the reference proportion at a 390px-wide
                          // display. This is a minimum, never a clipping height.
                          minimumHeight:
                              MediaQuery.sizeOf(context).width
                                  .clamp(320.0, 430.0) *
                              (190 / 390),
                        );
                        final statistics = DashboardGlassCard(
                          key: const ValueKey('dashboard-statistics-panel'),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StatCard(
                                title: 'Daily calorie target',
                                value: '${user.estimatedCalories}',
                                icon: Icons.local_fire_department,
                                iconColor: const Color(0xFFFFD35B),
                                embedded: true,
                              ),
                              const SizedBox(height: 16),
                              StatCard(
                                title: 'Workout',
                                value: '${user.workoutTime} min',
                                icon: Icons.fitness_center,
                                embedded: true,
                                dotted: false,
                              ),
                            ],
                          ),
                        );
                        final bmi = StatCard(
                          title: 'BMI',
                          value: user.bmi.toStringAsFixed(1),
                          icon: Icons.monitor_weight_outlined,
                        );
                        final weight = StatCard(
                          title: 'Weight',
                          value: '${user.weight} kg',
                          icon: Icons.scale_outlined,
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
                                if (days == null && !hasBell) return branding;
                                final actions = ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: headerConstraints.maxWidth,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (days != null)
                                        Flexible(
                                          child: DailyStreakIndicator(
                                            days: days,
                                            isPreview:
                                                streakDays == null && preview,
                                          ),
                                        ),
                                      if (days != null && hasBell)
                                        const SizedBox(width: 6),
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
                                                        'The 7-day streak is sample '
                                                        'data. Notifications are not '
                                                        'connected. No workout '
                                                        'history is being recorded.',
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
                                    (days == null
                                        ? 0
                                        : DailyStreakIndicator.preferredWidth(
                                            context,
                                            days,
                                          )) +
                                    (days != null && hasBell ? 6 : 0) +
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
                              const SizedBox(height: 12),
                              statistics,
                            ] else
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: goal),
                                    const SizedBox(width: 12),
                                    Expanded(child: statistics),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 10),
                            if (stacked) ...[
                              bmi,
                              const SizedBox(height: 12),
                              weight,
                            ] else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: bmi),
                                  const SizedBox(width: 12),
                                  Expanded(child: weight),
                                ],
                              ),
                            const SizedBox(height: 18),
                            Text(
                              'Your Plan',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 20,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            PlanCard(
                              icon: Icons.fitness_center,
                              title: "Today's Workout",
                              description:
                                  '${user.fitnessLevel} '
                                  '${user.workoutTime}-minute workout',
                            ),
                            PlanCard(
                              icon: Icons.restaurant,
                              title: "Today's Nutrition",
                              description:
                                  'Target approximately '
                                  '${user.estimatedCalories} calories',
                            ),
                            const PlanCard(
                              icon: Icons.shopping_cart_outlined,
                              title: 'Grocery List',
                              description:
                                  'View ingredients for your meal plan',
                            ),
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
