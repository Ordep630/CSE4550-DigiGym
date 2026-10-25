import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/meal.dart';
import '../utils/measurement_units.dart';
import '../widgets/dashboard_glass_card.dart';

class MealPage extends StatelessWidget {
  final UserProfile user;

  const MealPage({super.key, required this.user});

  List<Meal> getMeals() {
    if (user.fitnessGoal == 'Build Muscle') {
      return [
        Meal(
          name: 'Chicken Rice Bowl',
          calories: 650,
          protein: '45g protein',
          portion: '150g chicken + 200g rice',
        ),
        Meal(
          name: 'Greek Yogurt & Oats',
          calories: 400,
          protein: '25g protein',
          portion: '250g yogurt + 50g oats',
        ),
        Meal(
          name: 'Egg & Avocado Toast',
          calories: 450,
          protein: '22g protein',
          portion: '2 eggs + 2 slices toast',
        ),
      ];
    }

    if (user.fitnessGoal == 'Lose Weight') {
      return [
        Meal(
          name: 'Grilled Chicken Salad',
          calories: 350,
          protein: '35g protein',
          portion: '120g chicken + vegetables',
        ),
        Meal(
          name: 'Tuna Wrap',
          calories: 400,
          protein: '30g protein',
          portion: '1 whole wheat wrap',
        ),
        Meal(
          name: 'Vegetable Omelette',
          calories: 300,
          protein: '24g protein',
          portion: '2 eggs + vegetables',
        ),
      ];
    }

    return [
      Meal(
        name: 'Oatmeal & Banana',
        calories: 400,
        protein: '12g protein',
        portion: '60g oats + 1 banana',
      ),
      Meal(
        name: 'Chicken Sandwich',
        calories: 500,
        protein: '35g protein',
        portion: '1 sandwich',
      ),
      Meal(
        name: 'Salmon & Vegetables',
        calories: 550,
        protein: '40g protein',
        portion: '150g salmon + vegetables',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final meals = getMeals();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.transparent
          : null,
      appBar: AppBar(title: const Text('Meal Plan')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          // Reserve the measured navigation inset inside the scroll content,
          // so the viewport does not cut glass surfaces off above the pill.
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            DashboardGlassCard(
              margin: const EdgeInsets.all(4),
              padding: EdgeInsets.zero,
              cornerRadius: 12,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Nutrition',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Estimated target: '
                      '${user.estimatedCalories} calories',
                    ),
                    Text('Goal: ${user.fitnessGoal}'),
                    Text('Diet: ${user.dietaryPreference}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            ...meals.map(
              (meal) => DashboardGlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.zero,
                cornerRadius: 12,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.restaurant)),
                  title: Text(
                    meal.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${MeasurementUnits.formatFoodPortion(meal.portion)}\n${meal.protein}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    '${meal.calories}\n kcal',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
