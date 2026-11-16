import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout;
import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    show FlutterSecureKeyValueStorage, KeyValueStorage;

import '../models/workout_plan.dart';
import '../models/workout_record_details.dart';
import 'digigym_api.dart';

enum WorkoutSessionPhase { running, paused, saving, unconfirmed, saved }

/// One session and history view per signed-in app shell. Timers only refresh
/// the presentation and checkpoint storage. The monotonic clock measures time.
class WorkoutSessionController extends ChangeNotifier {
  final String accountId;
  final DigiGymApi api;
  final KeyValueStorage _storage;
  final Duration Function() _monotonicNow;
  final VoidCallback? onStreakUpdated;
  final ValueNotifier<List<CompletedWorkout>> _history = ValueNotifier(
    const [],
  );
  ValueListenable<List<CompletedWorkout>> get history => _history;

  WorkoutSessionController({
    required this.accountId,
    required this.api,
    KeyValueStorage? storage,
    Duration Function()? monotonicNow,
    this.onStreakUpdated,
  }) : _storage = storage ?? FlutterSecureKeyValueStorage(null),
       _monotonicNow = monotonicNow ?? _stopwatchClock();

  static Duration Function() _stopwatchClock() {
    final watch = Stopwatch()..start();
    return () => watch.elapsed;
  }

  String get _key => 'digigym.workout.session.v1.$accountId';
  bool get _authorized => !_closed && api.authenticatedAccountId == accountId;
  bool _closed = false;
  bool _ready = false;
  bool get ready => _ready;
  bool _storageFailed = false;
  bool get storageFailed => _storageFailed;
  bool _busy = false;
  bool get busy => _busy;
  Future<void>? _initialization;
  Future<void> _writes = Future.value();
  Timer? _ticker;
  int _historyRevision = 0;

  String? _id;
  String? _title;
  String? get title => _title;
  WorkoutSessionPhase? _phase;
  WorkoutSessionPhase? get phase => _phase;
  bool _timed = false;
  bool get timed => _timed;
  int _plannedMinutes = 0;
  int _plannedSeconds = 0;
  Duration get planned => Duration(seconds: _plannedSeconds);
  List<WorkoutExerciseDetails> _exercises = const [];
  List<WorkoutExerciseDetails> get exercises => _exercises;
  Duration _accumulated = Duration.zero;
  Duration? _segmentStart;
  DateTime? _savedAt;
  bool _streakPending = false;
  bool get streakPending => _streakPending;

  Duration get elapsed {
    final start = _segmentStart;
    return _accumulated +
        (start == null ? Duration.zero : _monotonicNow() - start);
  }

  bool get canStart =>
      _ready &&
      _authorized &&
      !_busy &&
      (_phase == null ||
          (_phase == WorkoutSessionPhase.saved && !_streakPending));

  bool get canDiscard => !_busy && _phase != null;

  Future<void> initialize() => _initialization ??= _restore();

  Future<void> retryStorage() async {
    if (!_ready) {
      _initialization = null;
      await initialize();
    } else {
      await _persist();
    }
  }

  Future<void> _restore() async {
    try {
      final value = await _storage.get(_key);
      if (_closed) return;
      if (value != null) _readDraft(jsonDecode(value));
      _ready = true;
      _storageFailed = false;
    } catch (_) {
      _storageFailed = true;
    }
    _changed();
  }

  void _readDraft(Object? value) {
    if (value is! Map) throw const FormatException('Invalid workout session');
    final details = WorkoutRecordDetails.fromJson(value['details']);
    final id = details.sessionId;
    final planned = details.plannedSeconds;
    final title = value['title'];
    final minutes = value['plannedMinutes'];
    final phase = value['phase'];
    final timed = value['timed'];
    if (id == null ||
        planned == null ||
        title is! String ||
        minutes is! int ||
        minutes < 1 ||
        timed is! bool) {
      throw const FormatException('Invalid workout session');
    }
    final restoredPhase = switch (phase) {
      'running' || 'paused' => WorkoutSessionPhase.paused,
      'saving' || 'unconfirmed' => WorkoutSessionPhase.unconfirmed,
      'saved' => WorkoutSessionPhase.saved,
      _ => throw const FormatException('Invalid workout state'),
    };
    final savedAt = value['savedAt'];
    final completed = savedAt is String ? DateTime.tryParse(savedAt) : null;
    if (restoredPhase == WorkoutSessionPhase.saved && completed == null) {
      throw const FormatException('Invalid workout receipt');
    }
    _id = id;
    _title = title;
    _plannedSeconds = planned;
    _plannedMinutes = minutes;
    _timed = timed;
    _exercises = details.exercises;
    _accumulated = details.activeTime ?? Duration.zero;
    _phase = restoredPhase;
    _savedAt = completed;
    _streakPending = restoredPhase == WorkoutSessionPhase.saved;
  }

  WorkoutRecordDetails _details() => WorkoutRecordDetails(
    sessionId: _id,
    activeTime: _timed ? elapsed : null,
    plannedSeconds: _plannedSeconds,
    exercises: _exercises,
  );

  Future<bool> _persist() {
    final phase = _phase;
    final data =
        phase == null || (phase == WorkoutSessionPhase.saved && !_streakPending)
        ? null
        : jsonEncode({
            'title': _title,
            'phase': phase.name,
            'timed': _timed,
            'plannedMinutes': _plannedMinutes,
            'savedAt': _savedAt?.toUtc().toIso8601String(),
            'details': _details().toJson(),
          });
    final writing = _writes.then((_) async {
      try {
        await _storage.set(_key, data);
        _setStorageFailed(false);
        return true;
      } catch (_) {
        _setStorageFailed(true);
        return false;
      }
    });
    _writes = writing.then((_) {});
    return writing;
  }

  void _setStorageFailed(bool value) {
    if (_storageFailed == value || _closed) return;
    _storageFailed = value;
    _changed();
  }

  void _changed() {
    if (!_closed) notifyListeners();
  }

  void _prepare(WorkoutPlan plan, {required bool timed}) {
    final random = Random.secure();
    _id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    _title = plan.title;
    _plannedMinutes = plan.durationMinutes;
    _plannedSeconds = plan.estimatedSeconds;
    _exercises = WorkoutRecordDetails.snapshot(plan);
    _timed = timed;
    _accumulated = Duration.zero;
    _savedAt = null;
    _streakPending = false;
    _phase = WorkoutSessionPhase.paused;
  }

  bool _canUse(WorkoutPlan plan) =>
      canStart &&
      !plan.isRecovery &&
      plan.exercises.isNotEmpty &&
      plan.estimatedSeconds > 0;

  void start(WorkoutPlan plan) {
    if (!_canUse(plan)) return;
    _prepare(plan, timed: true);
    resume();
  }

  void resume() {
    if (!_authorized ||
        _busy ||
        !_timed ||
        _phase != WorkoutSessionPhase.paused) {
      return;
    }
    _phase = WorkoutSessionPhase.running;
    _segmentStart = _monotonicNow();
    _startTicker();
    _changed();
    unawaited(_persist());
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _changed();
      if (timer.tick % 5 == 0) unawaited(_persist());
    });
  }

  void _stopClock() {
    _accumulated = elapsed;
    _segmentStart = null;
    _ticker?.cancel();
    _ticker = null;
  }

  void pause() {
    if (_phase != WorkoutSessionPhase.running) return;
    _stopClock();
    _phase = WorkoutSessionPhase.paused;
    _changed();
    unawaited(_persist());
  }

  /// The in-process clock keeps running if the OS suspends the UI. If the
  /// process is killed, only the last checkpoint can be trusted.
  void foregroundChanged({required bool foreground}) {
    if (_phase != WorkoutSessionPhase.running) return;
    if (foreground) {
      _startTicker();
      _changed();
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
    unawaited(_persist());
  }

  Future<bool> discard() async {
    if (!canDiscard || !_authorized) return false;
    _busy = true;
    _stopClock();
    final previous = _phase;
    _phase = null;
    _changed();
    final removed = await _persist();
    if (!_closed) {
      if (!removed) {
        _phase = previous == WorkoutSessionPhase.running
            ? WorkoutSessionPhase.paused
            : previous;
      }
      _busy = false;
      _changed();
    }
    return removed;
  }

  /// Retains untimed completion from the existing exercise preview.
  Future<void> markCompleted(WorkoutPlan plan) async {
    if (!_canUse(plan)) return;
    _prepare(plan, timed: false);
    await finish();
  }

  Future<void> finish() async {
    if (!_authorized ||
        _busy ||
        (_phase != WorkoutSessionPhase.running &&
            _phase != WorkoutSessionPhase.paused)) {
      return;
    }
    _stopClock();
    _phase = WorkoutSessionPhase.saving;
    _busy = true;
    _changed();

    // Never dispatch unless a process restart can see the outstanding save.
    if (!await _persist()) {
      _phase = WorkoutSessionPhase.paused;
      _busy = false;
      _changed();
      return;
    }
    if (!_authorized) return;

    CompletedWorkout receipt;
    try {
      receipt = await api
          .completeWorkout(
            workoutName: _title!,
            durationMinutes: _plannedMinutes,
            details: jsonEncode(_details().toJson()),
          )
          .timeout(const Duration(seconds: 25));
      if (!_authorized) return;
      if (receipt.authUserId.toString() != accountId) {
        throw StateError('Completion receipt belongs to another account');
      }
    } catch (_) {
      if (!_closed) {
        _phase = WorkoutSessionPhase.unconfirmed;
        _busy = false;
        _changed();
      }
      return;
    }
    await _confirm(receipt);
  }

  /// A lost reply may already have committed. Read history to reconcile the
  /// session ID and never send a second completion request for that session.
  Future<void> checkSave() async {
    if (!_authorized || _busy || _phase != WorkoutSessionPhase.unconfirmed) {
      return;
    }
    _busy = true;
    _changed();
    CompletedWorkout? receipt;
    try {
      final rows = await fetchHistory();
      for (final row in rows) {
        if (WorkoutRecordDetails.decode(row.details).sessionId == _id) {
          receipt = row;
          break;
        }
      }
    } catch (_) {
      // Keep the honest unconfirmed state so the user can check again.
    }
    if (!_authorized) return;
    if (receipt == null) {
      _busy = false;
      _changed();
    } else {
      await _confirm(receipt);
    }
  }

  Future<void> _confirm(CompletedWorkout receipt) async {
    _savedAt = receipt.completedAt;
    _phase = WorkoutSessionPhase.saved;
    _streakPending = true;
    ++_historyRevision;
    _history.value = List.unmodifiable(
      [receipt, ..._history.value.where((row) => row.id != receipt.id)]
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt)),
    );
    _changed();
    await _persist();
    await _writeStreak();
  }

  Future<void> retryStreak() async {
    if (!_authorized || _busy || !_streakPending) return;
    _busy = true;
    _changed();
    await _writeStreak();
  }

  Future<void> _writeStreak() async {
    if (!_authorized) return;
    try {
      await api.recordWorkoutCompletion(_savedAt!);
      if (!_authorized) return;
      _streakPending = false;
      onStreakUpdated?.call();
      await _persist();
    } catch (_) {
      // The receipt is still confirmed and the local retry survives restart.
    }
    if (!_closed) {
      _busy = false;
      _changed();
    }
  }

  Future<List<CompletedWorkout>> fetchHistory() async {
    if (!_authorized) return const [];
    final request = ++_historyRevision;
    final rows = (await api.getWorkoutHistory())
        .where((row) => row.authUserId.toString() == accountId)
        .toList(growable: false);
    if (!_authorized) return const [];
    if (request == _historyRevision) _history.value = List.unmodifiable(rows);
    return rows;
  }

  Future<void> refreshHistory() async {
    try {
      await fetchHistory();
    } catch (_) {
      // Keep the last confirmed calendar. History shows its own load errors.
    }
  }

  Future<int> deleteHistory(List<int> ids) async {
    if (!_authorized) return 0;
    final deleted = await api.deleteWorkoutHistory(ids);
    if (!_authorized) return 0;
    if (deleted == ids.toSet().length) {
      ++_historyRevision;
      _history.value = List.unmodifiable(
        _history.value.where((row) => !ids.contains(row.id)),
      );
    }
    await refreshHistory();
    return deleted;
  }

  Future<void> prepareLogout() async {
    if (_phase == WorkoutSessionPhase.running) {
      _stopClock();
      _phase = WorkoutSessionPhase.paused;
      _changed();
      await _persist();
    } else {
      await _writes;
    }
  }

  @override
  void dispose() {
    _closed = true;
    if (_phase == WorkoutSessionPhase.running) {
      _stopClock();
      _phase = WorkoutSessionPhase.paused;
      unawaited(_persist());
    }
    _ticker?.cancel();
    _history.dispose();
    super.dispose();
  }
}
