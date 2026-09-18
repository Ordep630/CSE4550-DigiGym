import 'package:flutter/material.dart';
import '../data/meal_data.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan'),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        size: 35,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          meal.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(meal.description),

                  const SizedBox(height: 15),

                  Text(
                    '${meal.calories} kcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Protein ${meal.protein}g'),
                      Text('Carbs ${meal.carbs}g'),
                      Text('Fat ${meal.fat}g'),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ...meal.ingredients.map(
                    (ingredient) => Text(
                      '• $ingredient',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}