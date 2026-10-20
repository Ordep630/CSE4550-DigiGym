import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';

void main() {
  Widget host({
    Brightness brightness = Brightness.light,
    int index = 0,
    ValueChanged<int>? onTap,
  }) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        bottomNavigationBar: FloatingBottomNavigationBar(
          selectedIndex: index,
          onDestinationSelected: onTap ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('all five destinations dispatch their existing indices', (
    tester,
  ) async {
    final taps = <int>[];
    await tester.pumpWidget(host(onTap: taps.add));
    for (final label in ['Home', 'Workout', 'Meals', 'Groceries', 'Profile']) {
      await tester.tap(find.text(label));
    }
    expect(taps, [0, 1, 2, 3, 4]);
  });

  testWidgets(
    'workout uses the official asset with sharp filtering and proportional width',
    (tester) async {
      await tester.pumpWidget(host(index: 1));
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/digigym_workout_icon.png',
      );
      expect(image.width, 38);
      expect(image.height, isNull);
      expect(image.filterQuality, FilterQuality.none);
      expect(image.fit, BoxFit.contain);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('selection follows parent state and theme brightness', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(host(brightness: brightness, index: 1));
      expect(find.bySemanticsLabel('Workout'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Workout')),
        matchesSemantics(
          label: 'Workout',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      final selectedColor = tester.widget<Image>(find.byType(Image)).color;
      await tester.pumpWidget(host(brightness: brightness, index: 0));
      expect(
        tester.widget<Image>(find.byType(Image)).color,
        isNot(selectedColor),
      );
    }
    semantics.dispose();
  });

  testWidgets('fits narrow and wide layouts with safe area and enlarged text', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final width in [320.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 800),
              padding: const EdgeInsets.only(bottom: 34),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              bottomNavigationBar: FloatingBottomNavigationBar(
                selectedIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final surface = tester.getRect(find.byType(BackdropFilter));
      expect(surface.width, lessThanOrEqualTo(560));
      expect(surface.bottom, lessThanOrEqualTo(766));
    }
  });
}
