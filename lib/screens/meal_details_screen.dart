import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/dashboard_number.dart';
import '../widgets/digigym_atmospheric_background.dart';
import '../widgets/meal_nutrition_summary.dart';
import '../widgets/workout_app_bar.dart';

class MealDetailsScreen extends StatelessWidget {
  final Meal meal;
  const MealDetailsScreen({super.key, required this.meal});
  @override
  Widget build(BuildContext context) {
    final theme = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.dark(Theme.of(context)),
    );
    return Theme(
      data: theme,
      child: DigiGymAtmosphericBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: workoutAppBar(
            context,
            title: 'Meal Details',
            showBack: true,
            theme: theme,
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  meal.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(meal.description),
                const SizedBox(height: 20),
                DashboardGlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardNumber(
                        value: '${meal.calories} kcal',
                        dotted: false,
                        fontSize: 38,
                        fitToWidth: true,
                      ),
                      const SizedBox(height: 10),
                      MealNutritionSummary(meal: meal),
                      const SizedBox(height: 12),
                      Text('Serving: ${meal.serving}'),
                      const SizedBox(height: 8),
                      Text(
                        'Approximate nutrition per serving.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Ingredients', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                DashboardGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in meal.ingredients)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '${item.quantity.label} · ${item.ingredient.name}',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ingredient quantities are based on one serving.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
