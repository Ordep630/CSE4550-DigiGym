import 'package:digigym/main.dart';
import 'package:digigym/models/session.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/grocery_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/screens/meal_details_screen.dart';
import 'package:digigym/screens/meal_page.dart';
import 'package:digigym/services/meal_recommendation_service.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/meal_nutrition_summary.dart';
import 'package:digigym/widgets/soft_glow_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

Widget host(
  UserProfile profile, {
  double scale = 1,
  bool keyboard = false,
  TargetPlatform platform = TargetPlatform.android,
}) => MaterialApp(
  theme: ThemeData(useMaterial3: true, platform: platform),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      padding: const EdgeInsets.only(top: 52, bottom: 34),
      viewInsets: EdgeInsets.only(bottom: keyboard ? 250 : 0),
      textScaler: TextScaler.linear(scale),
    ),
    child: child!,
  ),
  home: HomeScreen(
    user: profile,
    onLogout: () async {},
    onUpdateProfile: (_) {},
  ),
);
Future<void> tab(WidgetTester tester, String name) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FloatingBottomNavigationBar),
      matching: find.text(name),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
  scroll.position.jumpTo(0);
  await tester.pumpAndSettle();
  for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
    scroll.position.jumpTo(
      (scroll.position.pixels + 250).clamp(0, scroll.position.maxScrollExtent),
    );
    await tester.pumpAndSettle();
  }
  expect(finder, findsOneWidget);
}

Future<void> press(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) await reveal(tester, finder);
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0);
  await tester.pumpAndSettle();
  final rect = tester.getRect(finder);
  final nav = find.byType(FloatingBottomNavigationBar);
  final bottom =
      find.byType(AlertDialog).evaluate().isNotEmpty || nav.evaluate().isEmpty
      ? tester.view.physicalSize.height / tester.view.devicePixelRatio
      : tester.getRect(nav).top;
  final appbar = find.byType(AppBar);
  final top = appbar.evaluate().isEmpty
      ? 0.0
      : tester.getRect(appbar.first).bottom;
  final visible = rect.intersect(
    Rect.fromLTRB(
      0,
      top,
      tester.view.physicalSize.width / tester.view.devicePixelRatio,
      bottom,
    ),
  );
  await tester.tapAt(visible.center);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    for (final entry in {
      'DigiGymInter': 'Inter',
      'DigiGymDoto': 'Doto',
    }.entries) {
      await (FontLoader(entry.key)..addFont(
            rootBundle.load('assets/fonts/${entry.value}-Variable.ttf'),
          ))
          .load();
    }
  });
  tearDown(() => DigiGymSession.currentUser = null);
  testWidgets(
    'Meals uses shared primary heading and opens complete approximate nutrition details',
    (tester) async {
      final profile = testUser();
      await tester.pumpWidget(host(profile));
      await tester.pumpAndSettle();
      await tab(tester, 'Profile');
      final profileHeadingGap =
          tester.getRect(find.byKey(const ValueKey('profile-user-card'))).top -
          tester.getRect(find.byType(AppBar)).bottom;
      await tab(tester, 'Meals');
      final appbar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appbar.titleTextStyle?.fontSize, 30);
      expect(appbar.titleTextStyle?.fontWeight, FontWeight.w700);
      expect(find.text('DAILY CALORIE TARGET'), findsOneWidget);
      final target = tester.widget<DashboardNumber>(
        find.byKey(const ValueKey('meal-calorie-target')),
      );
      expect(target.value, '1,920 kcal');
      expect(target.dotted, isTrue);
      expect(target.fontSize, 45);
      expect(target.dotWeight, 860);
      expect(target.unitFontSize, 18);
      final targetText = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('meal-calorie-target')),
          matching: find.byType(Text),
        ),
      );
      final spans = (targetText.textSpan! as TextSpan).children!
          .cast<TextSpan>();
      expect(spans.first.style?.fontFamily, DigiGymDashboardTheme.numberFont);
      expect(spans.first.style?.fontVariations, [
        const FontVariation('ROND', 100),
        const FontVariation('wght', 860),
      ]);
      expect(spans.last.style?.fontFamily, DigiGymDashboardTheme.textFont);
      final flame = find.byKey(const ValueKey('meal-target-flame'));
      expect(tester.widget<SoftGlowIcon>(flame).color, SoftGlowIcon.warmAmber);
      expect(tester.getSize(flame).width, closeTo(61.2, .001));
      expect(tester.getSize(flame).height, closeTo(61.2, .001));
      expect(tester.widget<SoftGlowIcon>(flame).glowIntensity, .74);
      expect(
        tester
            .widget<Icon>(
              find.descendant(of: flame, matching: find.byType(Icon)),
            )
            .size,
        46.8,
      );
      final flameWell =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: flame,
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(flameWell.shape, BoxShape.circle);
      expect(flameWell.border, isNull);
      expect(
        flameWell.gradient!.colors.every((color) => color.a <= .17),
        isTrue,
      );
      expect(
        find.descendant(of: flame, matching: find.byType(IgnorePointer)),
        findsOneWidget,
      );
      final flameBounds = tester.getRect(flame);
      final titleBounds = tester.getRect(find.text('DAILY CALORIE TARGET'));
      expect(flameBounds.left, greaterThanOrEqualTo(titleBounds.right + 8));
      final targetBounds = tester.getRect(
        find.byKey(const ValueKey('meal-calorie-target')),
      );
      expect(flameBounds.overlaps(targetBounds), isFalse);
      final nutritionBounds = tester.getRect(
        find.byKey(const ValueKey('daily-nutrition')),
      );
      expect(flameBounds.top - nutritionBounds.top, closeTo(15, .001));
      expect(nutritionBounds.right - flameBounds.right, closeTo(23, .001));
      // The larger illustration fits alongside the number at normal width;
      // its card retains the prior height instead of adding a separate row.
      expect(flameBounds.top, lessThan(targetBounds.top));
      expect(flameBounds.bottom, greaterThan(targetBounds.top));
      expect(
        flameBounds.bottom,
        lessThan(
          tester
              .getRect(
                find.text(
                  '${profile.fitnessGoal} · ${profile.dietaryPreference}',
                ),
              )
              .top,
        ),
      );
      expect(
        tester.getRect(find.byKey(const ValueKey('daily-nutrition'))).top -
            tester.getRect(find.byType(AppBar)).bottom,
        profileHeadingGap,
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
      final meals = const MealRecommendationService().recommend(profile);
      expect(tester.widget<MealPage>(find.byType(MealPage)).getMeals(), meals);
      expect(
        find.textContaining('not constitute a full-day plan'),
        findsOneWidget,
      );
      final firstCard = find.byKey(ValueKey('meal-${meals.first.id}'));
      await reveal(tester, firstCard);
      final cardNumber = tester.widget<DashboardNumber>(
        find.descendant(of: firstCard, matching: find.byType(DashboardNumber)),
      );
      expect(cardNumber.dotted, isFalse);
      final calorieText = tester.widget<Text>(
        find.descendant(of: firstCard, matching: find.byType(Text)).at(1),
      );
      expect(
        ((calorieText.textSpan! as TextSpan).children!.first as TextSpan)
            .style
            ?.fontFamily,
        DigiGymDashboardTheme.textFont,
      );
      final chevron = tester.widget<Icon>(
        find.descendant(
          of: firstCard,
          matching: find.byIcon(Icons.chevron_right_rounded),
        ),
      );
      expect(chevron.color, DigiGymDarkColors.secondaryText);
      expect(chevron.size, 20);
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: firstCard,
                matching: find.text('Protein ${meals.first.proteinGrams} g'),
              ),
            )
            .style
            ?.fontFamily,
        DigiGymDashboardTheme.textFont,
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: firstCard,
                matching: find.text(meals.first.serving),
              ),
            )
            .style
            ?.fontFamily,
        DigiGymDashboardTheme.textFont,
      );
      await press(tester, firstCard);
      expect(find.byType(MealDetailsScreen), findsOneWidget);
      expect(
        tester.widget<DashboardNumber>(find.byType(DashboardNumber)).dotted,
        isFalse,
      );
      expect(find.text(meals.first.name), findsOneWidget);
      expect(find.byType(MealNutritionSummary), findsOneWidget);
      expect(
        find.text('Protein ${meals.first.proteinGrams} g'),
        findsOneWidget,
      );
      expect(
        find.text('Carbs ${meals.first.carbohydrateGrams} g'),
        findsOneWidget,
      );
      expect(find.text('Fat ${meals.first.fatGrams} g'), findsOneWidget);
      expect(find.text('Serving: ${meals.first.serving}'), findsOneWidget);
      expect(find.text('Approximate nutrition per serving.'), findsOneWidget);
      for (final ingredient in meals.first.ingredients) {
        final row = find.text(
          '${ingredient.quantity.label} · ${ingredient.ingredient.name}',
        );
        await tester.scrollUntilVisible(row, 250);
        expect(row, findsOneWidget);
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MealPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'purchases, additions, removals and undo survive tab navigation',
    (tester) async {
      await tester.pumpWidget(host(testUser()));
      await tester.pumpAndSettle();
      await tab(tester, 'Profile');
      final profileHeadingGap =
          tester.getRect(find.byKey(const ValueKey('profile-user-card'))).top -
          tester.getRect(find.byType(AppBar)).bottom;
      await tab(tester, 'Groceries');
      expect(
        tester.getRect(find.byKey(const ValueKey('grocery-summary'))).top -
            tester.getRect(find.byType(AppBar)).bottom,
        profileHeadingGap,
      );
      final controller = tester
          .widget<GroceryScreen>(find.byType(GroceryScreen))
          .controller!;
      final first = controller.items.first;
      final firstRow = find.byKey(ValueKey('grocery-row-${first.id}'));
      await reveal(tester, firstRow);
      expect(tester.getSize(firstRow).height, closeTo(62, 1));
      final remove = find.descendant(
        of: firstRow,
        matching: find.byType(IconButton),
      );
      expect(tester.getSize(remove).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(remove).width, greaterThanOrEqualTo(48));
      expect(
        tester
            .widget<Icon>(
              find.descendant(
                of: remove,
                matching: find.byIcon(Icons.close_rounded),
              ),
            )
            .color,
        DigiGymDarkColors.secondaryText,
      );
      await press(tester, find.byKey(ValueKey('grocery-check-${first.id}')));
      expect(controller.purchasedCount, 1);
      await press(tester, find.byKey(const ValueKey('grocery-add')));
      await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
      await tester.pumpAndSettle();
      expect(find.text('Enter an item name.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('grocery-custom-name')),
        'Green tea',
      );
      await tester.enterText(
        find.byKey(const ValueKey('grocery-custom-quantity')),
        '-1',
      );
      await press(tester, find.widgetWithText(FilledButton, 'Add item'));
      expect(find.text('Enter a positive quantity.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('grocery-custom-quantity')),
        '2',
      );
      await press(tester, find.widgetWithText(FilledButton, 'Add item'));
      final custom = controller.items.singleWhere((row) => row.custom);
      expect(custom.quantityLabel, '2 items');
      await tab(tester, 'Meals');
      await tab(tester, 'Groceries');
      expect(
        identical(
          tester.widget<GroceryScreen>(find.byType(GroceryScreen)).controller,
          controller,
        ),
        isTrue,
      );
      expect(controller.purchasedCount, 1);
      expect(controller.items.any((row) => row.id == custom.id), isTrue);
      await press(tester, find.byTooltip('Remove ${first.name}'));
      expect(controller.items.any((row) => row.id == first.id), isFalse);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(controller.purchasedCount, 1);
      await press(tester, find.byTooltip('Remove Green tea'));
      await tab(tester, 'Home');
      await tab(tester, 'Groceries');
      expect(controller.items.any((row) => row.custom), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'saved profile changes reconcile meals and groceries without losing custom items or leaking accounts',
    (tester) async {
      final profile = testUser();
      await tester.pumpWidget(host(profile));
      await tester.pumpAndSettle();
      await tab(tester, 'Groceries');
      final a = tester
          .widget<GroceryScreen>(find.byType(GroceryScreen))
          .controller!;
      a.addCustom('Keep my item');
      profile.dietaryPreference = 'Vegan';
      profile.fitnessGoal = 'Lose Weight';
      await tester.pumpWidget(host(profile));
      await tester.pumpAndSettle();
      expect(a.items.any((row) => row.custom), isTrue);
      final ids = a.items.map((row) => row.id).toList();
      expect(
        ids,
        isNot(
          anyElement(
            isIn([
              'chicken-cooked',
              'greek-yogurt',
              'eggs',
              'tuna-drained',
              'salmon-cooked',
            ]),
          ),
        ),
      );
      final other = testUser()..email = 'other@example.com';
      await tester.pumpWidget(host(other));
      await tester.pumpAndSettle();
      final b = tester
          .widget<GroceryScreen>(find.byType(GroceryScreen))
          .controller!;
      expect(identical(a, b), isFalse);
      expect(a.items, isEmpty);
      expect(b.items.any((row) => row.custom), isFalse);
      expect(b.purchasedCount, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('normal logout disposes account-specific grocery state', (
    tester,
  ) async {
    final api = FakeDigiGymApi()
      ..authenticated = true
      ..restoredProfile = testUser();
    await tester.pumpWidget(DigiGymApp(api: api));
    await tester.pumpAndSettle();
    await tab(tester, 'Groceries');
    final controller = tester
        .widget<GroceryScreen>(find.byType(GroceryScreen))
        .controller!;
    controller.addCustom('Clear at logout');
    await tab(tester, 'Profile');
    await press(tester, find.text('Log Out'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(controller.items, isEmpty);
    expect(api.signOutCalls, 1);
  });

  testWidgets(
    'unavailable recommendations show honest empty states and no fabricated groceries',
    (tester) async {
      final profile = testUser()..dietaryPreference = 'Unknown';
      await tester.pumpWidget(host(profile));
      await tester.pumpAndSettle();
      await tab(tester, 'Meals');
      expect(find.byKey(const ValueKey('meals-empty')), findsOneWidget);
      await tab(tester, 'Groceries');
      expect(find.byKey(const ValueKey('groceries-empty')), findsOneWidget);
      expect(find.text('0 / 0 items purchased'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0,
      );
    },
  );

  testWidgets('custom grocery input remains usable with keyboard and 3x text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 912);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final profile = testUser();
    await tester.pumpWidget(host(profile, scale: 3));
    await tester.pumpAndSettle();
    await tab(tester, 'Groceries');
    await press(tester, find.byKey(const ValueKey('grocery-add')));
    await tester.pumpWidget(host(profile, scale: 3, keyboard: true));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('grocery-custom-name')),
      'Keyboard item',
    );
    await press(tester, find.widgetWithText(FilledButton, 'Add item'));
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [280.0, 320.0, 420.0]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets(
        'Meals Groceries and details fit $width with $scale text and measured navigation clearance',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 912);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final profile = testUser();
          await tester.pumpWidget(
            host(
              profile,
              scale: scale,
              platform: width == 420
                  ? TargetPlatform.iOS
                  : TargetPlatform.android,
            ),
          );
          await tester.pumpAndSettle();
          for (final name in ['Meals', 'Groceries']) {
            await tab(tester, name);
            expect(tester.takeException(), isNull, reason: name);
            if (name == 'Meals') {
              final flame = tester.getRect(
                find.byKey(const ValueKey('meal-target-flame')),
              );
              final card = tester.getRect(
                find.byKey(const ValueKey('daily-nutrition')),
              );
              expect(flame.width, closeTo(61.2, .001));
              expect(flame.height, closeTo(61.2, .001));
              expect(card.contains(flame.topLeft), isTrue);
              expect(card.contains(flame.bottomRight), isTrue);
              for (final text in [
                find.text('DAILY CALORIE TARGET'),
                find.byKey(const ValueKey('meal-calorie-target')),
                find.text(
                  '${profile.fitnessGoal} · ${profile.dietaryPreference}',
                ),
              ]) {
                expect(
                  flame.overlaps(tester.getRect(text)),
                  isFalse,
                  reason: 'flame overlap at $width with $scale text',
                );
              }
            }
            final scroll = tester.state<ScrollableState>(
              find.byType(Scrollable).first,
            );
            final last = name == 'Meals'
                ? find.byKey(
                    ValueKey(
                      'meal-${const MealRecommendationService().recommend(profile).last.id}',
                    ),
                  )
                : find.byKey(
                    ValueKey(
                      'grocery-row-${tester.widget<GroceryScreen>(find.byType(GroceryScreen)).controller!.items.last.id}',
                    ),
                  );
            await reveal(tester, last);
            for (var i = 0; i < 40; i++) {
              scroll.position.jumpTo(scroll.position.maxScrollExtent);
              await tester.pumpAndSettle();
            }
            expect(last, findsOneWidget);
            expect(
              tester.getRect(last).bottom,
              lessThan(
                tester.getRect(find.byType(FloatingBottomNavigationBar)).top,
              ),
            );
            if (name == 'Groceries') {
              final controller = tester
                  .widget<GroceryScreen>(find.byType(GroceryScreen))
                  .controller!;
              final item = controller.items.last;
              final checkbox = find.byKey(ValueKey('grocery-check-${item.id}'));
              final control = find.descendant(
                of: checkbox,
                matching: find.byType(Checkbox),
              );
              final appbarBottom = tester.getRect(find.byType(AppBar)).bottom;
              final navigationTop = tester
                  .getRect(find.byType(FloatingBottomNavigationBar))
                  .top;
              // A tall accessible row can be larger than the usable viewport.
              // Scroll its real checkbox into that viewport, rather than asking
              // ensureVisible to align the entire row beneath the toolbar.
              scroll.position.jumpTo(
                (scroll.position.pixels +
                        tester.getRect(control).center.dy -
                        (appbarBottom + navigationTop) / 2)
                    .clamp(0, scroll.position.maxScrollExtent),
              );
              await tester.pumpAndSettle();
              expect(
                tester.getRect(control).top,
                greaterThanOrEqualTo(appbarBottom),
              );
              expect(tester.getRect(control).bottom, lessThan(navigationTop));
              await tester.tap(control);
              await tester.pumpAndSettle();
              expect(
                controller.items
                    .singleWhere((row) => row.id == item.id)
                    .purchased,
                isTrue,
              );
              expect(controller.purchasedCount, 1);
            }
            expect(tester.takeException(), isNull);
          }
          await tab(tester, 'Meals');
          final meal = const MealRecommendationService()
              .recommend(profile)
              .first;
          await reveal(tester, find.byKey(ValueKey('meal-${meal.id}')));
          await press(tester, find.byKey(ValueKey('meal-${meal.id}')));
          await tester.scrollUntilVisible(
            find.text('Ingredient quantities are based on one serving.'),
            350,
          );
          expect(tester.takeException(), isNull);
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tab(tester, 'Groceries');
          await reveal(tester, find.byKey(const ValueKey('grocery-add')));
          await press(tester, find.byKey(const ValueKey('grocery-add')));
          await tester.enterText(
            find.byKey(const ValueKey('grocery-custom-name')),
            'Responsive item',
          );
          await press(tester, find.widgetWithText(FilledButton, 'Add item'));
          expect(find.byType(AlertDialog), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
