import 'package:flutter/material.dart';

import '../models/meal.dart';

/// Wrapping, readable macros; nutritional mass remains in grams.
class MealNutritionSummary extends StatelessWidget {
  final Meal meal;
  const MealNutritionSummary({super.key, required this.meal});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 8,
    children: [
      for (final (label, value) in [
        ('Protein', meal.proteinGrams),
        ('Carbs', meal.carbohydrateGrams),
        ('Fat', meal.fatGrams),
      ])
        Text(
          '$label $value g',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
    ],
  );
}
