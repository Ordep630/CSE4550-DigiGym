import 'dart:io';
import 'dart:convert';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/plan_card.dart';
import 'package:digigym/widgets/fitness_goal_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget dashboard({
  double textScale = 1,
  String name = 'Alex Morgan',
  EdgeInsets safeArea = const EdgeInsets.only(top: 24, bottom: 24),
  UserProfile? user,
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
        await precacheImage(
          const AssetImage('assets/images/digigym_workout_icon.png'),
          tester.element(find.byType(HomeScreen)),
        );
      });
      await tester.pumpAndSettle();
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(PlanCard).first))
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
        tester.getSize(find.byType(FitnessGoalCard)).height,
        inInclusiveRange(190, 210),
      );
      expect(
        tester
            .getSize(
              find
                  .descendant(
                    of: find.byType(PlanCard).first,
                    matching: find.byType(ClipRRect),
                  )
                  .first,
            )
            .height,
        inInclusiveRange(72, 80),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testAndroidDashboard(
    'complete dashboard fits the measured Pixel 10 Pro viewport',
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
        await precacheImage(
          const AssetImage('assets/images/digigym_workout_icon.png'),
          tester.element(find.byType(HomeScreen)),
        );
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
      expect(viewport.bottom, navigation.top);
      expect(viewport.height, 796);
      for (final label in [
        'DigiGym',
        'Welcome back,',
        'Isaac',
        'Build Muscle',
        '1818',
        '30 min',
        '19.2',
        '58.0 kg',
        'Your Plan',
        "Today's Workout",
        "Today's Nutrition",
        'Grocery List',
        'Intermediate 30-minute workout',
        'Target approximately 1818 calories',
        'View ingredients for your meal plan',
      ]) {
        final bounds = tester.getRect(find.text(label));
        expect(bounds.top, greaterThanOrEqualTo(52), reason: label);
        expect(bounds.bottom, lessThanOrEqualTo(navigation.top), reason: label);
        expect(bounds.left, greaterThanOrEqualTo(20), reason: label);
        expect(bounds.right, lessThanOrEqualTo(1280 / 3 - 20), reason: label);
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/dashboard_phase_2d.png'),
      );
      expect(tester.takeException(), isNull);
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
          final scrollable = tester.state<ScrollableState>(
            find.byType(Scrollable),
          );
          expect(scrollable.position.maxScrollExtent, greaterThan(0));
          await tester.ensureVisible(find.text('Grocery List'));
          await tester.pumpAndSettle();
          expect(find.text('24.7'), findsOneWidget);
          expect(find.text('80.0 kg'), findsOneWidget);
          expect(find.text('2075'), findsOneWidget);
          expect(find.text('45 min'), findsOneWidget);
          final description = tester.getRect(
            find.text('View ingredients for your meal plan'),
          );
          final viewport = tester.getRect(find.byType(SingleChildScrollView));
          expect(description.bottom, lessThanOrEqualTo(viewport.bottom));
          expect(tester.takeException(), isNull, reason: '$size at $scale');
        }
      }
    },
  );
}
