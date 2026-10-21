import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Device-local dashboard copy, independent of authentication and profile data.
class DashboardPersonalization {
  static const storageKey = 'digigym.dashboard.personalization.v1';
  static const defaultMessage =
      'Every workout brings you closer to your goals.';
  static const messages = [
    defaultMessage,
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

  final KeyValueStorage _storage;
  final Random _random;
  final Duration storageTimeout;
  final Map<String, int> _accountMessages = {};
  int? _previousMessage;
  Future<void>? _initialization;
  Future<void> _writes = Future.value();
  bool _dirty = false;
  int _revision = 0;

  DashboardPersonalization({
    KeyValueStorage? storage,
    Random? random,
    this.storageTimeout = const Duration(seconds: 1),
  }) : _storage = storage ?? FlutterSecureKeyValueStorage(null),
       _random = random ?? Random();

  /// An opaque, stable handle; raw emails and profile fields are never stored.
  static String accountKey(String email) => const Uuid().v5(
    Namespace.url.value,
    'digigym.dashboard.account:${email.trim().toLowerCase()}',
  );

  static String greetingFor(DateTime time) {
    final hour = time.toLocal().hour;
    if (hour >= 5 && hour < 12) return 'Good morning,';
    if (hour >= 12 && hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  static DateTime nextGreetingChange(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour < 5
        ? 5
        : local.hour < 12
        ? 12
        : 17;
    return local.hour < 17
        ? DateTime(local.year, local.month, local.day, hour)
        : DateTime(local.year, local.month, local.day + 1, 5);
  }

  Future<void> initialize() => _initialization ??= _load();

  Future<void> _load() async {
    try {
      final value = await _storage.get(storageKey).timeout(storageTimeout);
      if (value == null) return;
      final data = jsonDecode(value);
      if (data is! Map || data['version'] != 1) return;
      final accounts = data['accounts'];
      if (accounts is Map) {
        for (final entry in accounts.entries) {
          if (entry.key is String &&
              RegExp(r'^[a-f0-9-]{36}$').hasMatch(entry.key as String) &&
              _validIndex(entry.value)) {
            _accountMessages[entry.key as String] = entry.value as int;
          }
        }
      }
      if (_validIndex(data['previous'])) {
        _previousMessage = data['previous'] as int;
      }
    } catch (_) {
      // Personalization storage must never enter the authentication error path.
    }
  }

  static bool _validIndex(Object? value) =>
      value is int && value >= 0 && value < messages.length;

  /// Called only after a successful explicit login, never from widget builds.
  String startSession(String email) {
    final previous = _previousMessage;
    var index = _random.nextInt(messages.length - (previous == null ? 0 : 1));
    if (previous != null && index >= previous) index++;
    _accountMessages[accountKey(email)] = index;
    _previousMessage = index;
    _persist();
    return messages[index];
  }

  /// Existing sessions retain their choice; pre-feature sessions initialize once.
  String restoreSession(String email) {
    final index = _accountMessages[accountKey(email)];
    if (index == null) return startSession(email);
    if (_dirty) _persist();
    return messages[index];
  }

  void _persist() {
    _dirty = true;
    final revision = ++_revision;
    final snapshot = jsonEncode({
      'version': 1,
      'accounts': _accountMessages,
      'previous': _previousMessage,
    });
    // Serialize snapshots so a slower, older write cannot replace a new choice.
    _writes = _writes.then((_) async {
      try {
        await _storage.set(storageKey, snapshot);
        if (_revision == revision) _dirty = false;
      } catch (_) {
        // Retain the in-memory session and retry on resume or the next operation.
      }
    });
  }

  Future<void> retryPersistence() {
    if (_dirty) _persist();
    return flush();
  }

  /// Also allows callers/tests to wait for the current write queue to settle.
  Future<void> flush() => _writes.timeout(storageTimeout, onTimeout: () {});
}
