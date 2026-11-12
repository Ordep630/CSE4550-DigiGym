import 'dart:convert';
import 'dart:io';

import 'package:digigym/client.dart' as app;
import 'package:digigym/models/session.dart';
import 'package:digigym/services/digigym_api.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        EmailAccountPasswordResetException,
        EmailAccountPasswordResetExceptionReason;
import 'package:flutter_test/flutter_test.dart';

// A local HTTP test server validates the REAL generated client wire format.
// These are transport contract tests, not live Serverpod verification.
void main() {
  const api = DigiGymApi();
  const id = '123e4567-e89b-12d3-a456-426614174000';
  late HttpServer server;
  final requests = <({String path, Map<String, dynamic> body})>[];
  var status = 200;
  Object? response;
  var disconnect = false;
  setUpAll(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    app.client = Client('http://127.0.0.1:${server.port}/');
    server.listen((request) async {
      requests.add((
        path: request.uri.path,
        body: jsonDecode(
          await utf8.decoder.bind(request).join(),
        ) as Map<String, dynamic>,
      ));
      if (disconnect) {
        final socket = await request.response.detachSocket();
        socket.destroy();
        return;
      }
      request.response.statusCode = status;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        response is EmailAccountPasswordResetException
            ? Protocol().encodeWithType(response)
            : jsonEncode(response),
      );
      await request.response.close();
    });
  });
  tearDownAll(() async {
    app.client.close();
    await server.close(force: true);
  });
  setUp(() {
    requests.clear();
    status = 200;
    response = null;
    disconnect = false;
  });

  test('reset endpoints use UUID, token and password signatures without auth/session updates', () async {
    response = id;
    expect(await api.startPasswordReset('test@example.com'), id);
    expect(requests.single.path, '/emailIdp/startPasswordReset');
    expect(requests.single.body, {'email': 'test@example.com'});
    response = 'transport-test-reset-token';
    expect(
      await api.verifyPasswordResetCode(
        passwordResetRequestId: id,
        verificationCode: 'a1b2c3d4',
      ),
      response,
    );
    expect(requests.last.path, '/emailIdp/verifyPasswordResetCode');
    expect(requests.last.body, {
      'passwordResetRequestId': id,
      'verificationCode': 'a1b2c3d4',
    });
    response = null;
    await api.finishPasswordReset(
      finishPasswordResetToken: 'transport-test-reset-token',
      newPassword: 'newsecret12',
    );
    expect(requests.last.path, '/emailIdp/finishPasswordReset');
    expect(requests.last.body, {
      'finishPasswordResetToken': 'transport-test-reset-token',
      'newPassword': 'newsecret12',
    });
    expect(DigiGymSession.currentUser, isNull);
    // No JWT refresh, sign-in, profile, or storage endpoint was called.
    expect(requests.length, 3);
  });

  for (final reason in EmailAccountPasswordResetExceptionReason.values) {
    test(
      'typed Serverpod $reason is safely mapped on every recovery endpoint',
      () async {
        status = 400;
        response = EmailAccountPasswordResetException(reason: reason);
        final expected = PasswordRecoveryFailure.values.byName(
          reason == EmailAccountPasswordResetExceptionReason.unknown
              ? 'unavailable'
              : reason.name,
        );
        final matcher = throwsA(
          isA<PasswordRecoveryException>().having(
            (e) => e.reason,
            'reason',
            expected,
          ),
        );
        await expectLater(api.startPasswordReset('test@example.com'), matcher);
        await expectLater(
          api.verifyPasswordResetCode(
            passwordResetRequestId: id,
            verificationCode: '12345678',
          ),
          matcher,
        );
        await expectLater(
          api.finishPasswordReset(
            finishPasswordResetToken: 'test-token',
            newPassword: 'newsecret12',
          ),
          matcher,
        );
      },
    );
  }
  for (final code in [403, 429, 500, 503]) {
    test('HTTP $code is handled without exposing raw server data', () async {
      status = code;
      response = {'private-server-detail': 'must-not-escape'};
      await expectLater(
        api.startPasswordReset('test@example.com'),
        throwsA(
          isA<PasswordRecoveryException>().having(
            (e) => e.reason,
            'reason',
            code == 429
                ? PasswordRecoveryFailure.tooManyAttempts
                : PasswordRecoveryFailure.unavailable,
          ),
        ),
      );
    });
  }
  test(
    'interrupted network connections become safe recovery failures',
    () async {
      disconnect = true;
      await expectLater(
        api.startPasswordReset('test@example.com'),
        throwsA(
          isA<PasswordRecoveryException>().having(
            (e) => e.reason,
            'reason',
            PasswordRecoveryFailure.unavailable,
          ),
        ),
      );
    },
  );
  test('malformed reset UUID is rejected without a network request', () async {
    await expectLater(
      api.verifyPasswordResetCode(
        passwordResetRequestId: 'not-a-uuid',
        verificationCode: '12345678',
      ),
      throwsA(
        isA<PasswordRecoveryException>().having(
          (e) => e.reason,
          'reason',
          PasswordRecoveryFailure.invalid,
        ),
      ),
    );
    expect(requests, isEmpty);
  });
}
