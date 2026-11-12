import 'dart:ui' as ui;
import 'dart:io';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/dashboard_progress_card.dart';
import 'package:digigym/widgets/segmented_progress_ring.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    for (final font in {
      'DigiGymInter': 'Inter',
      'DigiGymDoto': 'Doto',
    }.entries) {
      await (FontLoader(font.key)..addFont(
            rootBundle.load('assets/fonts/${font.value}-Variable.ttf'),
          ))
          .load();
    }
  });
  test('invalid percentages cannot be presented as workout data', () {
    for (final value in [-1.0, 100.01, double.nan, double.infinity]) {
      expect(() => SegmentedProgressRing(progress: value), throwsArgumentError);
    }
  });
  test(
    '0 percent paints no green; other percentages fill proportional segments',
    () async {
      Future<int> activePixels(double value) async {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        const active = Color(0xFF70FF45);
        SegmentedProgressPainter(
          progress: value,
          activeColor: active,
        ).paint(canvas, const Size(240, 240));
        final picture = recorder.endRecording();
        final image = await picture.toImage(240, 240);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        image.dispose();
        picture.dispose();
        var count = 0;
        for (var i = 0; i < bytes!.lengthInBytes; i += 4) {
          if (bytes.getUint8(i) == 0x70 &&
              bytes.getUint8(i + 1) == 255 &&
              bytes.getUint8(i + 2) == 0x45 &&
              bytes.getUint8(i + 3) == 255) {
            count++;
          }
        }
        return count;
      }

      expect(await activePixels(0), 0);
      final full = await activePixels(100);
      expect(full, greaterThan(1000));
      for (final percent in [1.25, 25.0, 50.0, 75.0]) {
        expect(
          await activePixels(percent) / full,
          closeTo(percent / 100, .008),
        );
      }
    },
  );
  testWidgets(
    'matrix percentage, Complete label and semantics represent supplied values',
    (tester) async {
      final semantics = tester.ensureSemantics();
      for (final value in [0.0, 12.5, 50.0, 100.0]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: DigiGymDashboardTheme.dark(ThemeData()),
            home: Scaffold(
              body: Center(child: DashboardProgressCard(progress: value)),
            ),
          ),
        );
        final label = value.round().toString();
        expect(find.bySemanticsLabel('$label% complete'), findsOneWidget);
        expect(
          tester.widget<DotMatrixText>(find.byType(DotMatrixText)).text,
          '$label%',
        );
        expect(find.text('Complete'), findsOneWidget);
        expect(find.text("Today's Progress"), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      semantics.dispose();
    },
  );
  testWidgets(
    'square matrix percentage stays centered inside the unchanged ring',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(280, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final scale in [1.0, 2.0, 3.0]) {
        for (final value in [0.0, 25.0, 75.0, 100.0]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: DigiGymDashboardTheme.dark(ThemeData()),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: Center(
                  child: SegmentedProgressRing(progress: value, diameter: 140),
                ),
              ),
            ),
          );
          final ring = tester.getRect(find.byType(SegmentedProgressRing));
          final percentage = find.byKey(
            const ValueKey('progress-percentage-bounds'),
          );
          final bounds = tester.getRect(percentage);
          final label = tester.getRect(find.text('Complete'));
          final matrix = tester.widget<DotMatrixText>(
            find.byType(DotMatrixText),
          );
          expect(
            matrix.height,
            closeTo(140 * .64 / DotMatrixPainter.widthFor('100%', 1), .001),
          );
          expect(matrix.scaleWithText, isFalse);
          expect(matrix.softenedDigits, isTrue);
          expect(matrix.color, DigiGymDarkColors.primaryText);
          expect(bounds.center.dx, closeTo(ring.center.dx, .01));
          expect((bounds.top + label.bottom) / 2, closeTo(ring.center.dy, .01));
          expect(bounds.left, greaterThan(ring.left + 10));
          expect(bounds.right, lessThan(ring.right - 10));
          expect(label.bottom, lessThan(ring.bottom - 10));
          expect(label.top, greaterThan(bounds.bottom));
          expect(tester.takeException(), isNull, reason: '$value at $scale');
        }
      }
    },
  );

  testWidgets(
    'all whole percentages keep the same digit size and clear the inner ring',
    (tester) async {
      double? expectedHeight;
      for (var percent = 0; percent <= 100; percent++) {
        await tester.pumpWidget(
          MaterialApp(
            theme: DigiGymDashboardTheme.dark(ThemeData()),
            home: Scaffold(
              body: Center(
                child: SegmentedProgressRing(progress: percent.toDouble()),
              ),
            ),
          ),
        );
        final matrix = tester.widget<DotMatrixText>(find.byType(DotMatrixText));
        expectedHeight ??= matrix.height;
        expect(matrix.height, expectedHeight);
        final ring = tester.getRect(find.byType(SegmentedProgressRing));
        final group = tester.getRect(
          find.byKey(const ValueKey('progress-percentage-bounds')),
        );
        expect(group.center.dx, closeTo(ring.center.dx, .001));
        final innerRadius = ring.width * .435;
        for (final corner in [
          group.topLeft,
          group.topRight,
          group.bottomLeft,
          group.bottomRight,
        ]) {
          expect((corner - ring.center).distance, lessThan(innerRadius - 7));
        }
        expect(tester.takeException(), isNull, reason: '$percent%');
      }
    },
  );

  testWidgets('isolated 0 25 75 and 100 percent visual comparison', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(460, 550);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final boundary = GlobalKey();
    Widget card(double value) => SizedBox(
      width: 200,
      child: DashboardProgressCard(progress: value, minimumHeight: 208),
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DigiGymDashboardTheme.content(
          DigiGymDashboardTheme.dark(ThemeData()),
        ),
        home: RepaintBoundary(
          key: boundary,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Isolated percentage previews',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Visual samples only • no workout records changed',
                    style: TextStyle(
                      fontSize: 11,
                      color: DigiGymDarkColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [card(0), card(25)],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [card(75), card(100)],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final heights = tester
        .widgetList<DotMatrixText>(find.byType(DotMatrixText))
        .map((w) => w.height)
        .toSet();
    expect(heights, hasLength(1));
    if (const bool.fromEnvironment('DIGIGYM_CAPTURE_TYPOGRAPHY')) {
      final image = await tester.runAsync(
        () =>
            (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 3),
      );
      final bytes = await tester.runAsync(
        () => image!.toByteData(format: ui.ImageByteFormat.png),
      );
      await tester.runAsync(
        () =>
            File('/private/tmp/digigym_phase3h_typography_preview.png')
                .writeAsBytes(bytes!.buffer.asUint8List()),
      );
      image!.dispose();
    }
  });

  testWidgets(
    'standard Pixel dashboard preserves zero progress, imperial weight and safe calendar scrolling',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280 / 3, 952);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final profile = UserProfile(
        name: 'Demo User',
        email: 'demo@gym.com',
        height: 175,
        weight: 75,
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(padding: const EdgeInsets.only(top: 52, bottom: 24)),
            child: child!,
          ),
          home: HomeScreen(
            user: profile,
            clock: () => DateTime(2026, 10, 24, 9),
            onLogout: () async {},
            onUpdateProfile: (_) {},
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
      expect(
        tester
            .widget<DotMatrixText>(
              find.byKey(const ValueKey('progress-percentage')),
            )
            .text,
        '0%',
      );
      expect(find.text('165.3 lb'), findsOneWidget);
      expect(find.text('Good Morning,'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      final scroll = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      // This fixture does not load the navigation's platform Roboto faces.
      // The Android-font appearance test verifies exact Pixel viewport fit.
      expect(scroll.maxScrollExtent, lessThanOrEqualTo(20));
      scroll.jumpTo(scroll.maxScrollExtent);
      await tester.pumpAndSettle();
      final navigation = tester.getRect(
        find.byType(FloatingBottomNavigationBar),
      );
      expect(
        tester
            .getRect(find.byKey(const ValueKey('month-day-2026-10-31')))
            .bottom,
        lessThan(navigation.top),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
