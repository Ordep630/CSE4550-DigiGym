import 'dart:async';

import 'package:digigym/models/session.dart';
import 'package:digigym/screens/register_screen.dart';
import 'package:digigym/screens/verify_email_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

class AuthTestApi extends FakeDigiGymApi {
  int registrations = 0;
  int verifications = 0;
  Object? registrationError;
  Object? verificationError;

  @override
  Future<String> startRegistration(String email) async {
    registrations++;
    if (registrationError != null) throw registrationError!;
    return super.startRegistration(email);
  }

  @override
  Future<void> finishRegistration({
    required String requestId,
    required String verificationCode,
    required String password,
  }) async {
    verifications++;
    if (verificationError != null) throw verificationError!;
    return super.finishRegistration(
      requestId: requestId,
      verificationCode: verificationCode,
      password: password,
    );
  }
}

Finder field(String id) => find.descendant(
  of: find.byKey(ValueKey('registration-$id')),
  matching: find.byType(TextFormField),
);

TextField inputWidget(WidgetTester tester, String id) =>
    tester.widget<TextField>(
      find.descendant(of: field(id), matching: find.byType(TextField)),
    );

FormFieldState<String> fieldState(WidgetTester tester, String id) =>
    tester.state<FormFieldState<String>>(field(id));

Future<void> blurField(WidgetTester tester, String id) async {
  inputWidget(tester, id).focusNode!.unfocus();
  await tester.pumpAndSettle();
}

Future<void> fillRegistration(
  WidgetTester tester, {
  String password = 'secret12',
  String? confirmation,
}) async {
  await tester.enterText(field('name'), 'New User');
  await tester.enterText(field('email'), 'new@example.com');
  await tester.enterText(field('password'), password);
  await tester.enterText(field('confirm-password'), confirmation ?? password);
}

Future<void> submitRegistration(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'Register');
  await tester.pumpAndSettle();
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> pumpRegistration(WidgetTester tester, AuthTestApi api) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RegisterScreen(api: api),
      routes: {
        '/verify-email': (_) =>
            const Scaffold(body: Text('Verification destination')),
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'DigiGymInter',
    )..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'))).load();
  });
  setUp(DigiGymSession.clearPendingRegistration);
  tearDown(DigiGymSession.clearPendingRegistration);

  testWidgets(
    'registration opens neutral with a muted password helper and unchanged pills',
    (tester) async {
      await pumpRegistration(tester, AuthTestApi());
      for (final id in ['name', 'email', 'password', 'confirm-password']) {
        expect(fieldState(tester, id).hasError, isFalse);
        expect(tester.getSize(field(id)).height, closeTo(60, .001));
      }
      final helper = find.text('Use at least 8 characters.');
      expect(helper, findsOneWidget);
      expect(
        tester.widget<Text>(helper).style!.color,
        DigiGymDarkColors.secondaryText,
      );
      expect(find.text('Enter your name.'), findsNothing);
      expect(find.text('Enter a valid email address.'), findsNothing);
      expect(find.text('Passwords must match exactly.'), findsNothing);
      expect(
        tester.getSize(find.byType(ElevatedButton)).height,
        closeTo(60, .001),
      );
    },
  );

  testWidgets('typing Name leaves all unrelated fields neutral', (
    tester,
  ) async {
    await pumpRegistration(tester, AuthTestApi());
    await tester.enterText(field('name'), 'New User');
    await tester.pumpAndSettle();
    for (final id in ['name', 'email', 'password', 'confirm-password']) {
      expect(fieldState(tester, id).hasError, isFalse);
    }
    await blurField(tester, 'name');
    for (final id in ['name', 'email', 'password', 'confirm-password']) {
      expect(fieldState(tester, id).hasError, isFalse);
    }
    expect(
      tester.widget<Text>(find.text('Use at least 8 characters.')).style!.color,
      DigiGymDarkColors.secondaryText,
    );
  });

  testWidgets(
    'Name validates on blur and clears its error while being corrected',
    (tester) async {
      final api = AuthTestApi();
      await pumpRegistration(tester, api);
      await tester.enterText(field('name'), '   ');
      await tester.pumpAndSettle();
      expect(fieldState(tester, 'name').hasError, isFalse);
      await blurField(tester, 'name');
      expect(fieldState(tester, 'name').errorText, 'Enter your name.');
      for (final id in ['email', 'password', 'confirm-password']) {
        expect(fieldState(tester, id).hasError, isFalse);
      }
      await tester.enterText(field('name'), 'Corrected Name');
      await tester.pumpAndSettle();
      expect(fieldState(tester, 'name').hasError, isFalse);
      expect(find.text('Enter your name.'), findsNothing);
      expect(api.registrations, 0);
    },
  );

  testWidgets(
    'Email has field-specific blur validation and keeps green focus when correcting errors',
    (tester) async {
      await pumpRegistration(tester, AuthTestApi());
      await tester.enterText(field('email'), 'invalid');
      await tester.pumpAndSettle();
      expect(fieldState(tester, 'email').hasError, isFalse);
      await blurField(tester, 'email');
      expect(
        fieldState(tester, 'email').errorText,
        'Enter a valid email address.',
      );
      for (final id in ['name', 'password', 'confirm-password']) {
        expect(fieldState(tester, id).hasError, isFalse);
      }
      inputWidget(tester, 'email').focusNode!.requestFocus();
      await tester.pumpAndSettle();
      final decoration = inputWidget(tester, 'email').decoration!;
      expect(decoration.focusedErrorBorder, decoration.focusedBorder);
      await tester.enterText(field('email'), 'correct@example.com');
      await tester.pumpAndSettle();
      expect(fieldState(tester, 'email').hasError, isFalse);
      expect(fieldState(tester, 'name').hasError, isFalse);
    },
  );

  testWidgets(
    'password helper stays neutral until blur, errors clear live, and whitespace remains invalid',
    (tester) async {
      await pumpRegistration(tester, AuthTestApi());
      await tester.enterText(field('password'), 'short');
      await tester.pumpAndSettle();
      expect(fieldState(tester, 'password').hasError, isFalse);
      expect(
        tester
            .widget<Text>(find.text('Use at least 8 characters.'))
            .style!
            .color,
        DigiGymDarkColors.secondaryText,
      );
      await blurField(tester, 'password');
      expect(
        fieldState(tester, 'password').errorText,
        'Use at least 8 characters.',
      );
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      await tester.enterText(field('password'), 'secret12');
      await tester.pumpAndSettle();
      expect(fieldState(tester, 'password').hasError, isFalse);
      expect(find.text('Use at least 8 characters.'), findsNothing);
      for (final value in [' secret12', 'secret12 ']) {
        await tester.enterText(field('password'), value);
        await blurField(tester, 'password');
        expect(
          fieldState(tester, 'password').errorText,
          'Remove spaces at the start or end of your password.',
        );
        await tester.enterText(field('password'), 'secret12');
        await tester.pumpAndSettle();
        expect(fieldState(tester, 'password').hasError, isFalse);
      }
      expect(fieldState(tester, 'confirm-password').hasError, isFalse);
    },
  );

  testWidgets(
    'confirmation stays neutral when empty and validates nonempty values only after blur',
    (tester) async {
      await pumpRegistration(tester, AuthTestApi());
      await tester.enterText(field('confirm-password'), '');
      await blurField(tester, 'confirm-password');
      expect(fieldState(tester, 'confirm-password').hasError, isFalse);
      await tester.enterText(field('password'), 'secret12');
      await blurField(tester, 'password');
      await tester.enterText(field('confirm-password'), 'different');
      await tester.pumpAndSettle();
      expect(fieldState(tester, 'confirm-password').hasError, isFalse);
      await blurField(tester, 'confirm-password');
      expect(
        fieldState(tester, 'confirm-password').errorText,
        'Passwords must match exactly.',
      );
      await tester.enterText(field('confirm-password'), 'secret12');
      await tester.pumpAndSettle();
      expect(fieldState(tester, 'confirm-password').hasError, isFalse);
      expect(fieldState(tester, 'email').hasError, isFalse);
    },
  );

  testWidgets(
    'Register validates every field, focuses first error and allows live corrections before valid submission',
    (tester) async {
      final api = AuthTestApi();
      await pumpRegistration(tester, api);
      await submitRegistration(tester);
      for (final id in ['name', 'email', 'password', 'confirm-password']) {
        expect(fieldState(tester, id).hasError, isTrue);
      }
      expect(inputWidget(tester, 'name').focusNode!.hasFocus, isTrue);
      expect(api.registrations, 0);
      await fillRegistration(tester);
      await tester.pumpAndSettle();
      for (final id in ['name', 'email', 'password', 'confirm-password']) {
        expect(fieldState(tester, id).hasError, isFalse);
      }
      expect(api.registrations, 0);
      await submitRegistration(tester);
      expect(api.registrations, 1);
      expect(api.startedRegistrationEmail, 'new@example.com');
      expect(DigiGymSession.pendingRegistrationPassword, 'secret12');
      expect(find.text('Verification destination'), findsOneWidget);
    },
  );

  testWidgets(
    'password changes resolve existing matching errors but submission still catches stale confirmations',
    (tester) async {
      final api = AuthTestApi();
      await pumpRegistration(tester, api);
      await fillRegistration(
        tester,
        password: 'original12',
        confirmation: 'matching12',
      );
      await blurField(tester, 'confirm-password');
      expect(fieldState(tester, 'confirm-password').hasError, isTrue);
      await tester.enterText(field('password'), 'matching12');
      await tester.pumpAndSettle();
      expect(fieldState(tester, 'confirm-password').hasError, isFalse);
      await tester.enterText(field('password'), 'changed12');
      await submitRegistration(tester);
      expect(fieldState(tester, 'confirm-password').hasError, isTrue);
      expect(api.registrations, 0);
    },
  );

  testWidgets(
    'registration rejects missing, short, padded and mismatched passwords inline',
    (tester) async {
      final api = AuthTestApi();
      await pumpRegistration(tester, api);
      await submitRegistration(tester);
      expect(find.text('Enter your name.'), findsOneWidget);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      for (final values in [
        ('short', 'short', 'Use at least 8 characters.'),
        (
          ' secret12',
          ' secret12',
          'Remove spaces at the start or end of your password.',
        ),
        (
          'secret12 ',
          'secret12 ',
          'Remove spaces at the start or end of your password.',
        ),
        ('secret12', 'SECRET12', 'Passwords must match exactly.'),
        ('secret12', 'secret12 ', 'Passwords must match exactly.'),
      ]) {
        await fillRegistration(
          tester,
          password: values.$1,
          confirmation: values.$2,
        );
        await submitRegistration(tester);
        expect(find.text(values.$3), findsOneWidget);
        expect(api.registrations, 0);
        expect(DigiGymSession.pendingRegistrationPassword, isNull);
      }
    },
  );

  testWidgets('password visibility controls are independent and accessible', (
    tester,
  ) async {
    await pumpRegistration(tester, AuthTestApi());
    await fillRegistration(tester);
    final confirmation = field('confirm-password');
    await tester.ensureVisible(find.byTooltip('Show password'));
    await tester.tap(find.byTooltip('Show password'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(field('password')).controller!.text,
      'secret12',
    );
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: field('password'),
              matching: find.byType(TextField),
            ),
          )
          .obscureText,
      isFalse,
    );
    expect(
      tester
          .widget<TextField>(
            find.descendant(of: confirmation, matching: find.byType(TextField)),
          )
          .obscureText,
      isTrue,
    );
    await tester.ensureVisible(find.byTooltip('Show confirm password'));
    await tester.tap(find.byTooltip('Show confirm password'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hide confirm password'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets(
    'registration retains only actual password and prevents repeated keyboard submissions',
    (tester) async {
      final gate = Completer<void>();
      final api = AuthTestApi()..startRegistrationWait = gate.future;
      await pumpRegistration(tester, api);
      await fillRegistration(tester);
      final submit = tester
          .widget<TextField>(
            find.descendant(
              of: field('confirm-password'),
              matching: find.byType(TextField),
            ),
          )
          .onSubmitted!;
      submit('secret12');
      submit('secret12');
      await tester.pump();
      expect(api.registrations, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      gate.complete();
      await tester.pumpAndSettle();
      expect(api.startedRegistrationEmail, 'new@example.com');
      expect(DigiGymSession.pendingUser!.name, 'New User');
      expect(DigiGymSession.pendingRegistrationPassword, 'secret12');
      expect(DigiGymSession.registrationRequestId, api.registrationRequestId);
      expect(find.text('Verification destination'), findsOneWidget);
    },
  );

  testWidgets('registration failure can retry and Back returns to Login', (
    tester,
  ) async {
    final api = AuthTestApi()..registrationError = StateError('offline');
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => RegisterScreen(api: api),
                ),
              ),
              child: const Text('Login destination'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Login destination'));
    await tester.pumpAndSettle();
    await fillRegistration(tester);
    await submitRegistration(tester);
    expect(
      find.text('Registration failed. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(DigiGymSession.pendingRegistrationPassword, isNull);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
  });

  testWidgets(
    'verification preserves request data, submits once and clears the password',
    (tester) async {
      final gate = Completer<void>();
      final api = AuthTestApi()..finishRegistrationWait = gate.future;
      DigiGymSession.pendingUser = testUser();
      DigiGymSession.registrationRequestId = api.registrationRequestId;
      DigiGymSession.pendingRegistrationPassword = 'secret12';
      await tester.pumpWidget(
        MaterialApp(
          home: VerifyEmailScreen(api: api),
          routes: {
            '/assessment': (_) =>
                const Scaffold(body: Text('Assessment destination')),
          },
        ),
      );
      await tester.enterText(find.byType(TextField), 'a1b2c3d4');
      final submit = tester
          .widget<TextField>(find.byType(TextField))
          .onSubmitted!;
      submit('a1b2c3d4');
      submit('a1b2c3d4');
      await tester.pump();
      expect(api.verifications, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      gate.complete();
      await tester.pumpAndSettle();
      expect(api.verifiedRequestId, api.registrationRequestId);
      expect(api.verifiedCode, 'a1b2c3d4');
      expect(api.verifiedPassword, 'secret12');
      expect(DigiGymSession.pendingRegistrationPassword, isNull);
      expect(find.text('Assessment destination'), findsOneWidget);
    },
  );

  testWidgets(
    'verification errors allow retry and abandoned verification clears pending secrets',
    (tester) async {
      final api = AuthTestApi()..verificationError = StateError('wrong code');
      DigiGymSession.pendingUser = testUser();
      DigiGymSession.registrationRequestId = api.registrationRequestId;
      DigiGymSession.pendingRegistrationPassword = 'secret12';
      await tester.pumpWidget(MaterialApp(home: VerifyEmailScreen(api: api)));
      await tester.enterText(find.byType(TextField), '000000');
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Verify'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Verify'));
      await tester.pumpAndSettle();
      expect(
        find.text('Verification failed. Check the code and try again.'),
        findsOneWidget,
      );
      expect(DigiGymSession.pendingRegistrationPassword, 'secret12');
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox());
      expect(DigiGymSession.pendingRegistrationPassword, isNull);
      expect(DigiGymSession.registrationRequestId, isNull);
    },
  );

  testWidgets(
    'auth forms keep controls reachable on narrow, short, keyboard and 3x layouts',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final registration in [true, false]) {
        for (final size in [const Size(320, 568), const Size(1280 / 3, 952)]) {
          for (final scale in [1.0, 2.0, 3.0]) {
            for (final keyboard in [0.0, 280.0]) {
              tester.view.physicalSize = size;
              await tester.pumpWidget(
                MaterialApp(
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                      viewInsets: EdgeInsets.only(bottom: keyboard),
                      padding: const EdgeInsets.only(top: 52, bottom: 24),
                    ),
                    child: child!,
                  ),
                  home: registration
                      ? RegisterScreen(key: UniqueKey(), api: AuthTestApi())
                      : VerifyEmailScreen(key: UniqueKey(), api: AuthTestApi()),
                ),
              );
              await tester.pumpAndSettle();
              if (registration) {
                await fillRegistration(
                  tester,
                  password: ' secret12',
                  confirmation: 'mismatch',
                );
                await tester.pumpAndSettle();
                await submitRegistration(tester);
                expect(
                  find.text(
                    'Remove spaces at the start or end of your password.',
                  ),
                  findsOneWidget,
                );
                expect(
                  find.text('Passwords must match exactly.'),
                  findsOneWidget,
                );
              }
              for (final target in [
                find.byType(EditableText).last,
                find.byType(ElevatedButton),
              ]) {
                await tester.pumpAndSettle();
                await tester.ensureVisible(target);
                await tester.pumpAndSettle();
                final bounds = tester.getRect(target);
                expect(bounds.left, greaterThanOrEqualTo(20));
                expect(bounds.right, lessThanOrEqualTo(size.width - 20 + .001));
                expect(
                  bounds.bottom,
                  lessThanOrEqualTo(size.height - keyboard - 24 + .001),
                );
              }
              expect(
                tester.takeException(),
                isNull,
                reason: '$registration $size $scale $keyboard',
              );
            }
          }
        }
      }
    },
  );
}
