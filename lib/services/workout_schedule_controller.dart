import 'dart:async';

import 'package:flutter/foundation.dart';

import 'digigym_api.dart';

/// Authenticated, server-persisted weekday choices.
/// Recommendations are derived separately.
/// Each controller belongs to one immutable account UUID.
class WorkoutScheduleController extends ChangeNotifier {
  final String? accountId;
  final DigiGymApi _api;
  final Duration requestTimeout;

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
    DigiGymApi? api,
    this.requestTimeout = const Duration(seconds: 10),
  }) : _api = api ?? digiGymApi;

  bool get hasIdentity =>
      accountId != null &&
      RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(accountId!);

  bool get configured => _workoutDays != null;

  bool get canEdit =>
      hasIdentity &&
      _api.isAuthenticated &&
      !loading &&
      !_readFailed &&
      !saving;

  Set<int>? get workoutDays => _workoutDays;

  Future<void> initialize() => _initialization ??= _load();

  Future<void> _load() async {
    loading = true;
    error = null;
    _readFailed = false;
    _workoutDays = null;

    if (!hasIdentity || !_api.isAuthenticated) {
      loading = false;
      error = 'A signed-in account identity is needed to load a schedule.';
      _notify();
      return;
    }

    try {
      final days = await _api
          .getMyWorkoutSchedule()
          .timeout(requestTimeout);

      if (_disposed) return;

      if (days != null) {
        _validateDays(days);
        _workoutDays = Set.unmodifiable(days);
      }
    } catch (exception, stackTrace) {
      debugPrint('Workout schedule initial load failed: $exception');
      debugPrintStack(stackTrace: stackTrace);
      _readFailed = true;
      error = 'Your schedule could not be loaded. Retry to load your saved days.';
    } finally {
      loading = false;
      _notify();
    }
  }

  void _validateDays(List<int> days) {
    if (days.any((day) => day < 0 || day > 6) ||
        days.toSet().length != days.length) {
      throw const FormatException('Invalid weekdays');
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
      throw ArgumentError(
        'Weekdays must be Sunday (0) through Saturday (6).',
      );
    }

    final ordered = days.toList()..sort();

    saving = true;
    error = null;
    _notify();

    // Serialize requests even after a timeout. A delayed older save must
    // finish before a newer save is sent to the backend.
    final write = _writes.then(
      (_) => _api.updateMyWorkoutSchedule(ordered),
    );

    _writes = write.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );

    try {
      final savedDays = await write.timeout(requestTimeout);

      if (_disposed) return false;

      _validateDays(savedDays);
      _workoutDays = Set.unmodifiable(savedDays);
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
