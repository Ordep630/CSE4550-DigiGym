import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/grocery_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/services/workout_schedule_controller.dart';
import 'package:digigym/services/workout_scheduling.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/digigym_dialog.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/profile_components.dart';
import 'package:digigym/widgets/workout_schedule_details.dart';
import 'package:digigym/widgets/workout_schedule_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';


Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FloatingBottomNavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _home(
  WidgetTester tester, {
  Future<void> Function()? logout,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(420, 912);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: HomeScreen(
        user: testUser(),
        api: FakeDigiGymApi(),
        onLogout: logout ?? () async {},
        onUpdateProfile: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectSharedSurface(WidgetTester tester) {
  final dialog = find.byType(DigiGymDialog);
  expect(dialog, findsOneWidget);
  expect(find.byType(AlertDialog), findsNothing);
  final surface = tester.widget<Dialog>(
    find.descendant(of: dialog, matching: find.byType(Dialog)),
  );
  expect(surface.backgroundColor, Colors.transparent);
  expect(surface.elevation, 0);
  expect(surface.insetPadding, const EdgeInsets.all(24));
  final glass = tester.widget<DashboardGlassCard>(
    find.descendant(of: dialog, matching: find.byType(DashboardGlassCard)),
  );
  expect(glass.padding, const EdgeInsets.all(20));
  expect(glass.cornerRadius, DigiGymDashboardTheme.cardRadius);
  expect(
    find.descendant(of: dialog, matching: find.byType(BackdropFilter)),
    findsNothing,
  );
  final title = tester.widget<Text>(
    find.byKey(const ValueKey('digigym-dialog-title')),
  );
  expect(title.style?.color, DigiGymDarkColors.primaryText);
  expect(title.style?.fontFamily, DigiGymDashboardTheme.textFont);
  expect(title.style?.shadows, isNull);
}

void main() {
  testWidgets(
    'logout confirmation alone has localized red text glow and preserves Cancel and confirm',
    (tester) async {
      var calls = 0;
      await _home(
        tester,
        logout: () async {
          calls++;
        },
      );
      await _tab(tester, 'Profile');
      final pageButton = tester.widget<ProfileMenuRow>(
        find.byKey(const ValueKey('profile-logout')),
      );
      expect(pageButton.color, const Color(0xFFFF5F68));
      expect(pageButton.glow, isTrue);
      await _press(tester, find.byKey(const ValueKey('profile-logout')));
      _expectSharedSurface(tester);
      expect(find.text('Are you sure you want to log out?'), findsOneWidget);
      final confirm = find.byKey(const ValueKey('confirm-logout'));
      final button = tester.widget<TextButton>(confirm);
      expect(
        button.style?.foregroundColor?.resolve({}),
        DigiGymDarkColors.destructive,
      );
      final confirmText = tester.widget<Text>(
        find.descendant(of: confirm, matching: find.byType(Text)),
      );
      expect(confirmText.style!.shadows, isNotEmpty);
      final dialogTexts = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(DigiGymDialog),
          matching: find.byType(Text),
        ),
      );
      expect(
        dialogTexts
            .where((text) => text.style?.shadows?.isNotEmpty ?? false)
            .length,
        1,
      );
      final cancel = find.widgetWithText(TextButton, 'Cancel');
      expect(
        Theme.of(tester.element(cancel)).textButtonTheme.style!.foregroundColor!
            .resolve({}),
        DigiGymDarkColors.softGreen,
      );
      expect(tester.getSize(confirm).height, greaterThanOrEqualTo(48));
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(find.byType(Dialog), findsNothing);
      await _press(tester, find.byKey(const ValueKey('profile-logout')));
      await tester.tap(find.byKey(const ValueKey('confirm-logout')));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.byType(Dialog), findsNothing);
    },
  );

  testWidgets(
    'Groceries Add item and scoped popup use the actual Login gradient green',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(api: FakeDigiGymApi(), onLogin: (_) {}),
        ),
      );
      final gradient = tester
          .widgetList<DecoratedBox>(
            find.ancestor(
              of: find.widgetWithText(ElevatedButton, 'Login'),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((box) => box.gradient)
          .whereType<LinearGradient>()
          .firstWhere(
            (gradient) =>
                gradient.begin == Alignment.centerLeft &&
                gradient.end == Alignment.centerRight,
          );
      final loginGreen = gradient.colors.last;
      expect(loginGreen, DigiGymDarkColors.softGreen);
      await _home(tester);
      await _tab(tester, 'Groceries');
      final add = find.byKey(const ValueKey('grocery-add'));
      expect(
        tester.widget<OutlinedButton>(add).style!.foregroundColor!.resolve({}),
        loginGreen,
      );
      expect(
        IconTheme.of(
          tester.element(
            find.descendant(of: add, matching: find.byIcon(Icons.add_rounded)),
          ),
        ).color,
        loginGreen,
      );
      final screen = tester.widget<GroceryScreen>(find.byType(GroceryScreen));
      final count = screen.controller!.items.length;
      await _press(tester, add);
      _expectSharedSurface(tester);
      final input = find.byKey(const ValueKey('grocery-custom-name'));
      final theme = Theme.of(tester.element(input));
      expect(theme.colorScheme.primary, loginGreen);
      expect(theme.textSelectionTheme.cursorColor, loginGreen);
      expect(
        theme.filledButtonTheme.style!.backgroundColor!.resolve({}),
        loginGreen,
      );
      await tester.enterText(input, 'Cancelled item');
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(screen.controller!.items.length, count);
      expect(find.byType(Dialog), findsNothing);
      expect(
        Theme.of(tester.element(find.byType(GroceryScreen)))
            .colorScheme
            .primary,
        DigiGymDarkColors.electricGreen,
      );
    },
  );

  testWidgets(
    'grocery descriptions are clear and counters and progress retain actual state',
    (tester) async {
      await _home(tester);
      await _tab(tester, 'Groceries');
      const primary = 'Your shopping list is based on your recommended meals.';
      const secondary = 'Changes are saved for this session only.';
      final main = tester.widget<Text>(find.text(primary));
      final note = tester.widget<Text>(find.text(secondary));
      expect(note.style!.fontSize, lessThan(main.style!.fontSize!));
      expect(note.style!.color, DigiGymDarkColors.secondaryText);
      expect(find.textContaining('not synced across devices'), findsNothing);
      final controller = tester
          .widget<GroceryScreen>(find.byType(GroceryScreen))
          .controller!;
      final count = controller.items.length;
      expect(find.text('0 / $count items purchased'), findsOneWidget);
      controller.setPurchased(controller.items.first.id, true);
      await tester.pumpAndSettle();
      expect(find.text('1 / $count items purchased'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        1 / count,
      );
      await _tab(tester, 'Meals');
      await _tab(tester, 'Groceries');
      expect(controller.purchasedCount, 1);
      expect(find.text(secondary), findsOneWidget);
    },
  );

  testWidgets(
    'workout day information and schedule editor share the glass surface without changing persistence',
    (tester) async {
      const accountId = '123e4567-e89b-12d3-a456-426614174000';

      final api = FakeDigiGymApi()
        ..authenticated = true
        ..restoredProfile = UserProfile(
          accountId: accountId,
          name: 'Test User',
          email: 'test@example.com',
        );

      final controller = WorkoutScheduleController(
        accountId: accountId,
        api: api,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      final day = WorkoutScheduling.week(
        user: testUser(),
        workoutDays: null,
        date: DateTime(2026, 10, 27),
      ).first;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  TextButton(
                    onPressed: () => showWorkoutDay(context, day),
                    child: const Text('Day'),
                  ),
                  TextButton(
                    onPressed: () => editWorkoutSchedule(context, controller),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      _expectSharedSurface(tester);
      expect(find.text('Schedule not configured'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      _expectSharedSurface(tester);
      expect(
        find.byKey(const ValueKey('schedule-server-storage-disclosure')),
        findsOneWidget,
      );
      expect(api.workoutSchedules, isEmpty);
      await tester.tap(find.byKey(const ValueKey('schedule-cancel')));
      await tester.pumpAndSettle();
      expect(api.workoutSchedules, isEmpty);
      expect(controller.configured, isFalse);
    },
  );
}
