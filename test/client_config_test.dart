import 'package:digigym/client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeServerUrl', () {
    test('preserves the default iOS simulator and desktop URL', () {
      expect(normalizeServerUrl(defaultServerUrl), defaultServerUrl);
    });

    test('supports Android emulator and physical-device URLs', () {
      expect(
        normalizeServerUrl('http://10.0.2.2:8080'),
        'http://10.0.2.2:8080/',
      );
      expect(
        normalizeServerUrl('http://192.168.1.20:8080/'),
        'http://192.168.1.20:8080/',
      );
    });

    test('accepts HTTPS and rejects incomplete URLs', () {
      expect(
        normalizeServerUrl('https://api.example.com'),
        'https://api.example.com/',
      );
      expect(() => normalizeServerUrl('localhost:8080'), throwsArgumentError);
      expect(
        () => normalizeServerUrl('ftp://example.com'),
        throwsArgumentError,
      );
    });
  });
}
