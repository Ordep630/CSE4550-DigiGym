import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Test-only device storage; never used by the normal application.
class MemoryScheduleStorage implements KeyValueStorage {
  final values = <String, String>{};
  Object? readError;
  Object? writeError;
  Future<void>? writeWait;
  Future<void>? readWait;
  int reads = 0;
  int writes = 0;
  @override
  Future<String?> get(String key) async {
    reads++;
    await readWait;
    if (readError != null) throw readError!;
    return values[key];
  }

  @override
  Future<void> set(String key, String? value) async {
    writes++;
    await writeWait;
    if (writeError != null) throw writeError!;
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}
