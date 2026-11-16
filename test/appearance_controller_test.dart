import 'dart:async';

import 'package:digigym/theme/appearance_controller.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_schedule_storage.dart';

void main() {
  test('unset, invalid, and unavailable storage default to Dark', () async {
    for (final value in [null, '', 'invalid']) {
      final storage = MemoryScheduleStorage();
      if (value != null) {
        storage.values[AppearanceController.storageKey] = value;
      }
      final controller = AppearanceController(storage: storage);
      expect(controller.mode, ThemeMode.dark);
      await controller.initialize();
      expect(controller.mode, ThemeMode.dark);
      expect(controller.initialized, isTrue);
      expect(storage.writes, 0);
      controller.dispose();
    }
    final controller = AppearanceController(
      storage: MemoryScheduleStorage()..readError = StateError('unavailable'),
    );
    await controller.initialize();
    expect(controller.mode, ThemeMode.dark);
    controller.dispose();
  });

  test(
    'all three preferences persist and restore after controller restart',
    () async {
      final storage = MemoryScheduleStorage();
      for (final mode in ThemeMode.values) {
        final first = AppearanceController(storage: storage);
        await first.initialize();
        await first.select(mode);
        expect(storage.values[AppearanceController.storageKey], mode.name);
        first.dispose();
        final restarted = AppearanceController(storage: storage);
        await restarted.initialize();
        expect(restarted.mode, mode);
        restarted.dispose();
      }
    },
  );

  test(
    'rapid selections serialize so the final choice survives restart',
    () async {
      final storage = MemoryScheduleStorage();
      final gate = Completer<void>();
      final controller = AppearanceController(storage: storage);
      await controller.initialize();
      storage.writeWait = gate.future;
      final writes = [
        controller.select(ThemeMode.light),
        controller.select(ThemeMode.system),
        controller.select(ThemeMode.dark),
      ];
      expect(controller.mode, ThemeMode.dark);
      gate.complete();
      await Future.wait(writes);
      expect(storage.values[AppearanceController.storageKey], 'dark');
      controller.dispose();
    },
  );

  test('late restoration cannot replace an explicit Dark selection', () async {
    final gate = Completer<void>();
    final storage = MemoryScheduleStorage()
      ..values[AppearanceController.storageKey] = 'light'
      ..readWait = gate.future;
    final controller = AppearanceController(storage: storage);
    final load = controller.initialize();
    await controller.select(ThemeMode.dark);
    gate.complete();
    await load;
    expect(controller.mode, ThemeMode.dark);
    controller.dispose();
  });

  test('read timeout allows startup to continue in Dark', () async {
    final storage = MemoryScheduleStorage()
      ..readWait = Completer<void>().future;
    final controller = AppearanceController(
      storage: storage,
      storageTimeout: const Duration(milliseconds: 1),
    );
    await controller.initialize();
    expect(controller.initialized, isTrue);
    expect(controller.mode, ThemeMode.dark);
    controller.dispose();
  });

  test('failed writes retain the selection and retry persistence', () async {
    final storage = MemoryScheduleStorage()
      ..writeError = StateError('unavailable');
    final controller = AppearanceController(storage: storage);
    await controller.initialize();
    await controller.select(ThemeMode.light);
    expect(controller.mode, ThemeMode.light);
    expect(controller.hasPersistenceError, isTrue);
    storage.writeError = null;
    await controller.retryPersistence();
    expect(controller.hasPersistenceError, isFalse);
    expect(storage.values[AppearanceController.storageKey], 'light');
    controller.dispose();
  });

  test('completing a read after disposal does not notify listeners', () async {
    final gate = Completer<void>();
    final controller = AppearanceController(
      storage: MemoryScheduleStorage()..readWait = gate.future,
    );
    final load = controller.initialize();
    controller.dispose();
    gate.complete();
    await load;
  });

  test('surface extensions copy and interpolate both appearance endpoints', () {
    final dark = DigiGymSurfaces.dark;
    final light = DigiGymSurfaces.light;
    final midpoint = dark.lerp(light, .5);
    expect(dark.lerp(light, 0).glass, dark.glass);
    expect(dark.lerp(light, 1).glass, light.glass);
    expect(midpoint.glowIntensity, closeTo(.89, .0001));
    expect(midpoint.numberScale, closeTo(1.03, .0001));
    expect(midpoint.dotFillRatio, closeTo(.71, .0001));
    expect(midpoint.bmiSurfaceOpacity, closeTo(.97, .0001));
    expect(
      midpoint.background,
      BoxDecoration.lerp(dark.background, light.background, .5),
    );
    expect(light.copyWith(accent: Colors.red).accent, Colors.red);
    expect(light.copyWith(accent: Colors.red).glass, light.glass);
    expect(light.accent.computeLuminance(), lessThan(.25));
  });
}
