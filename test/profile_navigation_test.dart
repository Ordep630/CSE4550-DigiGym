import 'dart:async';
import 'dart:ui' as ui;

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/app_appearance_screen.dart';
import 'package:digigym/screens/coming_soon_screen.dart';
import 'package:digigym/screens/edit_profile_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/screens/profile_details_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/utils/measurement_units.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/digigym_form_components.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/profile_components.dart';
import 'package:digigym/widgets/profile_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

Future<void> profile(
  WidgetTester tester, {
  UserProfile? user,
  FakeDigiGymApi? api,
  double width = 420,
  double height = 912,
  double scale = 1,
  TargetPlatform platform = TargetPlatform.android,
  Future<void> Function()? onLogout,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  var current = user ?? testUser();
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          padding: const EdgeInsets.only(top: 62, bottom: 34),
        ),
        child: child!,
      ),
      home: StatefulBuilder(
        builder: (context, update) => HomeScreen(
          user: current,
          api: api ?? FakeDigiGymApi(),
          onLogout: onLogout ?? () async {},
          onUpdateProfile: (value) => update(() => current = value),
          clock: () => DateTime(2026, 10, 25, 18),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(FloatingBottomNavigationBar),
      matching: find.text('Profile'),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapRow(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    for (final font in [
      (DigiGymDashboardTheme.textFont, 'assets/fonts/Inter-Variable.ttf'),
      (DigiGymDashboardTheme.numberFont, 'assets/fonts/Doto-Variable.ttf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });

  testWidgets('overview uses actual account values and one connected menu', (
    tester,
  ) async {
    final user = testUser(name: 'Alex Rivera', email: 'alex@example.com')
      ..workoutTime = 125;
    final api = FakeDigiGymApi();
    await profile(tester, user: user, api: api);
    expect(find.text(user.name), findsOneWidget);
    expect(find.text(user.email), findsOneWidget);
    expect(find.text(user.fitnessLevel), findsOneWidget);
    expect(find.text(user.fitnessGoal), findsOneWidget);
    expect(find.text('125 min'), findsOneWidget);
    expect(find.byType(ProfileInformation), findsNothing);
    final cards = tester.getSize(find.byType(ProfileSummaryStat).first);
    for (final stat in find.byType(ProfileSummaryStat).evaluate()) {
      expect(tester.getSize(find.byWidget(stat.widget)), cards);
    }
    final menu = find.byKey(const ValueKey('profile-settings-menu'));
    expect(
      find.descendant(of: menu, matching: find.byType(DashboardGlassCard)),
      findsNothing,
    );
    expect(
      find.descendant(of: menu, matching: find.byType(ProfileMenuRow)),
      findsNWidgets(5),
    );
    expect(
      tester
          .widgetList<ProfileMenuRow>(
            find.descendant(of: menu, matching: find.byType(ProfileMenuRow)),
          )
          .map((row) => row.label),
      [
        'Edit Profile',
        'Preferences',
        'Notifications',
        'App Appearance',
        'Help & Support',
      ],
    );
    expect(find.byIcon(Icons.settings), findsNothing);
    expect(api.updateRequest, isNull);
  });

  testWidgets(
    'overview initial follows the actual trimmed Unicode display name',
    (tester) async {
      for (final entry in <String, String>{
        'Isaac': 'I',
        'Genesis': 'G',
        '  isaac rivera  ': 'I',
        'Élodie': 'É',
        'e\u0301lisa': 'E\u0301',
        '': '?',
        '   ': '?',
      }.entries) {
        await profile(tester, user: testUser(name: entry.key));
        expect(find.text(entry.value), findsOneWidget);
        expect(find.byIcon(Icons.person_rounded), findsNothing);
        final initial = tester.widget<Text>(find.text(entry.value));
        expect(initial.style?.fontFamily, DigiGymDashboardTheme.textFont);
        await tester.tap(find.byKey(const ValueKey('profile-user-card')));
        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsOneWidget);
        expect(
          tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).size,
          100,
        );
        expect(find.byIcon(Icons.person_rounded), findsNothing);
        expect(
          tester
              .widget<ProfileDetailsScreen>(find.byType(ProfileDetailsScreen))
              .user
              .name,
          entry.key,
        );
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets(
    'user card grows modestly with a centered translucent-glass initial',
    (tester) async {
      await profile(tester, user: testUser(name: 'Isaac'));
      final card = tester.getRect(
        find.byKey(const ValueKey('profile-user-card')),
      );
      // The previous approved card was 88px; keep the requested 15–20% increase.
      expect(card.height / 88, inInclusiveRange(1.15, 1.20));
      final avatar = find.byType(ProfileAvatar);
      expect(
        tester.widget<ProfileAvatar>(avatar).size / 56,
        inInclusiveRange(1.15, 1.20),
      );
      final initial = find.text('I');
      expect(tester.getRect(initial).center, tester.getRect(avatar).center);
      expect(
        tester.widget<Text>(initial).style?.color,
        DigiGymDarkColors.primaryText,
      );
      final surface = tester.widget<Container>(
        find.descendant(of: avatar, matching: find.byType(Container)),
      );
      final decoration = surface.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.gradient!.colors.every((color) => color.a < 1), isTrue);
      expect((decoration.border! as Border).top.color.a, lessThan(.2));
      await tester.tap(find.byKey(const ValueKey('profile-user-card')));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileDetailsScreen), findsOneWidget);
    },
  );

  testWidgets(
    'shared avatar handles unavailable names and optional circular images',
    (tester) async {
      for (final size in [66.0, 100.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(child: ProfileAvatar(size: size)),
          ),
        );
        expect(find.text('?'), findsOneWidget);
        expect(tester.getSize(find.byType(ProfileAvatar)), Size.square(size));
        final before = tester
            .widget<Container>(
              find.descendant(
                of: find.byType(ProfileAvatar),
                matching: find.byType(Container),
              ),
            )
            .decoration;
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: ProfileAvatar(
                size: size,
                name: 'Isaac',
                image: const AssetImage(
                  'assets/images/digigym_workout_icon.png',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('I'), findsNothing);
        expect(find.byType(ClipOval), findsOneWidget);
        final image = tester.widget<Image>(find.byType(Image));
        expect(image.fit, BoxFit.cover);
        expect(image.width, size);
        expect(
          tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(ProfileAvatar),
                  matching: find.byType(Container),
                ),
              )
              .decoration,
          before,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('saved level colors agree on Profile, Details and Workout', (
    tester,
  ) async {
    for (final level in ['Beginner', 'Intermediate', 'Advanced']) {
      await profile(tester, user: testUser()..fitnessLevel = level);
      final color = DigiGymFitnessLevelColors.forLevel(level);
      expect(tester.widget<Text>(find.text(level)).style?.color, color);
      await tester.tap(find.byKey(const ValueKey('profile-user-card')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text(level)).style?.color, color);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(FloatingBottomNavigationBar),
          matching: find.text('Workout'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(level), findsNothing);
      expect(tester.widget<Text>(find.text('$level Plan')).style?.color, color);
    }
    expect(
      DigiGymFitnessLevelColors.forLevel(' advanced '),
      DigiGymFitnessLevelColors.advanced,
    );
    expect(
      DigiGymFitnessLevelColors.forLevel('Unknown'),
      DigiGymDarkColors.primaryText,
    );
  });

  testWidgets('secondary routes share green accessible back controls', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await profile(tester);
    for (final route in [
      'Details',
      'Edit Profile',
      'App Appearance',
      'Preferences',
    ]) {
      if (route == 'Details') {
        await tester.tap(find.byKey(const ValueKey('profile-user-card')));
        await tester.pumpAndSettle();
      } else {
        await tapRow(tester, route);
      }
      final back = find.byType(BackButton);
      expect(
        tester.widget<BackButton>(back).color,
        DigiGymDarkColors.electricGreen,
      );
      expect(tester.getSize(back).height, greaterThanOrEqualTo(48));
      expect(
        tester
            .getSemantics(back)
            .getSemanticsData()
            .hasAction(ui.SemanticsAction.tap),
        isTrue,
      );
      await tester.tap(back);
      await tester.pumpAndSettle();
    }
    semantics.dispose();
  });

  testWidgets('logout illumination is restricted to its icon and text', (
    tester,
  ) async {
    await profile(tester);
    final row = find.byKey(const ValueKey('profile-logout'));
    final widget = tester.widget<ProfileMenuRow>(row);
    expect(widget.glow, isTrue);
    expect(widget.color, const Color(0xFFFF5F68));
    final icon = tester.widget<Icon>(
      find.descendant(of: row, matching: find.byIcon(Icons.logout_rounded)),
    );
    final text = tester.widget<Text>(find.text('Log Out'));
    expect(icon.color, widget.color);
    expect(text.style!.color, widget.color);
    expect(icon.shadows!.first.color.a, inInclusiveRange(.5, .6));
    expect(text.style!.shadows!.first.color.a, inInclusiveRange(.4, .5));
    expect(icon.shadows!.length, 2);
    expect(text.style!.shadows!.length, 2);
    expect(
      find.descendant(of: row, matching: find.byType(DecoratedBox)),
      findsNothing,
    );
    for (final other in tester.widgetList<ProfileMenuRow>(
      find.byType(ProfileMenuRow),
    )) {
      if (other.label != 'Log Out') expect(other.glow, isFalse);
    }
  });

  testWidgets(
    'neutral statistics panel keeps equal sections, dimensions and dividers',
    (tester) async {
      await profile(tester);
      final stats = tester
          .widgetList<ProfileSummaryStat>(find.byType(ProfileSummaryStat))
          .toList();
      expect(stats[0].iconAsset, 'assets/images/digigym_workout_icon.png');
      expect(stats[1].iconAsset, 'assets/icons/biceps_flexed.png');
      expect(stats[2].icon, Icons.bar_chart_outlined);
      final bounds = tester.getSize(find.byType(ProfileSummaryStat).first);
      final panel = find.byKey(const ValueKey('profile-statistics-panel'));
      expect(tester.widget(panel), isA<DashboardGlassCard>());
      expect(
        find.descendant(of: panel, matching: find.byType(DashboardGlassCard)),
        findsNothing,
      );
      expect(
        find.descendant(of: panel, matching: find.byType(ProfileGlassLighting)),
        findsNothing,
      );
      expect(
        find.ancestor(of: panel, matching: find.byType(ProfileUpperLighting)),
        findsNothing,
      );
      final identity = find.byKey(const ValueKey('profile-user-card'));
      expect(
        find.descendant(
          of: identity,
          matching: find.byType(ProfileGlassLighting),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: identity,
          matching: find.byType(ProfileUpperLighting),
        ),
        findsOneWidget,
      );
      final glass = tester.widget<DashboardGlassCard>(panel);
      expect(glass.padding, EdgeInsets.zero);
      expect(glass.cornerRadius, DigiGymDashboardTheme.cardRadius);
      expect(
        find.descendant(of: panel, matching: find.byType(VerticalDivider)),
        findsNWidgets(2),
      );
      final sections = find.byType(ProfileSummaryStat);
      final first = tester.getRect(sections.at(0));
      final second = tester.getRect(sections.at(1));
      final third = tester.getRect(sections.at(2));
      expect(second.left - first.right, closeTo(1, .001));
      expect(third.left - second.right, closeTo(1, .001));
      expect(
        find.descendant(of: sections, matching: find.byType(DecoratedBox)),
        findsNothing,
      );
      for (final stat in stats) {
        expect(tester.getSize(find.byWidget(stat)), bounds);
      }
      final duration = tester.widget<Text>(find.text('45 min'));
      expect(bounds.height, closeTo(120, .001));
      expect(duration.style?.fontFamily, DigiGymDashboardTheme.textFont);
      final spans = (duration.textSpan! as TextSpan).children!.cast<TextSpan>();
      expect(spans.first.text, '45');
      expect(spans.first.style?.fontSize, 18);
      expect(spans.first.style?.fontWeight, FontWeight.w700);
      expect(spans.last.text, ' min');
      expect(spans.last.style?.fontSize, 12);
      expect(spans.last.style?.fontWeight, FontWeight.w500);
      expect(
        find.descendant(of: panel, matching: find.byType(DashboardNumber)),
        findsNothing,
      );
      expect(
        find.byType(BackdropFilter),
        findsOneWidget,
      ); // Existing navbar only.
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('statistics use the softer green from the actual Login button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(onLogin: (_) {}, api: FakeDigiGymApi()),
      ),
    );
    await tester.pumpAndSettle();
    final decorations = tester.widgetList<DecoratedBox>(
      find.ancestor(
        of: find.widgetWithText(ElevatedButton, 'Login'),
        matching: find.byType(DecoratedBox),
      ),
    );
    final gradient = decorations
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .map((box) => box.gradient)
        .whereType<LinearGradient>()
        .firstWhere(
          (gradient) =>
              gradient.begin == Alignment.centerLeft &&
              gradient.end == Alignment.centerRight,
        );
    expect(ProfileSummaryStat.iconColor, gradient.colors.last);
    await profile(tester);
    for (final stat in tester.widgetList<ProfileSummaryStat>(
      find.byType(ProfileSummaryStat),
    )) {
      final image = find.descendant(
        of: find.byWidget(stat),
        matching: find.byType(Image),
      );
      final color = stat.iconAsset != null
          ? tester.widget<Image>(image).color
          : tester
                .widget<Icon>(
                  find.descendant(
                    of: find.byWidget(stat),
                    matching: find.byType(Icon),
                  ),
                )
                .color;
      expect(color, gradient.colors.last);
    }
    expect(
      tester.widget<Text>(find.text('Intermediate')).style?.color,
      DigiGymFitnessLevelColors.intermediate,
    );
  });

  testWidgets(
    'duration shares the unchanged value baseline without growing the panel',
    (tester) async {
      double baseline(String text) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(of: find.text(text), matching: find.byType(RichText)),
        );
        return MatrixUtils.transformPoint(
          paragraph.getTransformTo(null),
          Offset(
            0,
            paragraph.getDryBaseline(
              paragraph.constraints,
              TextBaseline.alphabetic,
            )!,
          ),
        ).dy;
      }

      for (final width in [390.0, 420.0]) {
        for (final minutes in [30, 45, 90, 125, 300, 999]) {
          await profile(
            tester,
            width: width,
            user: testUser()..workoutTime = minutes,
          );
          final expected = baseline('Intermediate');
          expect(baseline('Build Muscle'), closeTo(expected, .01));
          expect(
            baseline('$minutes min'),
            closeTo(expected, .01),
            reason: '$minutes minutes / $width width',
          );
          expect(
            tester
                .getSize(find.byKey(const ValueKey('profile-statistics-panel')))
                .height,
            closeTo(120, .001),
          );
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'level values alone receive restrained semantic colors and all values use matching Inter',
    (tester) async {
      for (final entry in <String, Color>{
        'Beginner': const Color(0xFF45D98A),
        'Intermediate': const Color(0xFFF2A34A),
        'Advanced': const Color(0xFFF26B6B),
      }.entries) {
        await profile(
          tester,
          user: testUser()
            ..fitnessLevel = entry.key
            ..workoutTime = 125,
        );
        final level = tester.widget<Text>(find.text(entry.key));
        expect(level.style?.color, entry.value);
        final contrast =
            (entry.value.computeLuminance() + .05) /
            (DigiGymDarkColors.charcoal.computeLuminance() + .05);
        expect(contrast, greaterThanOrEqualTo(4.5));
        for (final value in [entry.key, 'Build Muscle']) {
          final text = tester.widget<Text>(find.text(value));
          expect(text.style?.fontFamily, DigiGymDashboardTheme.textFont);
          expect(text.style?.fontSize, 14);
          expect(text.style?.fontWeight, FontWeight.w600);
          expect(text.style?.height, 22 / 14);
        }
        for (final label in ['Level', 'Goal', 'Duration']) {
          expect(tester.widget<Text>(find.text(label)).style?.fontSize, 11);
          expect(
            tester.widget<Text>(find.text(label)).style?.color,
            DigiGymDarkColors.secondaryText,
          );
        }
        expect(
          tester.widget<Text>(find.text('Build Muscle')).style?.color,
          DigiGymDarkColors.primaryText,
        );
        expect(
          tester.widget<Text>(find.text('125 min')).style?.color,
          DigiGymDarkColors.primaryText,
        );
      }
    },
  );

  testWidgets(
    'official level asset stays sharp and saved goals select existing fitness artwork',
    (tester) async {
      for (final goal in [
        'Build Muscle',
        'Lose Weight',
        'Maintain Weight',
        'Gain Weight',
        'Other Goal',
      ]) {
        await profile(tester, user: testUser(fitnessGoal: goal));
        final stats = tester
            .widgetList<ProfileSummaryStat>(find.byType(ProfileSummaryStat))
            .toList();
        final levelImage = tester.widget<Image>(
          find.descendant(
            of: find.byWidget(stats[0]),
            matching: find.byType(Image),
          ),
        );
        expect(
          (levelImage.image as AssetImage).assetName,
          'assets/images/digigym_workout_icon.png',
        );
        expect(levelImage.filterQuality, FilterQuality.none);
        expect(levelImage.fit, BoxFit.contain);
        expect(levelImage.color, ProfileSummaryStat.iconColor);
        expect(levelImage.colorBlendMode, BlendMode.srcIn);
        expect(stats[0].iconSize, 28.5);
        expect(stats[0].iconWidth, 38);
        expect(stats[1].iconSize, goal == 'Build Muscle' ? 25.5 : 27);
        expect(stats[2].iconSize, 23);
        expect(stats[1].value, goal);
        if (goal == 'Build Muscle') {
          final bicep = tester.widget<Image>(
            find.descendant(
              of: find.byWidget(stats[1]),
              matching: find.byType(Image),
            ),
          );
          expect(
            (bicep.image as AssetImage).assetName,
            'assets/icons/biceps_flexed.png',
          );
          expect(bicep.width, 25.5);
          expect(bicep.height, 25.5);
          expect(bicep.color, ProfileSummaryStat.iconColor);
          final filter = tester.widget<ImageFiltered>(
            find.descendant(
              of: find.byWidget(stats[1]),
              matching: find.byType(ImageFiltered),
            ),
          );
          expect(
            filter.imageFilter.toString(),
            ui.ImageFilter.erode(radiusX: .12, radiusY: .12).toString(),
          );
          expect(
            find.descendant(
              of: find.byWidget(stats[0]),
              matching: find.byType(ImageFiltered),
            ),
            findsNothing,
          );
        } else {
          expect(stats[1].iconAsset, isNull);
          expect(stats[1].icon, switch (goal) {
            'Lose Weight' => Icons.monitor_weight_outlined,
            'Maintain Weight' => Icons.balance_outlined,
            'Gain Weight' => Icons.trending_up_rounded,
            _ => Icons.track_changes_outlined,
          });
          expect(
            tester
                .widget<Icon>(
                  find.descendant(
                    of: find.byWidget(stats[1]),
                    matching: find.byType(Icon),
                  ),
                )
                .color,
            ProfileSummaryStat.iconColor,
          );
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'statistics and logout remain unclipped on short Android phones through 3x text',
    (tester) async {
      for (final size in [const Size(280, 568), const Size(320, 640)]) {
        for (final scale in [1.0, 2.0, 3.0]) {
          await profile(
            tester,
            width: size.width,
            height: size.height,
            scale: scale,
            user: testUser(fitnessGoal: 'Maintain Weight')..workoutTime = 125,
          );
          for (final value in ['Intermediate', 'Maintain Weight', '125 min']) {
            final rect = tester.getRect(find.text(value));
            expect(rect.left, greaterThanOrEqualTo(20));
            expect(rect.right, lessThanOrEqualTo(size.width - 20));
          }
          final scroll = tester.state<ScrollableState>(
            find.byType(Scrollable).first,
          );
          scroll.position.jumpTo(scroll.position.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(
            tester.getRect(find.byKey(const ValueKey('profile-logout'))).bottom,
            lessThanOrEqualTo(
              tester.getRect(find.byType(FloatingBottomNavigationBar)).top,
            ),
          );
          expect(tester.takeException(), isNull, reason: '$size at $scale');
        }
      }
    },
  );

  testWidgets(
    'profile card and settings expose accessible tap actions and touch targets',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await profile(tester);
      for (final label in [
        'View profile details for Test User, test@example.com',
        'Edit Profile',
        'Preferences',
        'Notifications',
        'App Appearance',
        'Help & Support',
        'Log Out',
      ]) {
        final target = find.bySemanticsLabel(label);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(
          tester
              .getSemantics(target)
              .getSemanticsData()
              .hasAction(ui.SemanticsAction.tap),
          isTrue,
          reason: label,
        );
        expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'user card opens complete read-only imperial details, never edit',
    (tester) async {
      final user = testUser();
      await profile(tester, user: user);
      await tester.tap(find.byKey(const ValueKey('profile-user-card')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ProfileDetailsScreen>(find.byType(ProfileDetailsScreen))
            .user,
        same(user),
      );
      expect(find.byType(EditProfileScreen), findsNothing);
      final fields = <String, String>{
        for (final card in tester.widgetList<ProfileInformation>(
          find.byType(ProfileInformation),
        ))
          card.title: card.value,
      };
      expect(fields, {
        'Name': user.name,
        'Email': user.email,
        'Age': '${user.age} years',
        'Height': MeasurementUnits.formatHeight(user.height),
        'Weight': MeasurementUnits.formatWeight(user.weight),
        'BMI': user.bmi.toStringAsFixed(1),
        'Fitness Level': user.fitnessLevel,
        'Fitness Goal': user.fitnessGoal,
        'Workout Time': '${user.workoutTime} minutes',
        'Diet': user.dietaryPreference,
        'Body Type': user.bodyType,
      });
      expect(find.text('Edit Profile'), findsNothing);
      final panel = find.byKey(const ValueKey('profile-details-panel'));
      expect(find.byType(DashboardGlassCard), findsOneWidget);
      expect(
        find.descendant(of: panel, matching: find.byType(Divider)),
        findsNWidgets(10),
      );
      expect(
        find.descendant(of: panel, matching: find.byType(DashboardGlassCard)),
        findsNothing,
      );
      expect(find.byType(TextField), findsNothing);
      for (final tile in tester.widgetList<ListTile>(find.byType(ListTile))) {
        expect(tile.onTap, isNull);
        expect(tile.onLongPress, isNull);
      }
      for (final row in tester.widgetList<ProfileInformation>(
        find.byType(ProfileInformation),
      )) {
        expect(row.connected, isTrue);
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('profile-user-card')), findsOneWidget);
    },
  );

  testWidgets('edit uses existing API and refreshes overview and details', (
    tester,
  ) async {
    final api = FakeDigiGymApi();
    await profile(tester, api: api);
    await tapRow(tester, 'Edit Profile');
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.byType(DigiGymFormBranding), findsNothing);
    expect(find.byType(Image), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'Updated Name');
    final levelDropdown = find.byType(DropdownButtonFormField<String>).first;
    await tester.ensureVisible(levelDropdown);
    await tester.tap(levelDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced').last);
    await tester.pumpAndSettle();
    await tapRow(tester, 'SAVE CHANGES');
    expect(api.updateRequest?.name, 'Updated Name');
    expect(api.updateRequest?.fitnessLevel, 'Advanced');
    expect(find.text('Updated Name'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Advanced')).style?.color,
      DigiGymFitnessLevelColors.advanced,
    );
    await tester.tap(find.byKey(const ValueKey('profile-user-card')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ProfileDetailsScreen>(find.byType(ProfileDetailsScreen))
          .user
          .name,
      'Updated Name',
    );
    expect(
      tester.widget<Text>(find.text('Advanced')).style?.color,
      DigiGymFitnessLevelColors.advanced,
    );
  });

  testWidgets(
    'appearance shows selected dark and unavailable light without toggling theme',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await profile(tester);
      await tapRow(tester, 'App Appearance');
      expect(find.byType(AppAppearanceScreen), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Dark Mode, selected')),
        matchesSemantics(
          label: 'Dark Mode, selected',
          hasEnabledState: true,
          isEnabled: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Light Mode, Coming Soon, unavailable'),
        ),
        matchesSemantics(
          label: 'Light Mode, Coming Soon, unavailable',
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      await tester.tap(find.text('Light Mode'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Dark Mode'))).brightness,
        Brightness.dark,
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets('three settings open the same artwork route with working back', (
    tester,
  ) async {
    await profile(tester);
    for (final feature in ['Preferences', 'Notifications', 'Help & Support']) {
      await tapRow(tester, feature);
      expect(
        tester.widget<ComingSoonScreen>(find.byType(ComingSoonScreen)).feature,
        feature,
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        ComingSoonScreen.illustrationAsset,
      );
      expect(image.fit, BoxFit.contain);
      expect(find.byType(Text), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('logout preserves cancel, async guard and failure recovery', (
    tester,
  ) async {
    var calls = 0;
    final gate = Completer<void>();
    await profile(
      tester,
      onLogout: () {
        calls++;
        return gate.future;
      },
    );
    await tapRow(tester, 'Log Out');
    await tapRow(tester, 'Cancel');
    expect(calls, 0);
    await tapRow(tester, 'Log Out');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pump();
    expect(calls, 1);
    expect(
      tester
          .widget<ProfileMenuRow>(find.byKey(const ValueKey('profile-logout')))
          .onTap,
      isNull,
    );
    gate.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(
      find.text('Unable to log out. Check your connection and retry.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ProfileMenuRow>(find.byKey(const ValueKey('profile-logout')))
          .onTap,
      isNotNull,
    );
  });

  testWidgets(
    'narrow layouts and 3x text keep every profile control and destination reachable',
    (tester) async {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        for (final width in [280.0, 320.0, 420.0]) {
          for (final scale in [1.0, 2.0, 3.0]) {
            await profile(
              tester,
              platform: platform,
              width: width,
              scale: scale,
              user: testUser(
                name: 'Alexanderthegreat Montgomery',
                email: 'a.long.account.address@example.com',
                fitnessGoal: 'Maintain Weight',
              )..workoutTime = 125,
            );
            final nav = tester.getRect(
              find.byType(FloatingBottomNavigationBar),
            );
            final scroll = tester.state<ScrollableState>(
              find.byType(Scrollable).first,
            );
            scroll.position.jumpTo(scroll.position.maxScrollExtent);
            await tester.pumpAndSettle();
            final logout = tester.getRect(
              find.byKey(const ValueKey('profile-logout')),
            );
            expect(logout.bottom, lessThanOrEqualTo(nav.top));
            for (final label in [
              'Edit Profile',
              'Preferences',
              'Notifications',
              'App Appearance',
              'Help & Support',
              'Log Out',
            ]) {
              await tester.ensureVisible(find.text(label));
              await tester.pumpAndSettle();
              expect(
                tester.getRect(find.text(label)).right,
                lessThanOrEqualTo(width - 20),
              );
            }
            await tapRow(tester, 'App Appearance');
            await tester.ensureVisible(find.text('Light Mode'));
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$platform $width $scale appearance',
            );
            await tester.pageBack();
            await tester.pumpAndSettle();
            await tapRow(tester, 'Preferences');
            expect(
              tester.getRect(find.byType(Image)).right,
              lessThanOrEqualTo(width - 20),
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$platform $width $scale artwork',
            );
            await tester.pageBack();
            await tester.pumpAndSettle();
            await tester.ensureVisible(
              find.byKey(const ValueKey('profile-user-card')),
            );
            await tester.tapAt(
              tester.getTopLeft(
                    find.byKey(const ValueKey('profile-user-card')),
                  ) +
                  const Offset(36, 36),
            );
            await tester.pumpAndSettle();
            for (final field in ['Email', 'Body Type']) {
              await tester.ensureVisible(find.text(field));
              await tester.pumpAndSettle();
            }
            expect(
              tester.takeException(),
              isNull,
              reason: '$platform $width $scale details',
            );
            await tester.pageBack();
            await tester.pumpAndSettle();
          }
        }
      }
    },
  );
}
