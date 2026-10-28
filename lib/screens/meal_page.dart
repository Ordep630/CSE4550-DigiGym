import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/meal.dart';
import '../services/meal_recommendation_service.dart';
import '../utils/calorie_format.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/dashboard_card_action.dart';
import '../widgets/dashboard_number.dart';
import '../widgets/meal_nutrition_summary.dart';
import '../widgets/soft_glow_icon.dart';
import '../widgets/workout_app_bar.dart';
import 'meal_details_screen.dart';

class MealPage extends StatelessWidget {
  final UserProfile user;
  final List<Meal>? recommendations;
  const MealPage({super.key, required this.user, this.recommendations});

  List<Meal> getMeals() =>
      recommendations ?? const MealRecommendationService().recommend(user);

  @override
  Widget build(BuildContext context) {
    final meals = getMeals();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: workoutAppBar(context, title: 'Meals', large: true),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          key: PageStorageKey(('meals', user.email)),
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            DashboardGlassCard(
              key: const ValueKey('daily-nutrition'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final title = ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 24),
                        child: Text(
                          'DAILY CALORIE TARGET',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 1.1,
                          ),
                        ),
                      );
                      final target = DashboardNumber(
                        key: const ValueKey('meal-calorie-target'),
                        value: CalorieFormat.format(
                          user.estimatedCalories,
                          grouped: true,
                        ),
                        fontSize: 45,
                        dotWeight: 860,
                        unitFontSize: 18,
                        fitToWidth: true,
                      );
                      // Retain the approved layout slot so only the artwork
                      // shrinks and moves 7px nearer the card's top-right edges.
                      const flame = Padding(
                        padding: EdgeInsets.only(top: 6, right: 14),
                        child: SizedBox.square(
                          dimension: 68,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -7,
                                right: -7,
                                child: SoftGlowIcon(
                                  key: ValueKey('meal-target-flame'),
                                  icon: Icons.local_fire_department,
                                  color: SoftGlowIcon.warmAmber,
                                  size: 61.2,
                                  iconSize: 46.8,
                                  glowIntensity: .74,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      final stacked =
                          constraints.maxWidth < 300 ||
                          MediaQuery.textScalerOf(context).scale(12) > 15.6;
                      if (stacked) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: title),
                                const SizedBox(width: 8),
                                flame,
                              ],
                            ),
                            const SizedBox(height: 12),
                            target,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title,
                                const SizedBox(height: 12),
                                target,
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          flame,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${user.fitnessGoal} · ${user.dietaryPreference}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Estimated daily target. Meal options below do not constitute a full-day plan.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recommended for you',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Approximate nutrition per serving. Open a meal for ingredients.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (meals.isEmpty)
              const DashboardGlassCard(
                key: ValueKey('meals-empty'),
                child: Text(
                  'No meals match your saved goal and dietary preference. You can review your preferences in Edit Profile.',
                ),
              ),
            for (final meal in meals) ...[
              DashboardCardAction(
                key: ValueKey('meal-${meal.id}'),
                label:
                    '${meal.name}. Approximately ${CalorieFormat.format(meal.calories)}. '
                    'Protein ${meal.proteinGrams} grams, carbohydrates ${meal.carbohydrateGrams} grams, '
                    'fat ${meal.fatGrams} grams. ${meal.serving}. View meal details',
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => MealDetailsScreen(meal: meal),
                  ),
                ),
                child: DashboardGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              meal.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: DigiGymDarkColors.secondaryText,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DashboardNumber(
                        value: CalorieFormat.format(meal.calories),
                        dotted: false,
                        fontSize: 30,
                        unitFontSize: 16,
                        fitToWidth: true,
                      ),
                      const SizedBox(height: 8),
                      MealNutritionSummary(meal: meal),
                      const SizedBox(height: 10),
                      Text(
                        meal.serving,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}
