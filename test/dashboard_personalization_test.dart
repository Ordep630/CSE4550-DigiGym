import 'dart:async';
import 'dart:convert';

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

void main() {
  test(
    'restored account alignment survives logout and a full app restart',
    () async {
      final storage = _Storage()
        ..value = jsonEncode({
          'version': 1,
          'previous': 3,
          'accounts': {DashboardPersonalization.accountKey('a@example.com'): 4},
        });
      final restored = DashboardPersonalization(storage: storage);
      await restored.initialize();
      expect(
        restored.restoreSession('a@example.com'),
        DashboardPersonalization.messages[4],
      );
      await restored.flush();
      final restarted = DashboardPersonalization(storage: storage);
      await restarted.initialize();
      expect(
        restarted.startSession('a@example.com'),
        DashboardPersonalization.messages[5],
      );
      await restarted.flush();
    },
  );
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
  test(
    'successful logins cycle through the exact ten messages in order',
    () async {
      final service = DashboardPersonalization(storage: _Storage());
      await service.initialize();
      expect(DashboardPersonalization.messages, expected);
      for (var i = 0; i < 30; i++) {
        expect(service.startSession('a@example.com'), expected[i % 10]);
      }
      await service.flush();
    },
  );
  for (final boundary in [
    (4, 59, 59, 'Good Evening,'),
    (5, 0, 0, 'Good Morning,'),
    (11, 59, 59, 'Good Morning,'),
    (12, 0, 0, 'Good Afternoon,'),
    (16, 59, 59, 'Good Afternoon,'),
    (17, 0, 0, 'Good Evening,'),
    (23, 59, 59, 'Good Evening,'),
    (0, 0, 0, 'Good Evening,'),
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
  test('greeting boundaries follow local calendar dates and midnight', () {
    for (final b in [(0, 5), (4, 5), (5, 12), (11, 12), (12, 17), (16, 17)]) {
      expect(
        DashboardPersonalization.nextGreetingChange(
          DateTime(2026, 10, 20, b.$1, 30),
        ),
        DateTime(2026, 10, 20, b.$2),
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
  test('rotation persists across process recreation without restoration consuming a login', () async {
    final storage = _Storage();
    var service = DashboardPersonalization(storage: storage);
    await service.initialize();
    for (var i = 0; i < 25; i++) {
      final message = service.startSession('a@example.com');
      expect(message, expected[i % 10]);
      await service.flush();
      final writes = storage.writes;
      service = DashboardPersonalization(storage: storage);
      await service.initialize();
      expect(service.restoreSession('A@Example.com'), message);
      expect(service.restoreSession(' a@example.com '), message);
      await service.flush();
      expect(storage.writes, writes);
    }
  });
  test(
    'restoring an older account never repeats its message on the next login',
    () async {
      final storage = _Storage()
        ..value = jsonEncode({
          'version': 1,
          'previous': 3,
          'accounts': {
            DashboardPersonalization.accountKey('a@example.com'): 4,
            DashboardPersonalization.accountKey('b@example.com'): 3,
          },
        });
      final service = DashboardPersonalization(storage: storage);
      await service.initialize();
      expect(service.restoreSession('a@example.com'), expected[4]);
      expect(service.startSession('a@example.com'), expected[5]);
      expect(service.startSession('b@example.com'), expected[6]);
      await service.flush();
      final restored = DashboardPersonalization(storage: storage);
      await restored.initialize();
      expect(restored.restoreSession('a@example.com'), expected[5]);
      expect(restored.startSession('a@example.com'), expected[6]);
      await restored.flush();
    },
  );
  test('legacy metadata retains the selected message and continues the new sequence', () async {
    final storage = _Storage()
      ..value = jsonEncode({
        'version': 1,
        'previous': 9,
        'accounts': {DashboardPersonalization.accountKey('a@example.com'): 9},
      });
    final service = DashboardPersonalization(storage: storage);
    await service.initialize();
    expect(service.restoreSession('a@example.com'), expected[9]);
    expect(service.startSession('a@example.com'), expected[0]);
    await service.flush();
  });
  test('a restored session with no metadata initializes once and remembers its next login', () async {
    final storage = _Storage();
    final service = DashboardPersonalization(storage: storage);
    await service.initialize();
    expect(service.restoreSession('a@example.com'), expected[0]);
    expect(service.restoreSession('a@example.com'), expected[0]);
    await service.flush();
    expect(storage.writes, 1);
    final next = DashboardPersonalization(storage: storage);
    await next.initialize();
    expect(next.startSession('a@example.com'), expected[1]);
    await next.flush();
  });
  test('metadata stores only opaque account handles and indices', () async {
    final storage = _Storage();
    final service = DashboardPersonalization(storage: storage);
    await service.initialize();
    service.startSession('private@example.com');
    await service.flush();
    final payload = jsonDecode(storage.value!) as Map;
    expect(payload.keys.toSet(), {'version', 'accounts', 'previous'});
    expect(payload['accounts'], {
      DashboardPersonalization.accountKey('private@example.com'): 0,
    });
    expect(storage.value, isNot(contains('private@example.com')));
    expect(storage.keys.toSet(), {DashboardPersonalization.storageKey});
  });
  test('malformed metadata recovers safely', () async {
    for (final value in [
      'invalid',
      '[]',
      '{"version":2}',
      '{"version":1,"accounts":{"email":99},"previous":-1}',
    ]) {
      final storage = _Storage()..value = value;
      final service = DashboardPersonalization(storage: storage);
      await service.initialize();
      expect(service.restoreSession('a@example.com'), expected[0]);
      await service.flush();
    }
  });
  test(
    'unavailable storage never blocks in-memory rotation and can retry',
    () async {
      final storage = _Storage()
        ..readError = Exception('offline')
        ..writeError = Exception('offline');
      final service = DashboardPersonalization(storage: storage);
      await service.initialize();
      expect(service.startSession('a@example.com'), expected[0]);
      await service.flush();
      expect(service.startSession('a@example.com'), expected[1]);
      await service.flush();
      storage.writeError = null;
      await service.retryPersistence();
      final restored = DashboardPersonalization(
        storage: storage..readError = null,
      );
      await restored.initialize();
      expect(restored.restoreSession('a@example.com'), expected[1]);
    },
  );
  test('unresponsive storage has bounded initialization and flush', () async {
    final storage = _Storage()
      ..readWait = Completer<void>().future
      ..writeWait = Completer<void>().future;
    final service = DashboardPersonalization(
      storage: storage,
      storageTimeout: const Duration(milliseconds: 5),
    );
    await service.initialize();
    final first = service.startSession('a@example.com');
    await service.flush();
    expect(service.restoreSession('a@example.com'), first);
    await service.flush();
  });
  test(
    'slow serialized writes cannot replace the newest rotation index',
    () async {
      final gate = Completer<void>();
      final storage = _Storage()..writeWait = gate.future;
      final service = DashboardPersonalization(storage: storage);
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
