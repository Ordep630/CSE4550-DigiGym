import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/dashboard_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/daily_streak_indicator.dart';
import 'package:digigym/widgets/dashboard_notification_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Android visual preview and these opt-in tests use:
// --dart-define=DIGIGYM_HEADER_PREVIEW=true
// No sample data is passed through HomeScreen or stored in a user profile.
Widget dashboard({int? streakDays, VoidCallback? onNotifications}) =>
    MaterialApp(
      theme: DigiGymDashboardTheme.dark(ThemeData(useMaterial3: true)),
      home: DashboardPage(
        user: UserProfile(name: 'Isaac', email: 'header-test@example.com'),
        clock: () => DateTime(2026, 10, 20, 9),
        streakDays: streakDays,
        onNotifications: onNotifications,
      ),
    );

void main() {
  testWidgets('missing production data and actions add no header elements', (
    tester,
  ) async {
    await tester.pumpWidget(dashboard());
    await tester.pumpAndSettle();
    expect(find.byType(DailyStreakIndicator), findsNothing);
    expect(find.byType(DashboardNotificationButton), findsNothing);
    expect(find.text('SAMPLE'), findsNothing);
    expect(find.text('Good morning,'), findsOneWidget);
    expect(find.text('Isaac'), findsOneWidget);
  }, skip: DashboardHeaderPreview.enabled);

  testWidgets('supplied streak and notification action are independent', (
    tester,
  ) async {
    await tester.pumpWidget(dashboard(streakDays: 0));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DailyStreakIndicator>(find.byType(DailyStreakIndicator))
          .days,
      0,
    );
    expect(find.byType(DashboardNotificationButton), findsNothing);
    expect(find.text('SAMPLE'), findsNothing);

    var calls = 0;
    await tester.pumpWidget(dashboard(onNotifications: () => calls++));
    await tester.pumpAndSettle();
    expect(find.byType(DailyStreakIndicator), findsNothing);
    await tester.tap(find.byType(DashboardNotificationButton));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.byType(AlertDialog), findsNothing);
  }, skip: DashboardHeaderPreview.enabled);

  testWidgets(
    'caller-supplied values and actions are never replaced by samples',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        dashboard(streakDays: 12, onNotifications: () => calls++),
      );
      await tester.pumpAndSettle();
      final streak = tester.widget<DailyStreakIndicator>(
        find.byType(DailyStreakIndicator),
      );
      expect(streak.days, 12);
      expect(streak.isPreview, isFalse);
      expect(find.text('SAMPLE'), findsNothing);
      expect(
        tester
            .widget<DashboardNotificationButton>(
              find.byType(DashboardNotificationButton),
            )
            .isPreview,
        isFalse,
      );
      await tester.tap(find.byType(DashboardNotificationButton));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'compact streak shows only flame and Inter count with accessible meaning',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: DigiGymDashboardTheme.dark(ThemeData()),
            home: const Scaffold(
              body: Center(
                child: DailyStreakIndicator(days: 7, isPreview: true),
              ),
            ),
          ),
        );
        expect(
          find.bySemanticsLabel(
            'Development preview: sample 7-day workout streak',
          ),
          findsOneWidget,
        );
        expect(find.byType(Text), findsOneWidget);
        expect(find.text('DAYS'), findsNothing);
        expect(find.text('SAMPLE'), findsNothing);
        expect(find.text('7-day workout streak'), findsNothing);
        final number = tester.widget<Text>(find.text('7'));
        expect(number.style!.fontFamily, DigiGymDashboardTheme.textFont);
        expect(number.style!.fontWeight, FontWeight.w600);
        expect(number.style!.fontSize, 17);
        expect(number.style!.color, DigiGymDarkColors.primaryText);
        final flame = find.byIcon(Icons.local_fire_department_rounded);
        expect(tester.widget<Icon>(flame).size, 17);
        expect(tester.widget<Icon>(flame).color, const Color(0xFFFFAA58));
        expect(
          tester.getSize(find.byType(DailyStreakIndicator)).width,
          lessThan(64),
        );
        expect(tester.getSize(find.byType(DailyStreakIndicator)).height, 35);
        expect(
          tester.getRect(flame).center.dy,
          tester.getRect(find.text('7')).center.dy,
        );
        expect(find.byType(BackdropFilter), findsNothing);

        await tester.pumpWidget(
          MaterialApp(
            home: const Scaffold(
              body: Center(child: DailyStreakIndicator(days: 1)),
            ),
          ),
        );
        expect(find.bySemanticsLabel('1-day workout streak'), findsOneWidget);
        expect(find.text('SAMPLE'), findsNothing);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'notification has a 48px accessible target and outlined 24px bell',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        var calls = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: DigiGymDashboardTheme.dark(ThemeData()),
            home: Scaffold(
              body: Center(
                child: DashboardNotificationButton(onPressed: () => calls++),
              ),
            ),
          ),
        );
        expect(tester.getSize(find.byType(IconButton)), const Size(48, 48));
        expect(
          tester
              .widget<Icon>(find.byIcon(Icons.notifications_none_rounded))
              .size,
          24,
        );
        expect(find.byTooltip('Notifications'), findsOneWidget);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        final bounds = tester.getRect(find.byType(IconButton));
        await tester.tapAt(Offset(bounds.left + 1, bounds.center.dy));
        expect(calls, 1);
        expect(find.byType(BackdropFilter), findsNothing);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('streak accommodates large counts and 3x text without clipping', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final days in [0, 1, 7, 365, 10000]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(3)),
            child: child!,
          ),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: DailyStreakIndicator(days: days),
            ),
          ),
        ),
      );
      final pill = tester.getRect(find.byType(DailyStreakIndicator));
      final bounds = tester.getRect(find.text('$days'));
      expect(bounds.left, greaterThanOrEqualTo(pill.left));
      expect(bounds.right, lessThanOrEqualTo(pill.right));
      expect(bounds.bottom, lessThanOrEqualTo(pill.bottom));
      expect(tester.takeException(), isNull, reason: '$days days');
    }
  });

  testWidgets(
    'opt-in debug dashboard retains sample semantics and explanatory bell action',
    (tester) async {
      await tester.pumpWidget(dashboard());
      await tester.pumpAndSettle();
      final streak = tester.widget<DailyStreakIndicator>(
        find.byType(DailyStreakIndicator),
      );
      expect(streak.days, 7);
      expect(streak.isPreview, isTrue);
      expect(find.text('SAMPLE'), findsNothing);
      expect(find.text('DAYS'), findsNothing);
      expect(
        find.byTooltip('Notifications — development preview'),
        findsOneWidget,
      );
      await tester.tap(find.byType(DashboardNotificationButton));
      await tester.pumpAndSettle();
      expect(find.text('Development preview'), findsOneWidget);
      expect(
        find.textContaining('Notifications are not connected.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester
            .widget<DailyStreakIndicator>(find.byType(DailyStreakIndicator))
            .days,
        7,
      );
    },
    skip: !DashboardHeaderPreview.enabled,
  );
}
