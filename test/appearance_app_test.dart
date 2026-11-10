import 'package:digigym/main.dart';
import 'package:digigym/models/session.dart';
import 'package:digigym/screens/app_appearance_screen.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/screens/profile_screen.dart';
import 'package:digigym/services/dashboard_personalization.dart';
import 'package:digigym/theme/appearance_controller.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/utils/measurement_units.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/segmented_progress_ring.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';
import 'support/memory_schedule_storage.dart';

Future<void> start(WidgetTester tester, AppearanceController appearance) async {
  final api = FakeDigiGymApi()..restoredProfile = testUser();
  await tester.pumpWidget(
    DigiGymApp(
      api: api,
      appearance: appearance,
      personalization: DashboardPersonalization(
        storage: MemoryScheduleStorage(),
      ),
      clock: () => DateTime(2026, 10, 20, 9),
    ),
  );
  await tester.pumpAndSettle();
}

Brightness dashboardBrightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(DashboardPage))).brightness;

Future<void> tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FloatingBottomNavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

// Numeric glyphs are painted; verify the original accessible data value.
Finder numberValue(String value) => find.byWidgetPredicate(
  (widget) => widget is DashboardNumber && widget.value == value,
);

void main() {
  tearDown(() {
    DigiGymSession.currentUser = null;
    DigiGymSession.clearPendingRegistration();
  });

  testWidgets('Dark is the app default even on a light device', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final appearance = AppearanceController(storage: MemoryScheduleStorage());
    addTearDown(appearance.dispose);
    await start(tester, appearance);
    expect(dashboardBrightness(tester), Brightness.dark);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets(
    'settings switch, persist, and restore the light dashboard on app restart',
    (tester) async {
      final storage = MemoryScheduleStorage();
      final appearance = AppearanceController(storage: storage);
      addTearDown(appearance.dispose);
      await start(tester, appearance);
      await tapTab(tester, 'Profile');
      await tester.ensureVisible(find.text('App Appearance'));
      await tester.tap(find.text('App Appearance'));
      await tester.pumpAndSettle();
      expect(find.byType(AppAppearanceScreen), findsOneWidget);
      final semantics = tester.ensureSemantics();
      for (final label in [
        'Light Mode',
        'Follow System',
        'Dark Mode',
        'Light Mode',
      ]) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(find.bySemanticsLabel(label)),
          matchesSemantics(
            label: label,
            isButton: true,
            isInMutuallyExclusiveGroup: true,
            hasSelectedState: true,
            isSelected: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
          ),
        );
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      }
      semantics.dispose();
      await appearance.flush();
      expect(storage.values[AppearanceController.storageKey], 'light');
      expect(
        Theme.of(tester.element(find.text('Light Mode'))).brightness,
        Brightness.light,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      // Remaining tabs stay on their approved Sprint 2 styling during Stage 1.
      expect(
        Theme.of(tester.element(find.byType(ProfilePage))).brightness,
        Brightness.dark,
      );
      await tapTab(tester, 'Home');
      expect(dashboardBrightness(tester), Brightness.light);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      final restarted = AppearanceController(storage: storage);
      addTearDown(restarted.dispose);
      await start(tester, restarted);
      expect(restarted.mode, ThemeMode.light);
      expect(dashboardBrightness(tester), Brightness.light);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Follow System responds live and survives restart; explicit modes ignore changes',
    (tester) async {
      final storage = MemoryScheduleStorage();
      final appearance = AppearanceController(storage: storage);
      addTearDown(appearance.dispose);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await start(tester, appearance);
      appearance.select(ThemeMode.system);
      await tester.pumpAndSettle();
      expect(dashboardBrightness(tester), Brightness.light);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(dashboardBrightness(tester), Brightness.dark);
      await appearance.flush();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      final restarted = AppearanceController(storage: storage);
      addTearDown(restarted.dispose);
      await start(tester, restarted);
      expect(restarted.mode, ThemeMode.system);
      expect(dashboardBrightness(tester), Brightness.dark);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(dashboardBrightness(tester), Brightness.light);
      restarted.select(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(dashboardBrightness(tester), Brightness.dark);
      restarted.select(ThemeMode.light);
      await tester.pumpAndSettle();
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(dashboardBrightness(tester), Brightness.light);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'light dashboard uses semantic surfaces, numbers, navigation and readable dialogs',
    (tester) async {
      final storage = MemoryScheduleStorage()
        ..values[AppearanceController.storageKey] = 'light';
      final appearance = AppearanceController(storage: storage);
      addTearDown(appearance.dispose);
      await start(tester, appearance);
      final context = tester.element(find.byType(DashboardPage));
      final theme = Theme.of(context);
      expect(theme.colorScheme.onSurface, const Color(0xFF121418));
      expect(DigiGymSurfaces.of(context).glass, DigiGymSurfaces.light.glass);
      expect(find.byType(DashboardGlassCard), findsNWidgets(5));
      expect(
        numberValue(MeasurementUnits.formatWeight(testUser().weight)),
        findsOneWidget,
      );
      expect(numberValue(testUser().bmi.toStringAsFixed(1)), findsOneWidget);
      final painter =
          tester
                  .widget<CustomPaint>(
                    find
                        .descendant(
                          of: find.byType(SegmentedProgressRing),
                          matching: find.byType(CustomPaint),
                        )
                        .first,
                  )
                  .painter
              as SegmentedProgressPainter;
      expect(painter.inactiveColor, DigiGymSurfaces.light.progressTrack);
      await tester.tap(find.byKey(const ValueKey('dashboard-bmi-action')));
      await tester.pumpAndSettle();
      final dialogTheme = Theme.of(tester.element(find.text('What is BMI?')));
      expect(dialogTheme.brightness, Brightness.light);
      expect(dialogTheme.colorScheme.primary, DigiGymSurfaces.light.accent);
      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('dashboard-weight-action')));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Your Weight'))).brightness,
        Brightness.light,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'storage errors keep selection usable and resume retries saving',
    (tester) async {
      final storage = MemoryScheduleStorage()
        ..writeError = StateError('unavailable');
      final appearance = AppearanceController(storage: storage);
      addTearDown(appearance.dispose);
      await start(tester, appearance);
      await tapTab(tester, 'Profile');
      await tester.ensureVisible(find.text('App Appearance'));
      await tester.tap(find.text('App Appearance'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light Mode'));
      await tester.pumpAndSettle();
      expect(appearance.mode, ThemeMode.light);
      expect(find.textContaining('Could not save'), findsOneWidget);
      storage.writeError = null;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(storage.values[AppearanceController.storageKey], 'light');
      expect(find.textContaining('Could not save'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
