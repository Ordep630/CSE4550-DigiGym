import '../generated/protocol.dart';

final List<MealOption> mealOptions = [
    MealOption(
        id: 'chicken-rice',
        name: 'Chicken Rice Bowl',
        description: 'Cooked chicken and rice with steamed broccoli and olive oil.',
        serving: '1 bowl',

        supportedGoals: [
            FitnessGoal.buildMuscle,
            FitnessGoal.gainWeight,
        ],

        compatibleDiets: [
            'No Preference',
            'High Protein',
        ],

        ingredients: [
        MealIngredientOption(
            id: 'chicken-cooked',
            name: 'Chicken breast (cooked)',
            amount: 150,
            unit: IngredientUnit.gram,
        ),
        
        MealIngredientOption(
            id: 'rice-cooked',
            name: 'Rice (cooked)',
            amount: 200,
            unit: IngredientUnit.gram,
        ),
        
        MealIngredientOption(
            id: 'broccoli',
            name: 'Broccoli (steamed)',
            amount: 100,
            unit: IngredientUnit.gram,
        ),
        
        MealIngredientOption(
            id: 'olive-oil',
            name: 'Olive Oil',
            amount: 5,
            unit: IngredientUnit.gram,
         )
        ], 
        
        calories: 590,
        carbohydrateGrams: 63,
        proteinGrams: 56,
        fatGrams: 15,
    ),

    MealOption(
        id: 'yogurt-oats',
        name: 'Greek Yogurt & Oats',
        description: 'Plain yogurt with oats and berries. Soak oats before serving.',
        serving: '1 bowl',
        supportedGoals: [
            FitnessGoal.loseWeight,
            FitnessGoal.maintainWeight,
            FitnessGoal.buildMuscle,
            FitnessGoal.gainWeight
        ],
        compatibleDiets: [
            'No Preference',
            'Vegetarian',
            'High Protein',
        ],
        ingredients: [
        MealIngredientOption(
            id: 'greek-yogurt',
            name: 'Plain nonfat Greek yogurt',
            amount: 250,
            unit: IngredientUnit.gram,
        ),

        MealIngredientOption(
            id: 'oats-dry',
            name: 'Oats (dry)',
            amount: 50,
            unit: IngredientUnit.gram,
        ),

        MealIngredientOption(
            id: 'berries',
            name: 'Mixed berries',
            amount: 100,
            unit: IngredientUnit.gram,
        )
        ],
        calories: 390,
        carbohydrateGrams: 56,
        proteinGrams: 33,
        fatGrams: 4,
    ),

    MealOption(
  id: 'lentil-quinoa',
  name: 'Lentil & Quinoa Bowl',
  description: 'Cooked lentils and quinoa with wilted spinach.',
  serving: '1 bowl',
  supportedGoals: [
    FitnessGoal.loseWeight,
    FitnessGoal.maintainWeight,
    FitnessGoal.buildMuscle,
    FitnessGoal.gainWeight,
  ],
  compatibleDiets: [
    'No Preference',
    'Vegetarian',
    'Vegan',
  ],
  ingredients: [
    MealIngredientOption(
      id: 'lentils-cooked',
      name: 'Lentils (cooked)',
      amount: 200,
      unit: IngredientUnit.gram,
    ),
    MealIngredientOption(
      id: 'quinoa-cooked',
      name: 'Quinoa (cooked)',
      amount: 150,
      unit: IngredientUnit.gram,
    ),
    MealIngredientOption(
      id: 'spinach',
      name: 'Spinach',
      amount: 100,
      unit: IngredientUnit.gram,
    ),
    MealIngredientOption(
      id: 'olive-oil',
      name: 'Olive oil',
      amount: 5,
      unit: IngredientUnit.gram,
    ),
  ],
        calories: 480,
        carbohydrateGrams: 76,
        proteinGrams: 27,
        fatGrams: 10,
),
    
];

