import 'dart:io';
import 'dart:convert';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/plan_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget dashboard({double textScale = 1, String name = 'Alex Morgan'}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: const EdgeInsets.only(top: 24, bottom: 24),
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: HomeScreen(
        user: UserProfile(
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

  testWidgets('deterministic Android dashboard appearance with local fonts', (
    tester,
  ) async {
    final originalShadows = debugDisableShadows;
    debugDisableShadows = false;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    try {
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
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/dashboard_phase_2c.png'),
      );
      expect(tester.takeException(), isNull);
    } finally {
      debugDisableShadows = originalShadows;
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
    'bundled fonts stay readable on narrow phones and enlarged text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final width in [320.0, 390.0]) {
        tester.view.physicalSize = Size(width, 844);
        for (final scale in [1.0, 2.0, 3.0]) {
          await tester.pumpWidget(
            dashboard(textScale: scale, name: 'Alexandria Morgan Hernandez'),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$width at $scale');
          await tester.ensureVisible(find.text('Grocery List'));
          await tester.pumpAndSettle();
          expect(find.text('24.7'), findsOneWidget);
          expect(find.text('80.0 kg'), findsOneWidget);
          expect(find.text('2075'), findsOneWidget);
          expect(find.text('45 min'), findsOneWidget);
          expect(tester.takeException(), isNull, reason: '$width at $scale');
        }
      }
    },
  );
}
