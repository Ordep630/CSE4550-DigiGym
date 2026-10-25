import 'dart:ui' show SemanticsAction;

import 'package:digigym/models/workout_schedule_day.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:digigym/widgets/monthly_activity_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget calendar({
  required DateTime Function() clock,
  List<WorkoutScheduleDay> days = const [],
  double scale = 1,
}) => MaterialApp(
  theme: DigiGymDashboardTheme.content(DigiGymDashboardTheme.dark(ThemeData())),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: MonthlyActivityCalendar(clock: clock, days: days),
      ),
    ),
  ),
);
Finder day(DateTime date) => find.byKey(
  ValueKey('month-day-${date.toIso8601String().split('T').first}'),
);

void main() {
  setUpAll(() async {
    await (FontLoader(
      DigiGymDashboardTheme.textFont,
    )..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'))).load();
  });
  test('actual month dates align Sunday first across all month lengths and leap rules', () {
    for (final input in [
      (2026, 2, 28),
      (2028, 2, 29),
      (2026, 4, 30),
      (2026, 10, 31),
      (1900, 2, 28),
      (2000, 2, 29),
      (2100, 2, 28),
      (2026, 8, 31),
    ]) {
      final slots = MonthlyActivityCalendar.monthDates(
        DateTime(input.$1, input.$2, 15, 12),
      );
      final dates = slots.whereType<DateTime>().toList();
      expect(dates, hasLength(input.$3));
      expect(slots.length % 7, 0);
      expect(slots.length, inInclusiveRange(28, 42));
      expect(slots.indexOf(dates.first), dates.first.weekday % 7);
      expect(dates.first, DateTime(input.$1, input.$2));
      expect(dates.last, DateTime(input.$1, input.$2, input.$3));
      for (var i = 0; i < slots.length; i++) {
        if (slots[i] != null) expect(slots[i]!.weekday % 7, i % 7);
      }
      expect(dates.toSet(), hasLength(input.$3));
    }
    expect(MonthlyActivityCalendar.monthDates(DateTime(2026, 8)).length, 42);
    expect(MonthlyActivityCalendar.monthDates(DateTime(2026, 2)).length, 28);
  });

  testWidgets(
    'current local date is green beside a neutral Sunday-first month',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        calendar(clock: () => DateTime(2026, 10, 25, 14)),
      );
      expect(find.text('Monthly Activity'), findsOneWidget);
      final month = tester.widget<Text>(
        find.byKey(const ValueKey('activity-month')),
      );
      expect(month.data, 'OCT');
      expect(month.style!.color, DigiGymDarkColors.secondaryText);
      final largeDate = tester.widget<DotMatrixText>(
        find.byKey(const ValueKey('activity-date')),
      );
      expect(largeDate.text, '25');
      expect(largeDate.color, DigiGymDarkColors.electricGreen);
      expect(
        [
          for (var i = 0; i < 7; i++)
            tester.widget<Text>(find.byKey(ValueKey('month-weekday-$i'))).data,
        ],
        ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
      );
      expect(
        find.bySemanticsLabel('October 25, 2026, Today, No activity data'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('No activity data')),
        findsNWidgets(31),
      );
      expect(find.byType(Icon), findsNothing);
      expect(
        find.bySemanticsLabel(
          RegExp(
            'Completed workout|Scheduled rest day|Missed scheduled workout',
          ),
        ),
        findsNothing,
      );
      expect(
        tester.getRect(day(DateTime(2026, 10, 25))).left,
        tester
                .getRect(find.byKey(const ValueKey('month-weekday-0')))
                .center
                .dx -
            tester.getSize(day(DateTime(2026, 10, 25))).width / 2,
      );
      for (var i = 1; i <= 31; i++) {
        final data = tester
            .getSemantics(day(DateTime(2026, 10, i)))
            .getSemanticsData();
        expect(data.hasAction(SemanticsAction.tap), isFalse);
      }
      semantics.dispose();
    },
  );

  testWidgets('only explicit shared schedule inputs produce activity states', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      calendar(
        clock: () => DateTime(2026, 10, 25),
        days: [
          WorkoutScheduleDay(date: DateTime(2026, 10, 10), isCompleted: true),
          WorkoutScheduleDay(date: DateTime(2026, 10, 11), isRestDay: true),
          WorkoutScheduleDay(
            date: DateTime(2026, 10, 12),
            workoutType: ScheduledWorkoutType.cardio,
            isMissed: true,
          ),
          WorkoutScheduleDay(
            date: DateTime(2026, 10, 24),
            workoutType: ScheduledWorkoutType.upperBody,
          ),
          WorkoutScheduleDay(
            date: DateTime(2026, 10, 27),
            workoutType: ScheduledWorkoutType.lowerBody,
          ),
          WorkoutScheduleDay(date: DateTime(2026, 11, 1), isCompleted: true),
        ],
      ),
    );
    for (final state in [
      'Completed workout',
      'Scheduled rest day',
      'Missed scheduled workout',
      'Scheduled workout',
      'Future scheduled workout',
    ]) {
      expect(find.bySemanticsLabel(RegExp(', $state\$')), findsOneWidget);
    }
    expect(
      find.bySemanticsLabel(RegExp('No activity data')),
      findsNWidgets(26),
    );
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('activity-state-10')))
          .color,
      DigiGymDarkColors.electricGreen,
    );
    expect(find.byKey(const ValueKey('activity-state-9')), findsNothing);
    expect(find.byIcon(Icons.circle), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('midnight changes month and year without stale dates', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var now = DateTime(2026, 12, 31, 23, 59, 59);
    await tester.pumpWidget(calendar(clock: () => now));
    expect(find.text('DEC'), findsOneWidget);
    now = DateTime(2027, 1, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('JAN'), findsOneWidget);
    expect(day(DateTime(2026, 12, 31)), findsNothing);
    expect(
      find.bySemanticsLabel('January 1, 2027, Today, No activity data'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<DotMatrixText>(find.byKey(const ValueKey('activity-date')))
          .text,
      '1',
    );
    semantics.dispose();
  });

  testWidgets('resume, leap-day midnight and remount refresh the calendar', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var now = DateTime(2028, 2, 28, 23, 59, 59);
    DateTime clock() => now;
    await tester.pumpWidget(calendar(clock: clock));
    now = DateTime(2028, 2, 29);
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.bySemanticsLabel('February 29, 2028, Today, No activity data'),
      findsOneWidget,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2028, 3, 1, 14);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('MAR'), findsOneWidget);
    expect(day(DateTime(2028, 2, 29)), findsNothing);
    await tester.pumpWidget(const SizedBox());
    now = DateTime(2028, 4, 1);
    await tester.pump(const Duration(days: 30));
    await tester.pumpWidget(calendar(clock: clock));
    expect(find.text('APR'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'six-row calendar remains usable at narrow widths through 3x text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final width in [280.0, 320.0, 390.0, 1280 / 3]) {
        tester.view.physicalSize = Size(width, 640);
        for (final scale in [1.0, 2.0, 3.0]) {
          await tester.pumpWidget(
            calendar(clock: () => DateTime(2026, 8, 25), scale: scale),
          );
          final cells = [
            for (var i = 1; i <= 31; i++)
              tester.getRect(day(DateTime(2026, 8, i))),
          ];
          expect(cells.map((r) => r.top).toSet(), hasLength(6));
          for (final cell in cells) {
            expect(cell.left, greaterThanOrEqualTo(20));
            expect(cell.right, lessThanOrEqualTo(width - 20));
          }
          await tester.ensureVisible(day(DateTime(2026, 8, 31)));
          await tester.pumpAndSettle();
          expect(
            tester.getRect(day(DateTime(2026, 8, 31))).bottom,
            lessThanOrEqualTo(640),
          );
          expect(tester.takeException(), isNull, reason: '$width at $scale');
        }
      }
    },
  );
}
