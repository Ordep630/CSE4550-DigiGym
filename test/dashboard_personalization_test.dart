import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:digigym/services/dashboard_personalization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class _Storage implements KeyValueStorage {
  String? value;
  Object? readError;
  Object? writeError;
  Future<void>? readWait;
  Future<void>? writeWait;
  int reads = 0;
  int writes = 0;
  final keys = <String>[];

  @override
  Future<String?> get(String key) async {
    keys.add(key);
    reads++;
    await readWait;
    if (readError != null) throw readError!;
    return value;
  }

  @override
  Future<void> set(String key, String? next) async {
    keys.add(key);
    writes++;
    await writeWait;
    if (writeError != null) throw writeError!;
    value = next;
  }
}

class _FixedRandom implements Random {
  final int value;
  int calls = 0;
  _FixedRandom(this.value);
  @override
  int nextInt(int max) {
    calls++;
    return value % max;
  }

  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

void main() {
  test('the exact ten approved messages are available', () async {
    const expected = [
      'Every workout brings you closer to your goals.',
      'Small steps lead to big changes.',
      'Progress starts with showing up.',
      "Keep pushing. You're getting stronger.",
      'Consistency is what makes the difference.',
      'A little progress is still progress.',
      'Your goals are worth the effort.',
      'Build better habits, one day at a time.',
      "Stay focused. You've got this.",
      'Another day, another opportunity to improve.',
    ];
    expect(DashboardPersonalization.messages, expected);
    for (var index = 0; index < expected.length; index++) {
      final service = DashboardPersonalization(
        storage: _Storage(),
        random: _FixedRandom(index),
      );
      await service.initialize();
      expect(service.startSession('a@example.com'), expected[index]);
      await service.flush();
    }
  });

  for (final boundary in [
    (4, 59, 59, 'Good evening,'),
    (5, 0, 0, 'Good morning,'),
    (11, 59, 59, 'Good morning,'),
    (12, 0, 0, 'Good afternoon,'),
    (16, 59, 59, 'Good afternoon,'),
    (17, 0, 0, 'Good evening,'),
    (23, 59, 59, 'Good evening,'),
    (0, 0, 0, 'Good evening,'),
  ]) {
    test('local greeting at ${boundary.$1}:${boundary.$2}:${boundary.$3}', () {
      final local = DateTime(
        2026,
        10,
        20,
        boundary.$1,
        boundary.$2,
        boundary.$3,
      );
      expect(DashboardPersonalization.greetingFor(local), boundary.$4);
      expect(DashboardPersonalization.greetingFor(local.toUtc()), boundary.$4);
    });
  }

  test('next boundary follows local calendar dates, including midnight', () {
    for (final boundary in [
      (0, 5),
      (4, 5),
      (5, 12),
      (11, 12),
      (12, 17),
      (16, 17),
    ]) {
      expect(
        DashboardPersonalization.nextGreetingChange(
          DateTime(2026, 10, 20, boundary.$1, 30),
        ),
        DateTime(2026, 10, 20, boundary.$2),
      );
    }
    expect(
      DashboardPersonalization.nextGreetingChange(
        DateTime(2026, 12, 31, 23, 59),
      ),
      DateTime(2027, 1, 1, 5),
    );
    expect(
      DashboardPersonalization.nextGreetingChange(DateTime(2027, 1, 1)),
      DateTime(2027, 1, 1, 5),
    );
  });

  test(
    'consecutive successful logins never repeat, including account switches',
    () async {
      final service = DashboardPersonalization(
        storage: _Storage(),
        random: Random(3),
      );
      await service.initialize();
      String? previous;
      for (var i = 0; i < 100; i++) {
        final message = service.startSession(
          i.isEven ? 'a@example.com' : 'b@example.com',
        );
        expect(message, isNot(previous));
        previous = message;
      }
      await service.flush();
    },
  );

  test(
    'account-scoped choices survive service recreation without reselection',
    () async {
      final storage = _Storage();
      final first = DashboardPersonalization(
        storage: storage,
        random: _FixedRandom(0),
      );
      await first.initialize();
      final a = first.startSession('A@Example.com');
      final b = first.startSession('b@example.com');
      await first.flush();
      final random = _FixedRandom(9);
      final restored = DashboardPersonalization(
        storage: storage,
        random: random,
      );
      await restored.initialize();
      expect(restored.restoreSession(' a@example.com '), a);
      expect(restored.restoreSession('b@example.com'), b);
      expect(random.calls, 0);
      final writes = storage.writes;
      expect(restored.restoreSession('a@example.com'), a);
      await restored.flush();
      expect(storage.writes, writes);
      expect(restored.startSession('a@example.com'), isNot(b));
      await restored.flush();
    },
  );

  test(
    'an existing session with no metadata initializes exactly once',
    () async {
      final storage = _Storage();
      final random = _FixedRandom(4);
      final first = DashboardPersonalization(storage: storage, random: random);
      await first.initialize();
      final message = first.restoreSession('a@example.com');
      expect(first.restoreSession('a@example.com'), message);
      expect(random.calls, 1);
      await first.flush();
      final newRandom = _FixedRandom(7);
      final restored = DashboardPersonalization(
        storage: storage,
        random: newRandom,
      );
      await restored.initialize();
      expect(restored.restoreSession('a@example.com'), message);
      expect(newRandom.calls, 0);
    },
  );

  test(
    'stored metadata contains only opaque account handles and message IDs',
    () async {
      final storage = _Storage();
      final service = DashboardPersonalization(storage: storage);
      await service.initialize();
      service.startSession('private@example.com');
      await service.flush();
      final payload = jsonDecode(storage.value!) as Map;
      expect(payload.keys.toSet(), {'version', 'accounts', 'previous'});
      expect(payload['accounts'], {
        DashboardPersonalization.accountKey('private@example.com'): isA<int>(),
      });
      expect(storage.value, isNot(contains('private@example.com')));
      expect(storage.keys.toSet(), {DashboardPersonalization.storageKey});
    },
  );

  test('malformed or unsupported metadata recovers safely', () async {
    for (final value in [
      'invalid',
      '[]',
      '{"version":2}',
      '{"version":1,"accounts":{"email":99},"previous":-1}',
    ]) {
      final storage = _Storage()..value = value;
      final service = DashboardPersonalization(
        storage: storage,
        random: _FixedRandom(2),
      );
      await service.initialize();
      expect(
        service.restoreSession('a@example.com'),
        DashboardPersonalization.messages[2],
      );
      await service.flush();
    }
  });

  test('storage errors retain the in-memory choice and can retry', () async {
    final storage = _Storage()
      ..readError = Exception('unavailable')
      ..writeError = Exception('unavailable');
    final service = DashboardPersonalization(storage: storage);
    await service.initialize();
    final message = service.startSession('a@example.com');
    await service.flush();
    expect(service.restoreSession('a@example.com'), message);
    await service.flush();
    storage.writeError = null;
    await service.retryPersistence();
    final restored = DashboardPersonalization(
      storage: storage..readError = null,
    );
    await restored.initialize();
    expect(restored.restoreSession('a@example.com'), message);
  });

  test('unresponsive storage has a bounded initialization and flush', () async {
    final storage = _Storage()
      ..readWait = Completer<void>().future
      ..writeWait = Completer<void>().future;
    final service = DashboardPersonalization(
      storage: storage,
      storageTimeout: const Duration(milliseconds: 5),
    );
    await service.initialize();
    final message = service.startSession('a@example.com');
    await service.flush();
    expect(service.restoreSession('a@example.com'), message);
    await service.flush();
  });

  test(
    'slow writes are serialized and cannot overwrite a newer session',
    () async {
      final gate = Completer<void>();
      final storage = _Storage()..writeWait = gate.future;
      final service = DashboardPersonalization(
        storage: storage,
        random: _FixedRandom(0),
      );
      await service.initialize();
      service.startSession('a@example.com');
      final last = service.startSession('a@example.com');
      await Future<void>.delayed(Duration.zero);
      expect(storage.writes, 1);
      gate.complete();
      await service.flush();
      expect(storage.writes, 2);
      final restored = DashboardPersonalization(storage: storage);
      await restored.initialize();
      expect(restored.restoreSession('a@example.com'), last);
    },
  );
}
