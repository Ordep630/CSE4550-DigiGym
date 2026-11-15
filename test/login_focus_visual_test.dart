import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'remaining_theme_visual_test.dart' as scenes;
import 'workout_theme_visual_test.dart' as fixtures;

void main() {
  setUpAll(fixtures.loadWorkoutVisualFonts);

  testWidgets(
    'Android light Login focus keeps both input containers in place',
    (tester) async {
      final shadows = debugDisableShadows;
      debugDisableShadows = false;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(426, 952);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      try {
        await scenes.openThemeScene(
          tester,
          'login',
          light: true,
          platform: TargetPlatform.android,
        );
        final fields = [
          find.byKey(const ValueKey('login-email')),
          find.byKey(const ValueKey('login-password')),
        ];
        Finder editable(Finder field) =>
            find.descendant(of: field, matching: find.byType(EditableText));
        Rect containerRect(Finder field) {
          final box = InputDecorator.containerOf(
            tester.element(editable(field)),
          )!;
          return box.localToGlobal(Offset.zero) & box.size;
        }

        final fieldSlots = fields.map(tester.getRect).toList();
        final inputContainers = fields.map(containerRect).toList();
        for (final (index, id) in ['email', 'password'].indexed) {
          final active = fields[index];
          if (index == 0) {
            await tester.tap(active);
          } else {
            await tester.testTextInput.receiveAction(TextInputAction.next);
          }
          await tester.pumpAndSettle();
          expect(tester.testTextInput.isVisible, isTrue);
          expect(
            tester.widget<EditableText>(editable(active)).focusNode.hasFocus,
            isTrue,
          );
          expect(fields.map(tester.getRect), fieldSlots);
          expect(fields.map(containerRect), inputContainers);
          final decoration = tester.widget<TextField>(active).decoration!;
          final focused = decoration.focusedBorder! as OutlineInputBorder;
          final normal = decoration.enabledBorder! as OutlineInputBorder;
          expect(focused.borderRadius, normal.borderRadius);
          expect(focused.borderSide.width, normal.borderSide.width);
          expect(focused.borderSide.color, DigiGymSurfaces.light.accent);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/login_light_${id}_focused_android.png'),
          );
        }
        expect(tester.takeException(), isNull);
      } finally {
        debugDisableShadows = shadows;
      }
    },
  );
}
