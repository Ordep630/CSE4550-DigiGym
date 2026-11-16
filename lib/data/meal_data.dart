import '../models/meal.dart';

// One catalogue. Rounded typical nutrition estimates per 100 g; preparation is
// identified in each ingredient. Recipe totals use these quantities.
// No inferred allergies, live prices, or exact calorie-target matching.
const _produce = GroceryCategory.produce;
const _protein = GroceryCategory.protein;
const _grains = GroceryCategory.grains;
const _pantry = GroceryCategory.pantry;
const _dairy = GroceryCategory.dairyAndEggs;
const _chicken = FoodIngredient(
  id: 'chicken-cooked',
  name: 'Chicken breast (cooked)',
  category: _protein,
  vegan: false,
  vegetarian: false,
  per100Grams: MealNutrition(165, 31, 0, 4),
);
const _rice = FoodIngredient(
  id: 'rice-cooked',
  name: 'Rice (cooked)',
  category: _grains,
  per100Grams: MealNutrition(130, 3, 28, 0),
);
const _broccoli = FoodIngredient(
  id: 'broccoli',
  name: 'Broccoli',
  category: _produce,
  per100Grams: MealNutrition(35, 3, 7, 0),
);
const _oil = FoodIngredient(
  id: 'olive-oil',
  name: 'Olive oil',
  category: _pantry,
  per100Grams: MealNutrition(880, 0, 0, 100),
);
const _yogurt = FoodIngredient(
  id: 'greek-yogurt',
  name: 'Plain nonfat Greek yogurt',
  category: _dairy,
  vegan: false,
  per100Grams: MealNutrition(60, 10, 4, 0),
);
const _oats = FoodIngredient(
  id: 'oats-dry',
  name: 'Oats (dry)',
  category: _grains,
  per100Grams: MealNutrition(380, 13, 68, 7),
);
const _berries = FoodIngredient(
  id: 'berries',
  name: 'Mixed berries',
  category: _produce,
  per100Grams: MealNutrition(50, 1, 12, 0),
);
const _eggs = FoodIngredient(
  id: 'eggs',
  name: 'Eggs (without shell)',
  category: _dairy,
  vegan: false,
  per100Grams: MealNutrition(145, 13, 1, 10),
);
const _bread = FoodIngredient(
  id: 'whole-wheat-bread',
  name: 'Plant-based whole-wheat bread',
  category: _grains,
  per100Grams: MealNutrition(250, 13, 43, 4),
);
const _avocado = FoodIngredient(
  id: 'avocado',
  name: 'Avocado',
  category: _produce,
  per100Grams: MealNutrition(160, 2, 9, 15),
);
const _spinach = FoodIngredient(
  id: 'spinach',
  name: 'Spinach',
  category: _produce,
  per100Grams: MealNutrition(25, 3, 4, 0),
);
const _tomato = FoodIngredient(
  id: 'tomato',
  name: 'Tomatoes',
  category: _produce,
  per100Grams: MealNutrition(20, 1, 4, 0),
);
const _tuna = FoodIngredient(
  id: 'tuna-drained',
  name: 'Tuna in water (drained)',
  category: _protein,
  vegan: false,
  vegetarian: false,
  per100Grams: MealNutrition(115, 26, 0, 1),
);
const _wrap = FoodIngredient(
  id: 'whole-wheat-wrap',
  name: 'Plant-based whole-wheat tortilla',
  category: _grains,
  per100Grams: MealNutrition(310, 9, 52, 8),
);
const _banana = FoodIngredient(
  id: 'banana',
  name: 'Bananas (peeled)',
  category: _produce,
  per100Grams: MealNutrition(90, 1, 23, 0),
);
const _soy = FoodIngredient(
  id: 'soy-milk',
  name: 'Unsweetened soy milk',
  category: _pantry,
  per100Grams: MealNutrition(35, 3, 2, 2),
);
const _peanut = FoodIngredient(
  id: 'peanut-butter',
  name: 'Plain peanut butter',
  category: _pantry,
  per100Grams: MealNutrition(590, 25, 20, 50),
);
const _salmon = FoodIngredient(
  id: 'salmon-cooked',
  name: 'Salmon (cooked)',
  category: _protein,
  vegan: false,
  vegetarian: false,
  per100Grams: MealNutrition(205, 22, 0, 12),
);
const _potato = FoodIngredient(
  id: 'potato-cooked',
  name: 'Potatoes (cooked)',
  category: _produce,
  per100Grams: MealNutrition(85, 2, 20, 0),
);
const _tofu = FoodIngredient(
  id: 'firm-tofu',
  name: 'Firm tofu',
  category: _protein,
  per100Grams: MealNutrition(145, 17, 3, 9),
);
const _lentils = FoodIngredient(
  id: 'lentils-cooked',
  name: 'Lentils (cooked)',
  category: _protein,
  per100Grams: MealNutrition(115, 9, 20, 0),
);
const _quinoa = FoodIngredient(
  id: 'quinoa-cooked',
  name: 'Quinoa (cooked)',
  category: _grains,
  per100Grams: MealNutrition(120, 4, 21, 2),
);
const _chickpeas = FoodIngredient(
  id: 'chickpeas-cooked',
  name: 'Chickpeas (cooked)',
  category: _protein,
  per100Grams: MealNutrition(165, 9, 27, 3),
);
const _cucumber = FoodIngredient(
  id: 'cucumber',
  name: 'Cucumber',
  category: _produce,
  per100Grams: MealNutrition(15, 1, 4, 0),
);
const _edamame = FoodIngredient(
  id: 'edamame-shelled',
  name: 'Edamame (shelled, cooked)',
  category: _protein,
  per100Grams: MealNutrition(120, 12, 9, 5),
);
const _beans = FoodIngredient(
  id: 'black-beans-cooked',
  name: 'Black beans (cooked)',
  category: _protein,
  per100Grams: MealNutrition(130, 9, 24, 1),
);
const _light = {'Lose Weight', 'Maintain Weight'};
const _balanced = {'Maintain Weight', 'Build Muscle'};
const _substantial = {'Build Muscle', 'Gain Weight'};
const _all = {'Lose Weight', 'Maintain Weight', 'Build Muscle', 'Gain Weight'};
MealIngredient _g(FoodIngredient ingredient, double grams) =>
    MealIngredient(ingredient, IngredientQuantity(grams, IngredientUnit.gram));
Meal _meal(
  String id,
  String name,
  String description,
  String serving,
  Set<String> goals,
  List<MealIngredient> ingredients,
) => Meal(
  id: id,
  name: name,
  description: description,
  serving: serving,
  supportedGoals: goals,
  ingredients: ingredients,
);

final List<Meal> mealCatalog = List.unmodifiable([
  _meal(
    'chicken-rice',
    'Chicken Rice Bowl',
    'Cooked chicken and rice with steamed broccoli and olive oil.',
    '1 bowl',
    _substantial,
    [_g(_chicken, 150), _g(_rice, 200), _g(_broccoli, 100), _g(_oil, 5)],
  ),
  _meal(
    'yogurt-oats',
    'Greek Yogurt & Oats',
    'Plain yogurt with oats and berries. Soak oats before serving.',
    '1 bowl',
    _all,
    [_g(_yogurt, 250), _g(_oats, 50), _g(_berries, 100)],
  ),
  _meal(
    'egg-avocado-toast',
    'Egg & Avocado Toast',
    'Cooked eggs and avocado on whole-wheat toast.',
    '2 slices with eggs and avocado',
    _balanced,
    [_g(_eggs, 100), _g(_bread, 80), _g(_avocado, 70)],
  ),
  _meal(
    'chicken-salad',
    'Grilled Chicken Salad',
    'Cooked chicken with spinach, tomatoes and an olive-oil dressing.',
    '1 salad bowl',
    _light,
    [_g(_chicken, 120), _g(_spinach, 100), _g(_tomato, 100), _g(_oil, 5)],
  ),
  _meal(
    'tuna-wrap',
    'Tuna Wrap',
    'Drained tuna, spinach and tomato in a whole-wheat wrap with plain yogurt.',
    '1 large wrap',
    _light,
    [
      _g(_tuna, 120),
      _g(_wrap, 60),
      _g(_spinach, 50),
      _g(_tomato, 50),
      _g(_yogurt, 40),
    ],
  ),
  _meal(
    'vegetable-omelette',
    'Vegetable Omelette',
    'Eggs cooked with spinach and tomato in olive oil.',
    '1 omelette',
    _light,
    [_g(_eggs, 150), _g(_spinach, 100), _g(_tomato, 100), _g(_oil, 5)],
  ),
  _meal(
    'oatmeal-banana',
    'Oatmeal & Banana',
    'Oats simmered in unsweetened soy milk, topped with banana and peanut butter.',
    '1 bowl',
    {'Maintain Weight', 'Gain Weight'},
    [_g(_oats, 60), _g(_banana, 120), _g(_soy, 200), _g(_peanut, 15)],
  ),
  _meal(
    'chicken-sandwich',
    'Chicken Sandwich',
    'Cooked chicken, spinach and tomato on whole-wheat bread.',
    '1 sandwich',
    _balanced,
    [
      _g(_chicken, 100),
      _g(_bread, 80),
      _g(_tomato, 100),
      _g(_spinach, 60),
      _g(_oil, 5),
    ],
  ),
  _meal(
    'salmon-vegetables',
    'Salmon & Vegetables',
    'Cooked salmon with potatoes and steamed broccoli.',
    '1 plate',
    _balanced,
    [_g(_salmon, 150), _g(_broccoli, 200), _g(_potato, 150), _g(_oil, 5)],
  ),
  _meal(
    'tofu-rice',
    'Tofu Vegetable Bowl',
    'Firm tofu, cooked rice and broccoli, lightly sautéed in olive oil.',
    '1 bowl',
    _substantial,
    [_g(_tofu, 200), _g(_rice, 150), _g(_broccoli, 150), _g(_oil, 5)],
  ),
  _meal(
    'lentil-quinoa',
    'Lentil & Quinoa Bowl',
    'Cooked lentils and quinoa with wilted spinach.',
    '1 bowl',
    _all,
    [_g(_lentils, 200), _g(_quinoa, 150), _g(_spinach, 100), _g(_oil, 5)],
  ),
  _meal(
    'chickpea-salad',
    'Chickpea Salad',
    'Cooked chickpeas with cucumber, tomato and olive oil.',
    '1 salad bowl',
    _light,
    [_g(_chickpeas, 180), _g(_tomato, 100), _g(_cucumber, 100), _g(_oil, 5)],
  ),
  _meal(
    'edamame-tofu',
    'Edamame & Tofu Skillet',
    'Shelled edamame, firm tofu and broccoli cooked in olive oil.',
    '1 skillet serving',
    _all,
    [_g(_edamame, 180), _g(_tofu, 150), _g(_broccoli, 150), _g(_oil, 5)],
  ),
  _meal(
    'bean-burrito',
    'Black Bean & Avocado Burrito',
    'Cooked black beans, avocado and tomato in a whole-wheat tortilla.',
    '1 large burrito',
    _substantial,
    [_g(_beans, 200), _g(_wrap, 80), _g(_tomato, 100), _g(_avocado, 70)],
  ),
  _meal(
    'overnight-oats',
    'Peanut Butter Overnight Oats',
    'Oats soaked in unsweetened soy milk with peanut butter and berries.',
    '1 bowl',
    _substantial,
    [_g(_oats, 70), _g(_soy, 200), _g(_peanut, 30), _g(_berries, 100)],
  ),
  _meal(
    'lentil-stew',
    'Lentil & Potato Stew',
    'Cooked lentils and potatoes simmered with tomato and spinach.',
    '1 bowl',
    _light,
    [
      _g(_lentils, 200),
      _g(_potato, 150),
      _g(_tomato, 150),
      _g(_spinach, 100),
      _g(_oil, 5),
    ],
  ),
]);
