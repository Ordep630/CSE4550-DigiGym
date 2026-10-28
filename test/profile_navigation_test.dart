import 'dart:async';
import 'dart:ui' as ui;

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/app_appearance_screen.dart';
import 'package:digigym/screens/coming_soon_screen.dart';
import 'package:digigym/screens/edit_profile_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/profile_details_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/utils/measurement_units.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/digigym_form_components.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/profile_components.dart';
import 'package:digigym/widgets/profile_information.dart';
import 'package:flutter/material.dart';
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
    expect(find.text(user.fitnessLevel), findsNothing);
    expect(find.text(user.fitnessGoal), findsNothing);
    expect(find.text('125 min'), findsNothing);
    expect(find.byType(ProfileInformation), findsNothing);
    expect(find.byType(ProfileSummaryStat), findsNothing);
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
      // Grow the existing 104px card and 66px avatar by approximately 10–15%.
      expect(card.height / 104, inInclusiveRange(1.10, 1.15));
      final avatar = find.byType(ProfileAvatar);
      expect(
        tester.widget<ProfileAvatar>(avatar).size / 66,
        inInclusiveRange(1.10, 1.15),
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

  testWidgets('saved level colors remain available in Details and Workout', (
    tester,
  ) async {
    for (final level in ['Beginner', 'Intermediate', 'Advanced']) {
      await profile(tester, user: testUser()..fitnessLevel = level);
      final color = DigiGymFitnessLevelColors.forLevel(level);
      expect(find.text(level), findsNothing);
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
    'overview omits summary statistics and keeps the menu and logout gaps',
    (tester) async {
      final user = testUser()..workoutTime = 125;
      await profile(tester, user: user);
      expect(find.byType(ProfileSummaryStat), findsNothing);
      expect(
        find.byKey(const ValueKey('profile-statistics-panel')),
        findsNothing,
      );
      expect(find.text(user.fitnessLevel), findsNothing);
      expect(find.text(user.fitnessGoal), findsNothing);
      expect(find.text('125 min'), findsNothing);
      final identity = find.byKey(const ValueKey('profile-user-card'));
      final menu = find.byKey(const ValueKey('profile-settings-menu'));
      final logout = find.byKey(const ValueKey('profile-logout'));
      expect(tester.getRect(menu).top - tester.getRect(identity).bottom, 24);
      expect(tester.getRect(logout).top - tester.getRect(menu).bottom, 16);
      expect(tester.getSize(logout).height, 64);
      expect(find.ancestor(of: logout, matching: menu), findsNothing);
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
      expect(find.byType(BackdropFilter), findsOneWidget); // Navbar only.
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'identity menu and detached logout fit short Android phones through 3x text',
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
          expect(find.byType(ProfileSummaryStat), findsNothing);
          for (final key in ['profile-user-card', 'profile-settings-menu']) {
            final rect = tester.getRect(find.byKey(ValueKey(key)));
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
    expect(find.text('Advanced'), findsNothing);
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
    await tester.tap(find.byKey(const ValueKey('confirm-logout')));
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
