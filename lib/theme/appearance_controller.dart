import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Device-local preference, deliberately independent of login/profile storage.
class AppearanceController extends ChangeNotifier {
  static const storageKey = 'digigym.appearance.v1';
  final KeyValueStorage _storage;
  final Duration storageTimeout;
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  bool _initialized = false;
  bool get initialized => _initialized;
  bool _dirty = false;
  bool get hasPersistenceError => _dirty;
  bool _disposed = false;
  int _revision = 0;
  Future<void>? _initialization;
  Future<void> _writes = Future.value();

  AppearanceController({
    KeyValueStorage? storage,
    this.storageTimeout = const Duration(seconds: 1),
  }) : _storage = storage ?? FlutterSecureKeyValueStorage(null);

  Future<void> initialize() => _initialization ??= _load();

  Future<void> _load() async {
    final revision = _revision;
    try {
      final value = await _storage.get(storageKey).timeout(storageTimeout);
      // A slow restore must never replace a more recent explicit selection.
      if (revision == _revision) {
        _mode = ThemeMode.values.firstWhere(
          (mode) => mode.name == value,
          orElse: () => ThemeMode.dark,
        );
      }
    } catch (_) {
      // Unsupported/unavailable storage cannot block authentication or startup.
    }
    _initialized = true;
    _notify();
  }

  Future<void> select(ThemeMode mode) {
    _mode = mode;
    _revision++;
    _notify();
    return _persist();
  }

  Future<void> _persist() {
    final revision = _revision;
    final snapshot = _mode.name;
    // Serialize writes so rapid taps cannot restore an older preference.
    _writes = _writes.then((_) async {
      try {
        await _storage.set(storageKey, snapshot);
        if (revision == _revision) _dirty = false;
      } catch (_) {
        if (revision == _revision) _dirty = true;
      }
      _notify();
    });
    return flush();
  }

  Future<void> retryPersistence() => _dirty ? _persist() : flush();

  Future<void> flush() => _writes.timeout(storageTimeout, onTimeout: () {});

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class AppearanceScope extends InheritedNotifier<AppearanceController> {
  const AppearanceScope({
    super.key,
    required AppearanceController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppearanceController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppearanceScope>()?.notifier;
}
