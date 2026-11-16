import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    show FlutterSecureKeyValueStorage, KeyValueStorage;

/// Device-local opt-out for one authenticated account.
class WorkoutStartPreference {
  final String _key;
  final KeyValueStorage _storage;
  Future<void> _writes = Future.value();

  WorkoutStartPreference({required String accountId, KeyValueStorage? storage})
    : _key = 'digigym.workout.confirmStart.v1.$accountId',
      _storage = storage ?? FlutterSecureKeyValueStorage(null);

  Future<bool> confirmationEnabled() async {
    try {
      final value = await _writes
          .then((_) => _storage.get(_key))
          .timeout(const Duration(seconds: 1));
      return value != 'skip';
    } catch (_) {
      return true;
    }
  }

  Future<void> setConfirmationEnabled(bool enabled) {
    final write = _writes.then(
      (_) => _storage.set(_key, enabled ? null : 'skip'),
    );
    _writes = write.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return write;
  }
}
