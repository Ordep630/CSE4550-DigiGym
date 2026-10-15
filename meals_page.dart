import 'package:flutter/material.dart';

class MealsPage extends StatelessWidget {
  const MealsPage({super.key});

  static const green = Color(0xFF00FF66);
  static const background = Color(0xFF080D0C);
  static const cardColor = Color(0xFF111A18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: green,
        elevation: 0,
        title: const Text(
          'DigiGym',
          style: TextStyle(
            color: green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MEALS',
              style: TextStyle(
                color: green,
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Fuel your progress.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Meal recommendations designed around your fitness goals.',
              style: TextStyle(
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 25),

            // DAILY NUTRITION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: green),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_outlined,
                        color: green,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Nutrition',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'TODAY\'S TARGET',
                            style: TextStyle(
                              color: green,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NutritionInfo(
                        value: '2,200',
                        label: 'Calories',
                      ),
                      NutritionInfo(
                        value: '150g',
                        label: 'Protein',
                      ),
                      NutritionInfo(
                        value: '230g',
                        label: 'Carbs',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const MealSectionTitle(
              title: 'TODAY\'S MEALS',
            ),

            const SizedBox(height: 12),

            const MealCard(
              icon: Icons.breakfast_dining,
              mealType: 'BREAKFAST',
              title: 'Protein Breakfast',
              description:
                  'Eggs, whole-grain toast, Greek yogurt and fresh fruit.',
              calories: '450 kcal',
            ),

            const MealCard(
              icon: Icons.lunch_dining,
              mealType: 'LUNCH',
              title: 'Chicken Power Bowl',
              description:
                  'Grilled chicken, brown rice, vegetables and avocado.',
              calories: '620 kcal',
            ),

            const MealCard(
              icon: Icons.dinner_dining,
              mealType: 'DINNER',
              title: 'Salmon & Vegetables',
              description:
                  'Grilled salmon with vegetables and roasted potatoes.',
              calories: '580 kcal',
            ),

            const SizedBox(height: 25),

            const MealSectionTitle(
              title: 'RECOMMENDED FOR YOU',
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: green.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: green,
                    size: 35,
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personalized Meals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'More personalized meal recommendations will appear here based on your fitness goals.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class NutritionInfo extends StatelessWidget {
  final String value;
  final String label;

  const NutritionInfo({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: MealsPage.green,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class MealSectionTitle extends StatelessWidget {
  final String title;

  const MealSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: MealsPage.green,
        fontSize: 13,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final IconData icon;
  final String mealType;
  final String title;
  final String description;
  final String calories;

  const MealCard({
    super.key,
    required this.icon,
    required this.mealType,
    required this.title,
    required this.description,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MealsPage.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: MealsPage.green.withValues(alpha: 0.35),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: MealsPage.green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: MealsPage.green,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(
                    color: MealsPage.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  calories,
                  style: const TextStyle(
                    color: MealsPage.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: MealsPage.green,
          ),
        ],
      ),
    );
  }
}