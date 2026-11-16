import 'dart:async';

import 'package:digigym/models/session.dart';
import 'package:digigym/screens/forgot_password_screen.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/services/digigym_api.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

// Automated test double only. Production always uses the generated client.
class RecoveryTestApi extends FakeDigiGymApi {
  final calls = <String>[];
  String? email;
  String? requestId;
  String? code;
  String? token;
  String? password;
  Object? failure;
  Future<void>? wait;

  Future<void> _request(String step) async {
    calls.add(step);
    await wait;
    if (failure != null) throw failure!;
  }

  @override
  Future<String> startPasswordReset(String email) async {
    this.email = email;
    await _request('request');
    return registrationRequestId;
  }

  @override
  Future<String> verifyPasswordResetCode({
    required String passwordResetRequestId,
    required String verificationCode,
  }) async {
    requestId = passwordResetRequestId;
    code = verificationCode;
    await _request('verify');
    return 'automated-test-only-reset-token';
  }

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) async {
    token = finishPasswordResetToken;
    password = newPassword;
    await _request('finish');
  }
}

Finder field(String id) => find.descendant(
  of: find.byKey(ValueKey('recovery-$id')),
  matching: find.byType(TextFormField),
);
FormFieldState<String> state(WidgetTester tester, String id) =>
    tester.state<FormFieldState<String>>(field(id));
TextField input(WidgetTester tester, String id) => tester.widget<TextField>(
  find.descendant(of: field(id), matching: find.byType(TextField)),
);
Future<void> blur(WidgetTester tester, String id) async {
  input(tester, id).focusNode!.unfocus();
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, String label) async {
  final button = find.widgetWithText(ElevatedButton, label);
  await tester.pumpAndSettle();
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> pumpRecovery(WidgetTester tester, RecoveryTestApi api) async {
  await tester.pumpWidget(MaterialApp(home: ForgotPasswordScreen(api: api)));
  await tester.pumpAndSettle();
}

Future<void> toCode(WidgetTester tester, RecoveryTestApi api) async {
  await pumpRecovery(tester, api);
  await tester.enterText(field('email'), 'test@example.com');
  await tap(tester, 'Send Reset Code');
}

Future<void> toPassword(WidgetTester tester, RecoveryTestApi api) async {
  await toCode(tester, api);
  await tester.enterText(field('code'), 'a1b2c3d4');
  await tap(tester, 'Verify Code');
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'DigiGymInter',
    )..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'))).load();
  });
  tearDown(() => DigiGymSession.currentUser = null);

  testWidgets(
    'initial screen is neutral, branded and validates email before API',
    (tester) async {
      final api = RecoveryTestApi();
      await pumpRecovery(tester, api);
      expect(state(tester, 'email').hasError, isFalse);
      expect(
        Theme.of(tester.element(field('email'))).brightness,
        Brightness.dark,
      );
      for (final value in ['', 'invalid', 'a@b', 'a b@example.com']) {
        await tester.enterText(field('email'), value);
        await tap(tester, 'Send Reset Code');
        expect(find.text('Enter a valid email address.'), findsOneWidget);
        expect(api.calls, isEmpty);
      }
      await tester.enterText(field('email'), ' test@example.com ');
      await tester.pumpAndSettle();
      expect(state(tester, 'email').hasError, isFalse);
      await tap(tester, 'Send Reset Code');
      expect(api.email, 'test@example.com');
      expect(find.text('Verify Reset Code'), findsOneWidget);
      expect(find.textContaining('Delivery is not confirmed'), findsOneWidget);
    },
  );

  for (final step in ['request', 'verify', 'finish']) {
    testWidgets(
      '$step is single-flight, disables controls and handles abandonment while pending',
      (tester) async {
        final api = RecoveryTestApi();
        if (step == 'request') {
          await pumpRecovery(tester, api);
          await tester.enterText(field('email'), 'test@example.com');
        } else if (step == 'verify') {
          await toCode(tester, api);
          await tester.enterText(field('code'), '12345678');
        } else {
          await toPassword(tester, api);
          await tester.enterText(field('password'), 'newsecret12');
          await tester.enterText(field('confirmation'), 'newsecret12');
        }
        final gate = Completer<void>();
        api.wait = gate.future;
        final submitted = tester
            .widget<TextField>(find.byType(TextField).last)
            .onSubmitted!;
        submitted('');
        submitted('');
        await tester.pump();
        expect(api.calls.where((v) => v == step).length, 1);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );
        expect(
          tester
              .widgetList<TextField>(find.byType(TextField))
              .every((v) => v.readOnly),
          isTrue,
        );
        await tester.pumpWidget(const SizedBox());
        gate.complete();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(api.authenticated, isFalse);
        expect(api.signOutCalls, 0);
      },
    );
  }

  testWidgets(
    'alphanumeric code is supported, empty and invalid codes cannot advance',
    (tester) async {
      final api = RecoveryTestApi();
      await toCode(tester, api);
      await tap(tester, 'Verify Code');
      expect(api.calls, ['request']);
      expect(input(tester, 'code').keyboardType, TextInputType.text);
      api.failure = const PasswordRecoveryException(
        PasswordRecoveryFailure.invalid,
      );
      await tester.enterText(field('code'), 'wrong-code');
      await tap(tester, 'Verify Code');
      expect(
        find.textContaining('code or reset request is invalid'),
        findsOneWidget,
      );
      expect(find.text('Verify Reset Code'), findsOneWidget);
      api.failure = null;
      await tester.enterText(field('code'), 'a1b2c3d4');
      final codeController = input(tester, 'code').controller!;
      await tap(tester, 'Verify Code');
      expect(api.requestId, api.registrationRequestId);
      expect(api.code, 'a1b2c3d4');
      expect(codeController.text, isEmpty);
      expect(find.text('New Password'), findsWidgets);
    },
  );

  testWidgets(
    'new password validation is progressive and confirmation stays neutral until edited',
    (tester) async {
      final api = RecoveryTestApi();
      await toPassword(tester, api);
      expect(state(tester, 'password').hasError, isFalse);
      expect(state(tester, 'confirmation').hasError, isFalse);
      expect(
        tester
            .widget<Text>(find.text('Use at least 8 characters.'))
            .style!
            .color,
        DigiGymDarkColors.secondaryText,
      );
      await tester.enterText(field('password'), 'short');
      await tester.pumpAndSettle();
      expect(state(tester, 'password').hasError, isFalse);
      expect(state(tester, 'confirmation').hasError, isFalse);
      await blur(tester, 'password');
      expect(state(tester, 'password').hasError, isTrue);
      await tester.enterText(field('password'), 'newsecret12');
      await tester.pumpAndSettle();
      expect(state(tester, 'password').hasError, isFalse);
      expect(find.text('Use at least 8 characters.'), findsNothing);
      await tester.enterText(field('confirmation'), '');
      await blur(tester, 'confirmation');
      expect(state(tester, 'confirmation').hasError, isFalse);
      await tester.enterText(field('confirmation'), 'different');
      await tester.pumpAndSettle();
      expect(state(tester, 'confirmation').hasError, isFalse);
      await blur(tester, 'confirmation');
      expect(state(tester, 'confirmation').hasError, isTrue);
      await tester.enterText(field('confirmation'), 'newsecret12');
      await tester.pumpAndSettle();
      expect(state(tester, 'confirmation').hasError, isFalse);
      expect(api.calls, ['request', 'verify']);
    },
  );

  testWidgets(
    'password policy and exact confirmation block completion; visibility is independent',
    (tester) async {
      final api = RecoveryTestApi();
      await toPassword(tester, api);
      for (final values in [
        ('', ''),
        ('short', 'short'),
        (' newsecret12', ' newsecret12'),
        ('newsecret12 ', 'newsecret12 '),
        ('newsecret12', 'NEWSECRET12'),
      ]) {
        await tester.enterText(field('password'), values.$1);
        await tester.enterText(field('confirmation'), values.$2);
        await tap(tester, 'Update Password');
        expect(api.calls, ['request', 'verify']);
      }
      await tester.ensureVisible(find.byTooltip('Show new password'));
      await tester.tap(find.byTooltip('Show new password'));
      await tester.pumpAndSettle();
      expect(input(tester, 'password').obscureText, isFalse);
      expect(input(tester, 'confirmation').obscureText, isTrue);
      await tester.ensureVisible(find.byTooltip('Show confirm new password'));
      await tester.tap(find.byTooltip('Show confirm new password'));
      await tester.pumpAndSettle();
      expect(input(tester, 'confirmation').obscureText, isFalse);
    },
  );

  for (final stage in ['request', 'verify', 'finish']) {
    for (final reason in PasswordRecoveryFailure.values) {
      testWidgets(
        '$stage handles $reason without exposing account data and supports retry/restart',
        (tester) async {
          final api = RecoveryTestApi();
          String label;
          if (stage == 'request') {
            await pumpRecovery(tester, api);
            await tester.enterText(field('email'), 'test@example.com');
            label = 'Send Reset Code';
          } else if (stage == 'verify') {
            await toCode(tester, api);
            await tester.enterText(field('code'), '12345678');
            label = 'Verify Code';
          } else {
            await toPassword(tester, api);
            await tester.enterText(field('password'), 'newsecret12');
            await tester.enterText(field('confirmation'), 'newsecret12');
            label = 'Update Password';
          }
          api.failure = PasswordRecoveryException(reason);
          await tap(tester, label);
          expect(find.byKey(const ValueKey('recovery-error')), findsOneWidget);
          expect(find.text('Password Updated'), findsNothing);
          expect(api.authenticated, isFalse);
          expect(api.signOutCalls, 0);
          api.failure = null;
          if (find.text('Forgot Password?').evaluate().isNotEmpty) {
            await tap(tester, 'Send Reset Code');
            expect(find.text('Verify Reset Code'), findsOneWidget);
          } else {
            await tap(tester, label);
            expect(find.byKey(const ValueKey('recovery-error')), findsNothing);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'successful recovery clears secret controllers, leaves session intact and returns to Login',
    (tester) async {
      final api = RecoveryTestApi()..authenticated = true;
      final existingUser = testUser();
      DigiGymSession.currentUser = existingUser;
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            api: api,
            onLogin: (_) => fail('Recovery must not log in'),
          ),
        ),
      );
      final recovery = find.widgetWithText(TextButton, 'Forgot Password?');
      await tester.ensureVisible(recovery);
      await tester.pumpAndSettle();
      await tester.tap(recovery);
      await tester.pumpAndSettle();
      await tester.enterText(field('email'), 'test@example.com');
      await tap(tester, 'Send Reset Code');
      await tester.enterText(field('code'), '12345678');
      await tap(tester, 'Verify Code');
      await tester.enterText(field('password'), 'newsecret12');
      await tester.enterText(field('confirmation'), 'newsecret12');
      final controllers = [
        input(tester, 'password').controller!,
        input(tester, 'confirmation').controller!,
      ];
      await tap(tester, 'Update Password');
      expect(api.token, 'automated-test-only-reset-token');
      expect(api.password, 'newsecret12');
      expect(api.calls, ['request', 'verify', 'finish']);
      expect(controllers.every((c) => c.text.isEmpty), isTrue);
      expect(find.text('Password Updated'), findsOneWidget);
      expect(find.textContaining('You can now log in'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(DigiGymSession.currentUser, same(existingUser));
      expect(api.authenticated, isTrue);
      expect(api.signOutCalls, 0);
      await tap(tester, 'Back to Login');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ForgotPasswordScreen), findsNothing);
    },
  );

  testWidgets(
    'requesting another code removes old passwords and validates the new request separately',
    (tester) async {
      final api = RecoveryTestApi();
      await toPassword(tester, api);
      await tester.enterText(field('password'), 'discardme12');
      final password = input(tester, 'password').controller!;
      final restart = find.widgetWithText(TextButton, 'Request a new code');
      await tester.ensureVisible(restart);
      await tester.pumpAndSettle();
      await tester.tap(restart);
      await tester.pumpAndSettle();
      expect(password.text, isEmpty);
      expect(find.text('Forgot Password?'), findsOneWidget);
      await tap(tester, 'Send Reset Code');
      expect(api.calls, ['request', 'verify', 'request']);
    },
  );

  testWidgets(
    'every step stays usable on narrow phones with keyboards and text through 3x',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final size in [const Size(320, 568), const Size(1280 / 3, 952)]) {
        tester.view.physicalSize = size;
        for (final scale in [1.0, 2.0, 3.0]) {
          for (final keyboard in [0.0, 280.0]) {
            final api = RecoveryTestApi();
            await tester.pumpWidget(
              MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: const EdgeInsets.only(top: 52, bottom: 24),
                    viewInsets: EdgeInsets.only(bottom: keyboard),
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child!,
                ),
                home: ForgotPasswordScreen(key: UniqueKey(), api: api),
              ),
            );
            await tester.pumpAndSettle();
            for (final label in [
              'Send Reset Code',
              'Verify Code',
              'Update Password',
              'Back to Login',
            ]) {
              if (label == 'Send Reset Code') {
                await tester.enterText(field('email'), 'test@example.com');
              }
              if (label == 'Verify Code') {
                await tester.enterText(field('code'), 'a1b2c3d4');
              }
              if (label == 'Update Password') {
                await tester.enterText(field('password'), 'newsecret12');
                await tester.enterText(field('confirmation'), 'newsecret12');
              }
              final action = find.widgetWithText(ElevatedButton, label);
              await tester.pumpAndSettle();
              await tester.ensureVisible(action);
              await tester.pumpAndSettle();
              final bounds = tester.getRect(action);
              expect(bounds.left, greaterThanOrEqualTo(20));
              expect(bounds.right, lessThanOrEqualTo(size.width - 20 + .001));
              expect(
                bounds.bottom,
                lessThanOrEqualTo(size.height - keyboard - 24 + .001),
                reason: '$size $scale $keyboard $label $bounds',
              );
              if (label != 'Back to Login') await tap(tester, label);
              expect(
                tester.takeException(),
                isNull,
                reason: '$size $scale $keyboard $label',
              );
            }
          }
        }
      }
    },
  );

  testWidgets('recovery controls meet Android touch target guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final api = RecoveryTestApi();
    await toPassword(tester, api);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });
}
