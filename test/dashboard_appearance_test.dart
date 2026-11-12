import 'dart:io';
import 'dart:convert';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/services/dashboard_personalization.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/monthly_activity_calendar.dart';
import 'package:digigym/widgets/dashboard_progress_card.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:digigym/widgets/segmented_progress_ring.dart';
import 'package:digigym/widgets/stat_card.dart';
import 'package:digigym/widgets/weekly_workout_schedule.dart';
import 'package:digigym/widgets/daily_streak_indicator.dart';
import 'package:digigym/widgets/dashboard_notification_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget dashboard({
  double textScale = 1,
  String name = 'Alex Morgan',
  EdgeInsets safeArea = const EdgeInsets.only(top: 24, bottom: 24),
  UserProfile? user,
  String motivationalMessage = DashboardPersonalization.defaultMessage,
  DateTime? localTime,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    scaffoldBackgroundColor: const Color(0xFFF5F7F5),
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(padding: safeArea, textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: HomeScreen(
    motivationalMessage: motivationalMessage,
    clock: () => localTime ?? DateTime(2026, 10, 20, 9),
    user:
        user ??
        UserProfile(
          name: name,
          email: 'alex@example.com',
          age: 31,
          height: 180,
          weight: 80,
          fitnessLevel: 'Intermediate',
          fitnessGoal: 'Build Muscle',
          workoutTime: 45,
        ),
    onLogout: () async {},
    onUpdateProfile: (_) {},
  ),
);

void testAndroidDashboard(
  String description,
  Future<void> Function(WidgetTester) body,
) {
  testWidgets(description, (tester) async {
    final originalShadows = debugDisableShadows;
    final originalPlatform = debugDefaultTargetPlatformOverride;
    debugDisableShadows = false;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await body(tester);
    } finally {
      debugDisableShadows = originalShadows;
      debugDefaultTargetPlatformOverride = originalPlatform;
    }
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final font in {
      DigiGymDashboardTheme.textFont: 'assets/fonts/Inter-Variable.ttf',
      DigiGymDashboardTheme.numberFont: 'assets/fonts/Doto-Variable.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
    // Android supplies Roboto at runtime. Load the same Flutter SDK font in
    // tests so the unchanged navbar does not render with placeholder glyphs.
    final configuration = File('.dart_tool/package_config.json');
    final packages =
        jsonDecode(await configuration.readAsString())['packages'] as List;
    final flutterPackage = packages.firstWhere(
      (entry) => entry['name'] == 'flutter',
    );
    final sdk = Directory.fromUri(
      configuration.uri.resolve(flutterPackage['rootUri'] as String),
    ).parent.parent;
    final roboto = FontLoader('Roboto');
    for (final face in ['Regular', 'Medium', 'Bold']) {
      final bytes = await File(
        '${sdk.path}/bin/cache/artifacts/material_fonts/Roboto-$face.ttf',
      ).readAsBytes();
      roboto.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await roboto.load();
  });

  testAndroidDashboard(
    'compact Android dashboard appearance with local fonts',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      await tester.pumpWidget(dashboard());
      await tester.runAsync(() async {
        for (final asset in [
          'assets/images/digigym_workout_icon.png',
          'assets/images/digigym_wordmark.png',
          'assets/icons/biceps_flexed.png',
        ]) {
          await precacheImage(
            AssetImage(asset),
            tester.element(find.byType(HomeScreen)),
          );
        }
      });
      await tester.pumpAndSettle();
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(MonthlyActivityCalendar)))
            .textTheme
            .bodyMedium
            ?.fontFamily,
        DigiGymDashboardTheme.textFont,
      );
      expect(
        Theme.of(tester.element(find.byType(FloatingBottomNavigationBar)))
            .textTheme
            .bodyMedium
            ?.fontFamily,
        isNot(DigiGymDashboardTheme.textFont),
      );
      expect(
        tester.getSize(find.byType(DashboardProgressCard)).height,
        inInclusiveRange(190, 210),
      );
      expect(find.text('Your Plan'), findsNothing);
      expect(find.byType(MonthlyActivityCalendar), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testAndroidDashboard(
    'current Pixel Home fits without scrolling and calendar clears navigation',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1280, 2856);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        dashboard(
          safeArea: const EdgeInsets.only(top: 52, bottom: 24),
          localTime: DateTime(2026, 10, 25, 9),
          user: UserProfile(
            name: 'Isaac',
            email: 'pixel@example.com',
            age: 31,
            height: 174,
            weight: 58,
            fitnessLevel: 'Intermediate',
            fitnessGoal: 'Build Muscle',
            workoutTime: 30,
          ),
        ),
      );
      await tester.runAsync(() async {
        for (final asset in [
          'assets/images/digigym_workout_icon.png',
          'assets/images/digigym_wordmark.png',
        ]) {
          await precacheImage(
            AssetImage(asset),
            tester.element(find.byType(HomeScreen)),
          );
        }
      });
      await tester.pumpAndSettle();
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scroll.position.maxScrollExtent, 0);
      final calendar = tester.getRect(find.byType(MonthlyActivityCalendar));
      final navigation = tester.getRect(
        find.byType(FloatingBottomNavigationBar),
      );
      expect(calendar.bottom, lessThan(navigation.top));
      expect(find.text('Your Plan'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testAndroidDashboard(
    'official wordmark preserves header geometry and sharp untinted artwork',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1280, 2856);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        dashboard(safeArea: const EdgeInsets.only(top: 52, bottom: 24)),
      );
      await tester.runAsync(() async {
        for (final asset in [
          'assets/images/digigym_workout_icon.png',
          'assets/images/digigym_wordmark.png',
          'assets/icons/biceps_flexed.png',
        ]) {
          await precacheImage(
            AssetImage(asset),
            tester.element(find.byType(HomeScreen)),
          );
        }
      });
      await tester.pumpAndSettle();
      final wordmark = find.byKey(const ValueKey('dashboard-wordmark'));
      final row = find.ancestor(of: wordmark, matching: find.byType(Row)).first;
      expect(tester.getRect(row), Rect.fromLTRB(20, 70, 1280 / 3 - 20, 101));
      expect(tester.getRect(find.text('Good Morning,')).top, 119);
      expect(find.text('DigiGym'), findsNothing);
      final image = tester.widget<Image>(wordmark);
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/digigym_wordmark.png',
      );
      expect(image.semanticLabel, 'DigiGym');
      expect(image.filterQuality, FilterQuality.none);
      expect(image.fit, BoxFit.contain);
      expect(image.color, isNull);
      final dumbbell = find.descendant(
        of: row,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/images/digigym_workout_icon.png',
        ),
      );
      expect(tester.getRect(dumbbell).left, 20);
      expect(tester.getRect(dumbbell).width, 48);
      expect(tester.getRect(dumbbell).height, closeTo(48 * 331 / 796, 0.001));
      expect(tester.getRect(wordmark).left, 78);
      expect(
        tester.getRect(wordmark).height / tester.getRect(dumbbell).height,
        closeTo(1.05, 0.001),
      );
      expect(
        tester.getRect(wordmark).center.dy,
        closeTo(tester.getRect(dumbbell).center.dy, 0.001),
      );
      expect(
        tester.getRect(wordmark).width / tester.getRect(wordmark).height,
        closeTo(862 / 189, 0.001),
      );
      expect(find.byType(DailyStreakIndicator), findsOneWidget);
      expect(
        find.byType(DashboardNotificationButton),
        DashboardHeaderPreview.enabled ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  // Run this fixture with --dart-define=DIGIGYM_HEADER_PREVIEW=true to review
  // the same explicitly marked samples rendered on the Android dashboard.
  testWidgets(
    'header actions stay together above standalone names at all text scales',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final size in [
        const Size(320, 640),
        const Size(390, 844),
        const Size(1280 / 3, 952),
      ]) {
        tester.view.physicalSize = size;
        for (final scale in [1.0, 2.0, 3.0]) {
          for (final name in ['Isaac', 'Alexandria Morgan Hernandez']) {
            await tester.pumpWidget(
              dashboard(
                textScale: scale,
                name: name,
                safeArea: const EdgeInsets.only(top: 52, bottom: 24),
              ),
            );
            await tester.pumpAndSettle();
            tester
                .state<ScrollableState>(find.byType(Scrollable))
                .position
                .jumpTo(0);
            final pill = tester.getRect(find.byType(DailyStreakIndicator));
            final nameBounds = tester.getRect(find.text(name));
            final nameStyle = tester.widget<Text>(find.text(name)).style!;
            expect(nameStyle.fontSize, 32);
            expect(nameStyle.fontWeight, FontWeight.w700);
            expect(nameStyle.letterSpacing, -0.9);
            expect(pill.height, closeTo(17 * scale + 18, .001));
            expect(pill.left, greaterThanOrEqualTo(20));
            expect(pill.bottom, lessThan(nameBounds.top));
            final greeting = tester.getRect(find.text('Good Morning,'));
            expect(pill.bottom, lessThanOrEqualTo(greeting.top));
            expect(nameBounds.left, 20);
            expect(nameBounds.top - greeting.bottom, 4);
            final message = tester.getRect(
              find.text(DashboardPersonalization.defaultMessage),
            );
            expect(message.top - nameBounds.bottom, 5);
            final bell = tester.getRect(
              find.byType(DashboardNotificationButton),
            );
            final artwork = tester.getRect(
              find.byKey(const ValueKey('dashboard-wordmark')),
            );
            expect(bell.size, const Size(48, 48));
            expect(bell.right, size.width - 20);
            expect(bell.left - pill.right, closeTo(6, .001));
            expect(bell.center.dy, closeTo(pill.center.dy, .001));
            expect(
              artwork.width,
              closeTo((48 * 331 / 796 * 1.05) * 862 / 189, .001),
            );
            if (pill.left >= artwork.right + 12) {
              expect(bell.center.dy, closeTo(artwork.center.dy, .001));
            } else {
              expect(pill.top, greaterThan(artwork.bottom));
            }
            if (size.height == 952 && scale == 1) {
              expect(bell, Rect.fromLTWH(size.width - 68, 61.5, 48, 48));
              expect(greeting.top, 119);
            }
            final scroll = tester.state<ScrollableState>(
              find.byType(Scrollable),
            );
            if (size.height == 952 && scale == 1 && name == 'Isaac') {
              expect(scroll.position.maxScrollExtent, lessThanOrEqualTo(20));
            } else {
              expect(scroll.position.maxScrollExtent, greaterThan(0));
            }
            await tester.ensureVisible(
              find.byKey(const ValueKey('month-day-2026-10-31')),
            );
            await tester.pumpAndSettle();
            expect(
              tester
                  .getRect(find.byKey(const ValueKey('month-day-2026-10-31')))
                  .bottom,
              lessThanOrEqualTo(
                tester.getRect(find.byType(FloatingBottomNavigationBar)).top,
              ),
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$size / $scale / $name',
            );
          }
        }
      }
    },
    skip: !DashboardHeaderPreview.enabled,
  );

  testAndroidDashboard(
    'larger Doto values retain card heights, units and label alignment',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [390.0, 1280 / 3]) {
        tester.view.physicalSize = Size(width * 3, 2856);
        await tester.pumpWidget(dashboard());
        await tester.pumpAndSettle();
        for (final entry in {
          'Daily calorie target': (29 * 1.15, 35.0, true),
          'BMI': (27 * 1.17, 32.0, true),
          'Weight': (27 * 1.17, 32.0, true),
          'Workout': (27.0, 32.0, false),
        }.entries) {
          final card = find.widgetWithText(StatCard, entry.key);
          final number = find.descendant(
            of: card,
            matching: find.byType(DashboardNumber),
          );
          final widget = tester.widget<DashboardNumber>(number);
          expect(widget.fontSize, closeTo(entry.value.$1, .001));
          expect(widget.dotted, entry.value.$3);
          if (entry.key == 'Daily calorie target') {
            // The shared Cal unit participates in the existing width fitting;
            // keep its original line slot without requiring an empty unit span.
            expect(tester.getSize(number).height, inInclusiveRange(34, 35));
          } else {
            expect(tester.getSize(number).height, entry.value.$2);
          }
          expect(
            tester
                    .getRect(
                      find.descendant(of: card, matching: find.text(entry.key)),
                    )
                    .top -
                tester.getRect(number).bottom,
            3,
          );
          expect(
            tester.getRect(number).right,
            lessThanOrEqualTo(tester.getRect(card).right),
          );
          final text = tester.widget<Text>(
            find.descendant(of: number, matching: find.byType(Text)),
          );
          final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
          expect(
            spans.first.style!.fontFamily,
            entry.value.$3
                ? DigiGymDashboardTheme.numberFont
                : DigiGymDashboardTheme.textFont,
          );
          expect(spans.first.style!.color, DigiGymDarkColors.primaryText);
          expect(
            spans.last.style!.fontSize,
            (entry.key == 'Daily calorie target' ? 29 : 27) * .53,
          );
          if (entry.key == 'BMI' || entry.key == 'Weight') {
            expect(tester.getSize(card).height, 63);
          }
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testAndroidDashboard(
    'approved Phase 3H dashboard fits the measured Pixel 10 Pro viewport',
    (tester) async {
      // Measured from the Android render tree: 1280x2856 at DPR 3, with
      // a 52px status area and 104px navigation region (including bottom inset).
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1280, 2856);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        dashboard(
          safeArea: const EdgeInsets.only(top: 52, bottom: 24),
          localTime: DateTime(2026, 10, 25, 9),
          user: UserProfile(
            name: 'Isaac',
            email: 'pixel-test@example.com',
            age: 31,
            height: 174,
            weight: 58,
            fitnessLevel: 'Intermediate',
            fitnessGoal: 'Build Muscle',
            workoutTime: 30,
          ),
        ),
      );
      await tester.runAsync(() async {
        for (final asset in [
          'assets/images/digigym_workout_icon.png',
          'assets/images/digigym_wordmark.png',
        ]) {
          await precacheImage(
            AssetImage(asset),
            tester.element(find.byType(HomeScreen)),
          );
        }
      });
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.maxScrollExtent, 0);
      expect(scrollable.position.pixels, 0);
      final navigation = tester.getRect(
        find.byType(FloatingBottomNavigationBar),
      );
      expect(navigation.top, 848);
      expect(navigation.height, 104);
      final background = find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                DigiGymDarkColors.graphite &&
            (widget.decoration as BoxDecoration).gradient is RadialGradient,
      );
      expect(background, findsOneWidget);
      expect(tester.getRect(background), Rect.fromLTWH(0, 0, 1280 / 3, 952));
      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      expect(viewport.top, 52);
      expect(viewport.bottom, 952);
      expect(viewport.height, 900);

      final progressCard = find.byType(DashboardProgressCard);
      expect(progressCard, findsOneWidget);
      final ring = find.descendant(
        of: progressCard,
        matching: find.byType(SegmentedProgressRing),
      );
      expect(ring, findsOneWidget);
      expect(tester.widget<SegmentedProgressRing>(ring).progress, 0);
      expect(SegmentedProgressPainter.segmentCount, 40);
      expect(
        tester
            .widget<DotMatrixText>(
              find.descendant(of: ring, matching: find.byType(DotMatrixText)),
            )
            .text,
        '0%',
      );

      final statistics = find.byKey(
        const ValueKey('dashboard-statistics-panel'),
      );
      expect(tester.widget(statistics), isA<DashboardGlassCard>());
      final rows = find.descendant(
        of: statistics,
        matching: find.byType(StatCard),
      );
      expect(tester.widgetList<StatCard>(rows).map((row) => row.title), [
        'Daily calorie target',
        'Weight',
        'BMI',
      ]);
      expect(tester.widgetList<StatCard>(rows).map((row) => row.value), [
        '1818 Cal',
        '127.9 lb',
        '19.2',
      ]);
      expect(
        tester.widgetList<StatCard>(rows).every((row) => row.embedded),
        isTrue,
      );
      final progressBounds = tester.getRect(progressCard);
      final panelBounds = tester.getRect(statistics);
      final workout = find.widgetWithText(StatCard, 'Workout');
      final workoutBounds = tester.getRect(workout);
      expect(tester.widget<StatCard>(workout).value, '30 min');
      expect(tester.widget<StatCard>(workout).embedded, isFalse);
      expect(find.byType(StatCard), findsNWidgets(4));
      expect(workoutBounds.left, progressBounds.left);
      expect(workoutBounds.width, progressBounds.width);
      expect(
        workoutBounds.top,
        greaterThanOrEqualTo(progressBounds.bottom + 10),
      );
      expect(panelBounds.top, progressBounds.top);
      expect(panelBounds.bottom, closeTo(workoutBounds.bottom, .01));
      expect(panelBounds.width, progressBounds.width);
      expect(panelBounds.left - progressBounds.right, 12);
      double? previousBottom;
      for (final row in rows.evaluate()) {
        final bounds = tester.getRect(find.byWidget(row.widget));
        expect(panelBounds.contains(bounds.topLeft), isTrue);
        expect(panelBounds.contains(bounds.bottomRight), isTrue);
        if (previousBottom != null) {
          expect(bounds.top, greaterThan(previousBottom));
        }
        previousBottom = bounds.bottom;
      }

      final week = find.byType(WeeklyWorkoutSchedule);
      final calendar = find.byType(MonthlyActivityCalendar);
      expect(week, findsOneWidget);
      expect(calendar, findsOneWidget);
      expect(tester.getRect(week).top, greaterThan(panelBounds.bottom));
      expect(
        tester.getRect(calendar).top,
        greaterThan(tester.getRect(week).bottom),
      );
      expect(tester.getRect(calendar).bottom, lessThan(navigation.top));
      expect(
        find.byKey(const ValueKey('month-day-2026-10-31')),
        findsOneWidget,
      );
      for (final removed in [
        'Build Muscle',
        'Your Plan',
        "Today's Workout",
        "Today's Nutrition",
        'Grocery List',
      ]) {
        expect(find.text(removed), findsNothing);
      }

      // The Phase 2D golden documents the retired layout and remains unchanged.
      // Check the approved Phase 3H content and geometry without rebasing it.
      for (final label in [
        'Good Morning,',
        DashboardPersonalization.defaultMessage,
        'Isaac',
        "Today's Progress",
        'Complete',
        '1818 Cal',
        '30 min',
        '19.2',
        '127.9 lb',
        'Daily calorie target',
        'Workout',
        'Weight',
        'BMI',
        'Your Week',
        'See All',
        'Monthly Activity',
      ]) {
        final bounds = tester.getRect(
          find.descendant(
            of: find.byType(DashboardPage),
            matching: find.text(label),
          ),
        );
        expect(bounds.top, greaterThanOrEqualTo(52), reason: label);
        expect(bounds.bottom, lessThanOrEqualTo(navigation.top), reason: label);
        expect(bounds.left, greaterThanOrEqualTo(20), reason: label);
        expect(bounds.right, lessThanOrEqualTo(1280 / 3 - 20), reason: label);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testAndroidDashboard(
    'all messages fit responsively through 3x text scaling',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final size in [
        const Size(320, 640),
        const Size(390, 844),
        const Size(1280 / 3, 952),
      ]) {
        tester.view.physicalSize = Size(size.width * 3, size.height * 3);
        for (final scale in [1.0, 2.0, 3.0]) {
          for (final message in DashboardPersonalization.messages) {
            final localTime = DateTime(
              2026,
              10,
              20,
              [5, 12, 17][DashboardPersonalization.messages.indexOf(message) %
                  3],
            );
            await tester.pumpWidget(
              dashboard(
                textScale: scale,
                motivationalMessage: message,
                localTime: localTime,
                safeArea: const EdgeInsets.only(top: 52, bottom: 24),
                user: UserProfile(
                  name: scale == 1 && size.height == 952
                      ? 'Isaac'
                      : 'Alexandria Morgan Hernandez',
                  email: 'layout@example.com',
                  age: 31,
                  height: 174,
                  weight: 58,
                  fitnessLevel: 'Intermediate',
                  fitnessGoal: 'Build Muscle',
                  workoutTime: 30,
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.text(message), findsOneWidget);
            expect(
              find.text(DashboardPersonalization.greetingFor(localTime)),
              findsOneWidget,
            );
            expect(
              tester.getRect(find.text(message)).right,
              lessThanOrEqualTo(size.width - 20),
            );
            final scroll = tester.state<ScrollableState>(
              find.byType(Scrollable),
            );
            if (size.height == 952 && scale == 1) {
              expect(
                scroll.position.maxScrollExtent,
                lessThanOrEqualTo(20),
                reason: message,
              );
            }
            await tester.ensureVisible(
              find.byKey(const ValueKey('month-day-2026-10-31')),
            );
            await tester.pumpAndSettle();
            final navigation = tester.getRect(
              find.byType(FloatingBottomNavigationBar),
            );
            expect(
              tester
                  .getRect(find.byKey(const ValueKey('month-day-2026-10-31')))
                  .bottom,
              lessThanOrEqualTo(navigation.top),
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$size / $scale / $message',
            );
          }
        }
      }
    },
  );

  testAndroidDashboard(
    'bundled fonts stay readable on narrow phones and enlarged text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final size in [const Size(320, 640), const Size(390, 844)]) {
        tester.view.physicalSize = size;
        for (final scale in [1.0, 2.0, 3.0]) {
          await tester.pumpWidget(
            dashboard(textScale: scale, name: 'Alexandria Morgan Hernandez'),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$size at $scale');
          final wordmark = find.byKey(const ValueKey('dashboard-wordmark'));
          final header = find
              .ancestor(of: wordmark, matching: find.byType(Row))
              .first;
          final dumbbell = find
              .descendant(of: header, matching: find.byType(Image))
              .first;
          expect(
            tester.getRect(wordmark).height / tester.getRect(dumbbell).height,
            closeTo(1.05, 0.001),
          );
          expect(
            tester.getRect(wordmark).center.dy,
            closeTo(tester.getRect(dumbbell).center.dy, 0.001),
          );
          final scrollable = tester.state<ScrollableState>(
            find.byType(Scrollable),
          );
          expect(scrollable.position.maxScrollExtent, greaterThan(0));
          await tester.ensureVisible(
            find.byKey(const ValueKey('month-day-2026-10-31')),
          );
          await tester.pumpAndSettle();
          expect(find.text('24.7'), findsOneWidget);
          expect(find.text('176.4 lb'), findsOneWidget);
          expect(find.text('2075 Cal'), findsOneWidget);
          expect(find.text('45 min'), findsOneWidget);
          final description = tester.getRect(
            find.byKey(const ValueKey('month-day-2026-10-31')),
          );
          final viewport = tester.getRect(find.byType(SingleChildScrollView));
          expect(description.bottom, lessThanOrEqualTo(viewport.bottom));
          expect(tester.takeException(), isNull, reason: '$size at $scale');
        }
      }
    },
  );
}
