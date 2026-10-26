import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Device-local weekday choices only. Recommendations are derived separately.
/// Each controller belongs to one immutable authenticated account UUID.
class WorkoutScheduleController extends ChangeNotifier {
  final String? accountId;
  final KeyValueStorage _storage;
  final Duration storageTimeout;
  Future<void>? _initialization;
  Future<void> _writes = Future.value();
  Set<int>? _workoutDays;
  bool loading = true;
  bool saving = false;
  bool _readFailed = false;
  bool _disposed = false;
  String? error;

  WorkoutScheduleController({
    required this.accountId,
    KeyValueStorage? storage,
    this.storageTimeout = const Duration(seconds: 2),
  }) : _storage = storage ?? FlutterSecureKeyValueStorage(null);

  bool get hasIdentity =>
      accountId != null &&
      RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(accountId!);
  String? get storageKey => hasIdentity
      ? 'digigym.workoutSchedule.v1.${accountId!.toLowerCase()}'
      : null;
  Set<int>? get workoutDays => _workoutDays;
  bool get configured => _workoutDays != null;
  bool get canEdit => hasIdentity && !loading && !_readFailed && !saving;

  Future<void> initialize() => _initialization ??= _load();

  Future<void> _load() async {
    loading = true;
    error = null;
    _readFailed = false;
    _workoutDays = null;
    if (!hasIdentity) {
      loading = false;
      error = 'A signed-in account identity is needed to save a schedule.';
      _notify();
      return;
    }
    try {
      final raw = await _storage.get(storageKey!).timeout(storageTimeout);
      if (_disposed) return;
      if (raw != null) {
        final data = jsonDecode(raw);
        if (data is! Map ||
            data['version'] != 1 ||
            data['workoutDays'] is! List) {
          throw const FormatException('Unsupported schedule');
        }
        final days = data['workoutDays'] as List;
        if (days.any((day) => day is! int || day < 0 || day > 6) ||
            days.toSet().length != days.length) {
          throw const FormatException('Invalid weekdays');
        }
        _workoutDays = Set.unmodifiable(days.cast<int>());
      }
    } on FormatException {
      // Never reinterpret corrupt/older data as an arbitrary weekly plan.
      error = 'The saved schedule could not be read. Choose your days again.';
    } catch (_) {
      _readFailed = true;
      error = 'Schedule storage is unavailable. Retry to load your saved days.';
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<void> reload() {
    if (loading || saving) return initialize();
    _initialization = null;
    return initialize();
  }

  Future<bool> save(Set<int> days) async {
    await initialize();
    if (_disposed || !canEdit) return false;
    if (days.any((day) => day < 0 || day > 6)) {
      throw ArgumentError('Weekdays must be Sunday (0) through Saturday (6).');
    }
    final selection = Set<int>.unmodifiable(days);
    final ordered = days.toList()..sort();
    saving = true;
    error = null;
    _notify();
    // Serialize even timed-out writes, so a delayed older save cannot replace
    // a newer choice. Disposing the controller never deletes persisted data.
    final write = _writes.then(
      (_) => _storage.set(
        storageKey!,
        jsonEncode({'version': 1, 'workoutDays': ordered}),
      ),
    );
    _writes = write.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    try {
      await write.timeout(storageTimeout);
      if (_disposed) return false;
      _workoutDays = selection;
      return true;
    } catch (_) {
      error = 'Your schedule could not be saved. Please try again.';
      return false;
    } finally {
      saving = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _workoutDays = null;
    super.dispose();
  }
}
