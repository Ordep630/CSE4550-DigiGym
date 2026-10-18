import 'package:digigym_backend_client/digigym_backend_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

late final Client client;

const defaultServerUrl = 'http://localhost:8080/';

String normalizeServerUrl(String value) {
  final normalized = value.trim();
  final uri = Uri.tryParse(normalized);

  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    throw ArgumentError.value(
      value,
      'SERVER_URL',
      'Use a complete HTTP or HTTPS URL.',
    );
  }

  return normalized.endsWith('/') ? normalized : '$normalized/';
}

Future<void> initializeClient() async {
  const configuredServerUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: defaultServerUrl,
  );
  final serverUrl = normalizeServerUrl(configuredServerUrl);

  client = Client(serverUrl);

  client.authSessionManager = FlutterAuthSessionManager();

  await client.auth.initialize();
}
