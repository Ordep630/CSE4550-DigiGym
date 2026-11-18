import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/meal.dart';
import '../services/meal_recommendation_service.dart';
import '../utils/calorie_format.dart';
import '../widgets/dashboard_card_action.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    const accent = Color(0xFF38E58B);
    final primaryText = theme.colorScheme.onSurface;
    final mutedText = theme.colorScheme.onSurfaceVariant;

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
            12,
            20,
            124 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Text(
              'YOUR NUTRITION',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: isDark ? accent : const Color(0xFF16864D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Daily Calorie Target & Meal Recommendations',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.9,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Simple meal ideas chosen for your goals.',
              style: theme.textTheme.bodyMedium?.copyWith(color: mutedText),
            ),
            const SizedBox(height: 22),

            // The target is based on the actual user profile, not sample data.
            Container(
              key: const ValueKey('daily-nutrition'),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF183C2C), Color(0xFF0B1C17)],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFF426A50)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? .14 : .10),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'DAILY CALORIE TARGET',
                          style: TextStyle(
                            color: Color(0xFFB3D3BE),
                            fontSize: 12,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF315C41),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: accent,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          CalorieFormat.format(
                            user.estimatedCalories,
                            grouped: true,
                          ),
                          key: const ValueKey('meal-calorie-target'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.8,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Cal',
                          style: TextStyle(
                            color: Color(0xFFB9D2C2),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TargetTag(
                        icon: Icons.flag_outlined,
                        label: user.fitnessGoal,
                      ),
                      _TargetTag(
                        icon: Icons.eco_outlined,
                        label: user.dietaryPreference,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Estimated daily target based on your profile. '
                    'These recommendations are not a complete daily meal plan.',
                    style: TextStyle(
                      color: Color(0xFFABC5B4),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Recommended for you',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: primaryText,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1D392C)
                        : const Color(0xFFE2F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${meals.length} options',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? accent : const Color(0xFF137745),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              'Tap any meal to see its ingredients and details.',
              style: theme.textTheme.bodySmall?.copyWith(color: mutedText),
            ),
            const SizedBox(height: 17),
            if (meals.isEmpty)
              Container(
                key: const ValueKey('meals-empty'),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'No meals match your saved goal and dietary preference. '
                  'You can review your preferences in Edit Profile.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            for (var i = 0; i < meals.length; i++) ...[
              _MealRecommendationCard(
                meal: meals[i],
                index: i,
                isDark: isDark,
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => MealDetailsScreen(meal: meals[i]),
                  ),
                ),
              ),
              const SizedBox(height: 13),
            ],
          ],
        ),
      ),
    );
  }
}

class _TargetTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TargetTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF284936),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF66ECA1), size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _MealRecommendationCard extends StatelessWidget {
  final Meal meal;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const _MealRecommendationCard({
    required this.meal,
    required this.index,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = isDark ? const Color(0xFF18251F) : Colors.white;
    final border = isDark ? const Color(0xFF34473B) : const Color(0xFFE4EBE7);
    final green = isDark ? const Color(0xFF55E996) : const Color(0xFF148A51);
    const icons = [
      Icons.ramen_dining_rounded,
      Icons.soup_kitchen_rounded,
      Icons.restaurant_rounded,
      Icons.lunch_dining_rounded,
    ];

    return DashboardCardAction(
      key: ValueKey('meal-${meal.id}'),
      label:
          '${meal.name}. Approximately ${CalorieFormat.format(meal.calories)}. '
          'Protein ${meal.proteinGrams} grams, '
          'carbohydrates ${meal.carbohydrateGrams} grams, '
          'fat ${meal.fatGrams} grams. ${meal.serving}. View meal details',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF152A20).withValues(alpha: .055),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF294734)
                        : const Color(0xFFE5F7EB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icons[index % icons.length],
                    color: green,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${CalorieFormat.format(meal.calories)} Cal',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _MacroPill(
                  label: 'Protein',
                  value: '${meal.proteinGrams}g',
                  isDark: isDark,
                ),
                _MacroPill(
                  label: 'Carbs',
                  value: '${meal.carbohydrateGrams}g',
                  isDark: isDark,
                ),
                _MacroPill(
                  label: 'Fat',
                  value: '${meal.fatGrams}g',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              meal.serving,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _MacroPill({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF26382D) : const Color(0xFFF0F5F1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 12),
    ),
  );
}
