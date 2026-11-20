import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/meal.dart';

import '../utils/calorie_format.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/dashboard_card_action.dart';
import '../widgets/dashboard_number.dart';
import '../widgets/meal_nutrition_summary.dart';
import '../widgets/soft_glow_icon.dart';
import '../widgets/workout_app_bar.dart';
import '../client.dart';
import '../models/meal_option_mapping.dart';
import 'meal_details_screen.dart';
import 'calorie_tracker_screen.dart';

class MealPage extends StatefulWidget {
  final UserProfile user;
  final List<Meal>? recommendations;
  const MealPage({super.key, required this.user, this.recommendations});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  List<Meal>? _meals;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    if (widget.recommendations != null) {
      setState(() => _meals = widget.recommendations);
      return;
    }

    try {
      final options = await client.mealRecommendation.getMyMealOptions();

      if (!mounted) return;

      setState(() {
        _meals = options.map(mealFromOption).toList();
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = _meals;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: workoutAppBar(context, title: 'Meals', large: true),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          key: PageStorageKey(('meals', widget.user.email)),
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
                          widget.user.estimatedCalories,
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
                    '${widget.user.fitnessGoal} · ${widget.user.dietaryPreference}',
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
            const SizedBox(height: 12),

            DashboardCardAction(
              label: 'Open Calorie Tracker',
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const CalorieTrackerScreen()),
              ),
              child: DashboardGlassCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Calorie Tracker',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
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
            if (_error != null)
              const DashboardGlassCard(
                child: Text('Unable to load meal recommendations.'),
              )
            else if (meals == null)
              const Center(child: CircularProgressIndicator())
            else if (meals.isEmpty)
              const DashboardGlassCard(
                key: ValueKey('meals-empty'),
                child: Text(
                  'No meals match your saved goal and dietary preference. You can review your preferences in Edit Profile.',
                ),
              ),
            const DashboardGlassCard(
              key: ValueKey('meals-empty'),
              child: Text(
                'No meals match your saved goal and dietary preference. You can review your preferences in Edit Profile.',
              ),
            ),
            if (meals != null)
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
                              color: theme.colorScheme.onSurfaceVariant,
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
