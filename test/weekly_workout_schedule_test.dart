import 'dart:ui' show SemanticsAction;

import 'package:digigym/models/workout_schedule_day.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/weekly_workout_schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget week({
  required DateTime Function() clock,
  List<WorkoutScheduleDay> days = const [],
  double scale = 1,
  VoidCallback? onSeeAll,
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
        child: WeeklyWorkoutSchedule(
          clock: clock,
          days: days,
          onSeeAll: onSeeAll,
        ),
      ),
    ),
  ),
);

Finder badge(DateTime date) => find.byKey(
  ValueKey('week-badge-${date.toIso8601String().split('T').first}'),
);

void expectSelected(WidgetTester tester, DateTime date) {
  final semantics = find.bySemanticsLabel(
    RegExp('${date.toIso8601String().split('T').first}, Today'),
  );
  expect(semantics, findsOneWidget);
  final decoration =
      tester.widget<Container>(badge(date)).decoration! as BoxDecoration;
  expect(decoration.boxShadow, isNotEmpty);
  for (final day in WeeklyWorkoutSchedule.weekDates(date)) {
    final label = tester.widget<Text>(
      find.byKey(
        ValueKey('week-label-${day.toIso8601String().split('T').first}'),
      ),
    );
    expect(
      label.style!.color,
      day == DateUtils.dateOnly(date)
          ? const Color(0xFF67E780)
          : DigiGymDarkColors.secondaryText,
    );
    expect(
      label.style!.shadows,
      day == DateUtils.dateOnly(date) ? isNotEmpty : isNull,
    );
  }
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      DigiGymDashboardTheme.textFont,
    )..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'))).load();
  });
  test('Sunday-first calendar week handles weekend and year boundaries', () {
    for (final entry in [
      (DateTime(2026, 10, 25), DateTime(2026, 10, 25)),
      (DateTime(2026, 10, 31, 23, 59), DateTime(2026, 10, 25)),
      (DateTime(2026, 11, 1), DateTime(2026, 11, 1)),
      (DateTime(2027, 1, 1), DateTime(2026, 12, 27)),
    ]) {
      final dates = WeeklyWorkoutSchedule.weekDates(entry.$1);
      expect(dates, hasLength(7));
      expect(dates.first, entry.$2);
      expect(dates.first.weekday, DateTime.sunday);
      expect(dates.last.weekday, DateTime.saturday);
      expect(dates.map((d) => d.hour), everyElement(0));
      expect(dates.toSet(), hasLength(7));
    }
  });

  testWidgets(
    'seven dated neutral badges have Sunday-first single-letter labels',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(week(clock: () => DateTime(2026, 10, 28, 13)));
      expect(find.text('Your Week'), findsOneWidget);
      final letters = tester
          .widgetList<Text>(find.byType(Text))
          .where((w) => w.data?.length == 1)
          .map((w) => w.data)
          .toList();
      expect(letters, ['S', 'M', 'T', 'W', 'T', 'F', 'S']);
      final dates = WeeklyWorkoutSchedule.weekDates(DateTime(2026, 10, 28));
      final bounds = dates.map((d) => tester.getRect(badge(d))).toList();
      expect(bounds.map((r) => r.top).toSet(), hasLength(1));
      for (var i = 1; i < 7; i++) {
        expect(bounds[i].left, greaterThan(bounds[i - 1].right));
      }
      expect(find.byIcon(Icons.remove_rounded), findsNWidgets(7));
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(find.bySemanticsLabel(RegExp('Unassigned Day')), findsNWidgets(7));
      expect(
        find.bySemanticsLabel(RegExp('Rest Day|Completed Workout|Upper Body')),
        findsNothing,
      );
      expectSelected(tester, DateTime(2026, 10, 28));
      for (final date in dates) {
        final data = tester
            .getSemantics(
              find
                  .ancestor(of: badge(date), matching: find.byType(Semantics))
                  .first,
            )
            .getSemanticsData();
        expect(data.hasAction(SemanticsAction.tap), isFalse);
      }
      semantics.dispose();
    },
  );

  for (final rest in [false, true]) {
    testWidgets(
      'shared current-day initial glows on ${rest ? 'rest' : 'workout'} days without changing its circle',
      (tester) async {
        final now = DateTime(2026, 10, 28, 12);
        final current = WorkoutScheduleDay(
          date: now,
          isRestDay: rest,
          workoutType: rest ? null : ScheduledWorkoutType.fullBody,
        );
        await tester.pumpWidget(week(clock: () => now));
        final circle = tester.widget<Container>(badge(current.date));
        final oldBounds = tester.getRect(badge(current.date));
        final before = circle.decoration;
        await tester.pumpWidget(week(clock: () => now, days: [current]));
        expect(tester.getRect(badge(current.date)), oldBounds);
        expect(
          tester.widget<Container>(badge(current.date)).decoration,
          before,
        );
        for (final date in WeeklyWorkoutSchedule.weekDates(now)) {
          final label = tester.widget<Text>(
            find.byKey(
              ValueKey('week-label-${date.toIso8601String().split('T').first}'),
            ),
          );
          expect(label.style!.fontSize, 13);
          if (date == current.date) {
            expect(label.style!.color, DigiGymDarkColors.softGreen);
            expect(label.style!.shadows, [
              Shadow(
                color: const Color(0xFF67E780).withValues(alpha: .30),
                blurRadius: 6,
              ),
            ]);
          } else {
            expect(label.style!.color, DigiGymDarkColors.secondaryText);
            expect(label.style!.shadows, isNull);
          }
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'midnight moves highlight and Saturday to Sunday starts a new week',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var now = DateTime(2026, 10, 31, 23, 59, 59);
      await tester.pumpWidget(week(clock: () => now));
      expectSelected(tester, DateTime(2026, 10, 31));
      now = DateTime(2026, 11, 1);
      await tester.pump(const Duration(seconds: 1));
      expectSelected(tester, DateTime(2026, 11, 1));
      expect(badge(DateTime(2026, 10, 31)), findsNothing);
      expect(badge(DateTime(2026, 11, 7)), findsOneWidget);
      final previousMidnight = now;
      now = DateTime(2026, 11, 2);
      // The device-local fall-back day can be 25 hours, rather than 24.
      await tester.pump(now.difference(previousMidnight));
      expectSelected(tester, now);
      semantics.dispose();
    },
  );

  testWidgets('resume, parent updates and remount recheck the local calendar', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var now = DateTime(2026, 10, 30, 10);
    DateTime clock() => now;
    await tester.pumpWidget(week(clock: clock));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2026, 10, 31, 12);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expectSelected(tester, DateTime(2026, 10, 31));
    now = DateTime(2026, 11, 1);
    await tester.pumpWidget(week(clock: clock));
    expectSelected(tester, now);
    await tester.pumpWidget(const SizedBox());
    now = DateTime(2027, 1, 1);
    await tester.pump(const Duration(days: 60));
    await tester.pumpWidget(week(clock: clock));
    expectSelected(tester, now);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'only supplied date assignments produce workout, rest or completion symbols',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final dates = WeeklyWorkoutSchedule.weekDates(DateTime(2026, 10, 28));
      for (final type in ScheduledWorkoutType.values) {
        await tester.pumpWidget(
          week(
            clock: () => dates.first,
            days: [WorkoutScheduleDay(date: dates[1], workoutType: type)],
          ),
        );
        expect(find.byIcon(Icons.remove_rounded), findsNWidgets(6));
        expect(
          find.bySemanticsLabel(RegExp('Unassigned Day')),
          findsNWidgets(6),
        );
        expect(find.byIcon(Icons.check_rounded), findsNothing);
      }
      await tester.pumpWidget(
        week(
          clock: () => dates.first,
          days: [
            WorkoutScheduleDay(date: dates[2], isRestDay: true),
            WorkoutScheduleDay(
              date: dates[3],
              workoutType: ScheduledWorkoutType.fullBody,
              isCompleted: true,
            ),
            WorkoutScheduleDay(
              date: dates.first.subtract(const Duration(days: 1)),
              isCompleted: true,
            ),
          ],
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Rest Day')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Full Body, Completed Workout')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsNWidgets(5));
      semantics.dispose();
    },
  );

  testWidgets(
    'all seven aligned columns fit 280-426px screens through 3x text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final dates = WeeklyWorkoutSchedule.weekDates(DateTime(2026, 10, 28));
      for (final width in [280.0, 320.0, 390.0, 1280 / 3]) {
        tester.view.physicalSize = Size(width, 640);
        for (final scale in [1.0, 2.0, 3.0]) {
          await tester.pumpWidget(
            week(clock: () => dates[3], scale: scale, onSeeAll: () {}),
          );
          final boxes = dates.map((d) => tester.getRect(badge(d))).toList();
          expect(boxes.map((r) => r.top).toSet(), hasLength(1));
          expect(boxes.first.left, greaterThanOrEqualTo(20));
          expect(boxes.last.right, lessThanOrEqualTo(width - 20));
          for (var i = 1; i < 7; i++) {
            expect(boxes[i].left, greaterThan(boxes[i - 1].right));
          }
          final letters = find.byWidgetPredicate(
            (w) => w is Text && w.data?.length == 1,
          );
          expect(letters, findsNWidgets(7));
          for (final label in letters.evaluate()) {
            final rect = tester.getRect(find.byWidget(label.widget));
            expect(rect.left, greaterThanOrEqualTo(20));
            expect(rect.right, lessThanOrEqualTo(width - 20));
          }
          expect(tester.takeException(), isNull, reason: '$width at $scale');
        }
      }
    },
  );
}
