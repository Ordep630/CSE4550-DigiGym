import 'package:digigym/widgets/dashboard_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final transition in [
    (4, 59, 'Good evening,', 'Good morning,'),
    (11, 59, 'Good morning,', 'Good afternoon,'),
    (16, 59, 'Good afternoon,', 'Good evening,'),
  ]) {
    testWidgets('visible dashboard updates at ${transition.$1 + 1}:00', (
      tester,
    ) async {
      var now = DateTime(2026, 10, 20, transition.$1, transition.$2, 59);
      await tester.pumpWidget(
        MaterialApp(home: DashboardGreeting(clock: () => now)),
      );
      expect(find.text(transition.$3), findsOneWidget);
      now = now.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(transition.$4), findsOneWidget);
    });
  }

  testWidgets('evening continues over midnight and changes at 05:00', (
    tester,
  ) async {
    var now = DateTime(2026, 12, 31, 23, 59, 59);
    await tester.pumpWidget(
      MaterialApp(home: DashboardGreeting(clock: () => now)),
    );
    now = DateTime(2027, 1, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Good evening,'), findsOneWidget);
    now = DateTime(2027, 1, 1, 5);
    await tester.pump(const Duration(hours: 5));
    expect(find.text('Good morning,'), findsOneWidget);
  });

  testWidgets('resume rechecks local time and reschedules the boundary', (
    tester,
  ) async {
    var now = DateTime(2026, 10, 20, 9);
    await tester.pumpWidget(
      MaterialApp(home: DashboardGreeting(clock: () => now)),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2026, 10, 20, 16, 59, 59);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('Good afternoon,'), findsOneWidget);
    now = DateTime(2026, 10, 20, 17);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Good evening,'), findsOneWidget);
  });

  testWidgets(
    'reopening the dashboard rechecks time and disposal cancels timers',
    (tester) async {
      var now = DateTime(2026, 10, 20, 9);
      Widget greeting() =>
          MaterialApp(home: DashboardGreeting(clock: () => now));
      await tester.pumpWidget(greeting());
      await tester.pumpWidget(const SizedBox());
      now = DateTime(2026, 10, 20, 18);
      await tester.pump(const Duration(hours: 9));
      await tester.pumpWidget(greeting());
      expect(find.text('Good evening,'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(days: 2));
      expect(tester.takeException(), isNull);
    },
  );
}
