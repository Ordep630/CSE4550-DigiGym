import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/fitness_goal_card.dart';
import '../widgets/plan_card.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  final UserProfile user;

  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Dashboard-only typography; the sibling navigation bar retains its theme.
    final theme = DigiGymDashboardTheme.content(Theme.of(context));
    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              color: DigiGymDarkColors.graphite,
              gradient: RadialGradient(
                center: Alignment(1.2, -0.6),
                radius: 1.6,
                colors: [Color(0xFF202C30), DigiGymDarkColors.graphite],
                stops: [0, 0.85],
              ),
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-1.1, 1.2),
                  radius: 1.25,
                  colors: [Color(0x0D39FF98), Color(0x0039FF98)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked =
                              constraints.maxWidth < 320 ||
                              MediaQuery.textScalerOf(context).scale(14) > 18.2;
                          final goal = FitnessGoalCard(goal: user.fitnessGoal);
                          final statistics = DashboardGlassCard(
                            key: const ValueKey('dashboard-statistics-panel'),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                StatCard(
                                  title: 'Daily calorie target',
                                  value: '${user.estimatedCalories}',
                                  icon: Icons.local_fire_department,
                                  iconColor: const Color(0xFFFFD35B),
                                  embedded: true,
                                ),
                                const SizedBox(height: 14),
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
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/digigym_workout_icon.png',
                                    width: 42,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.none,
                                    excludeFromSemantics: true,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'DigiGym',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.7,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Welcome back,',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.name,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 28,
                                  height: 1.15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.9,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                "Let's keep building a stronger you.",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 22),
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
                              const SizedBox(height: 12),
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
                              const SizedBox(height: 24),
                              Text(
                                'Your Plan',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 12),
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
      ),
    );
  }
}
