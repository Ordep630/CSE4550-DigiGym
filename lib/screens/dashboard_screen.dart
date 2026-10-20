import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../widgets/fitness_goal_card.dart';
import '../widgets/plan_card.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  final UserProfile user;

  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Let the content grow vertically instead of squeezing the
                  // featured section when the phone or text needs more room.
                  final stacked =
                      constraints.maxWidth < 320 ||
                      MediaQuery.textScalerOf(context).scale(14) > 18.2;
                  final goal = FitnessGoalCard(goal: user.fitnessGoal);
                  final calories = StatCard(
                    title: 'Daily calorie target',
                    value: '${user.estimatedCalories}',
                    icon: Icons.local_fire_department_outlined,
                    highlightValue: true,
                  );
                  final workout = StatCard(
                    title: 'Workout',
                    value: '${user.workoutTime} min',
                    icon: Icons.timer_outlined,
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
                            width: 44,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                            excludeFromSemantics: true,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'DigiGym',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome back,',
                        style: theme.textTheme.bodyMedium?.copyWith(
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
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (stacked) ...[
                        goal,
                        const SizedBox(height: 12),
                        calories,
                        const SizedBox(height: 12),
                        workout,
                      ] else
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 5, child: goal),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Expanded(child: calories),
                                    const SizedBox(height: 12),
                                    Expanded(child: workout),
                                  ],
                                ),
                              ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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
                        icon: Icons.shopping_cart,
                        title: 'Grocery List',
                        description: 'View ingredients for your meal plan',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
