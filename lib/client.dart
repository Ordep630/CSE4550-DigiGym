import 'package:digigym_backend_client/digigym_backend_client.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

late final Client client;

Future<void> initializeClient() async {
  client = Client('http://localhost:8080/');

  client.authSessionManager = FlutterAuthSessionManager();

  await client.auth.initialize();
}