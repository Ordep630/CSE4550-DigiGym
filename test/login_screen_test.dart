import 'dart:async';
import 'dart:ui' as ui;

import 'package:digigym/models/session.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/login_screen.dart';
import 'package:digigym/screens/register_screen.dart';
import 'package:digigym/services/digigym_api.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

class _CountingApi extends FakeDigiGymApi {
  int loginCalls = 0;

  @override
  Future<UserProfile> login({required String email, required String password}) {
    loginCalls++;
    return super.login(email: email, password: password);
  }
}

final email = find.byKey(const ValueKey('login-email'));
final password = find.byKey(const ValueKey('login-password'));
final loginButton = find.widgetWithText(ElevatedButton, 'Login');

Future<void> pumpLogin(
  WidgetTester tester, {
  Size size = const Size(1280 / 3, 952),
  double scale = 1,
  double keyboard = 0,
  DigiGymApi? api,
  ValueChanged<UserProfile>? onLogin,
}) async {
  tester.view.physicalSize = size;
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: const EdgeInsets.only(top: 52, bottom: 24),
          viewInsets: EdgeInsets.only(bottom: keyboard),
          textScaler: TextScaler.linear(scale),
        ),
        child: child!,
      ),
      home: LoginScreen(
        api: api ?? FakeDigiGymApi(),
        onLogin: onLogin ?? (_) {},
      ),
      routes: {
        '/assessment': (_) =>
            const Scaffold(body: Text('Assessment destination')),
      },
    ),
  );
  await tester.runAsync(() async {
    for (final asset in [
      'assets/images/digigym_workout_icon.png',
      'assets/images/digigym_wordmark.png',
    ]) {
      await precacheImage(AssetImage(asset), tester.element(email));
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      DigiGymDashboardTheme.textFont,
    )..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'))).load();
  });

  setUp(() {
    DigiGymSession.currentUser = null;
    DigiGymSession.clearPendingRegistration();
  });

  tearDown(() {
    DigiGymSession.currentUser = null;
    DigiGymSession.clearPendingRegistration();
  });

  testWidgets('official artwork is stacked, untinted, sharp and phone sized', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await pumpLogin(tester);
    final dumbbell = find.byKey(const ValueKey('login-dumbbell'));
    final wordmark = find.byKey(const ValueKey('login-wordmark'));
    for (final artwork in [dumbbell, wordmark]) {
      final image = tester.widget<Image>(artwork);
      expect(image.filterQuality, FilterQuality.none);
      expect(image.color, isNull);
      expect(image.fit, BoxFit.contain);
      expect(tester.getRect(artwork).center.dx, closeTo(1280 / 6, .001));
    }
    final dumbbellBounds = tester.getRect(dumbbell);
    final wordmarkBounds = tester.getRect(wordmark);
    expect(dumbbellBounds.width, closeTo(180, .001));
    expect(
      dumbbellBounds.width / dumbbellBounds.height,
      closeTo(796 / 331, .001),
    );
    expect(
      wordmarkBounds.width / wordmarkBounds.height,
      closeTo(862 / 189, .001),
    );
    expect(wordmarkBounds.top - dumbbellBounds.bottom, closeTo(18, .001));
    expect(dumbbellBounds.top, inInclusiveRange(160, 200));
    expect(tester.getRect(email).top - wordmarkBounds.bottom, greaterThan(100));
    expect(find.text('Your personal fitness companion'), findsNothing);
    expect(find.text('Welcome Back'), findsNothing);
    expect(find.byIcon(Icons.fitness_center), findsNothing);
    expect(find.text('Demo Login'), findsOneWidget);
    expect(find.text('demo@gym.com'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
    expect(find.text('or'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .maxScrollExtent,
      0,
    );
    expect(
      tester.getRect(find.widgetWithText(TextButton, 'Sign Up')).bottom,
      lessThanOrEqualTo(928),
    );
    final theme = Theme.of(tester.element(email));
    expect(theme.brightness, Brightness.dark);
    expect(
      theme.textTheme.bodyMedium!.fontFamily,
      DigiGymDashboardTheme.textFont,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('glass fields and primary button keep matching bounds on focus', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await pumpLogin(tester);
    final emailBefore = tester.getRect(email);
    final passwordBefore = tester.getRect(password);
    expect(emailBefore.width, closeTo(passwordBefore.width, .001));
    expect(emailBefore.height, closeTo(passwordBefore.height, .001));
    expect(emailBefore.height, closeTo(64, .001));
    expect(tester.getRect(loginButton).width, closeTo(emailBefore.width, .001));
    expect(tester.getRect(loginButton).height, closeTo(64, .001));
    for (final input in [email, password]) {
      final decoration = find.descendant(
        of: input,
        matching: find.byType(InputDecorator),
      );
      expect(
        tester.getRect(decoration),
        rectMoreOrLessEquals(tester.getRect(input), epsilon: .001),
      );
    }
    expect(find.byType(BackdropFilter), findsNWidgets(2));
    for (final blur in tester.widgetList<BackdropFilter>(
      find.byType(BackdropFilter),
    )) {
      expect(blur.filter, ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8));
    }
    for (final input in [email, password]) {
      final field = tester.widget<TextField>(input);
      expect(field.decoration!.filled, isFalse);
      final border = field.decoration!.enabledBorder! as OutlineInputBorder;
      final focused = field.decoration!.focusedBorder! as OutlineInputBorder;
      expect(border.borderRadius.topLeft.x, greaterThanOrEqualTo(32));
      expect(border.borderSide.width, 1);
      expect(focused.borderSide.width, 1);
      expect(
        focused.borderSide.color,
        DigiGymDarkColors.electricGreen.withValues(alpha: .55),
      );
    }
    await tester.tap(email);
    await tester.pumpAndSettle();
    expect(tester.getRect(email), emailBefore);
    expect(tester.getRect(password), passwordBefore);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password visibility and accessible controls preserve input', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await pumpLogin(tester);
    final semantics = tester.ensureSemantics();
    try {
      await tester.enterText(password, 'unchanged password');
      expect(tester.widget<TextField>(password).obscureText, isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(password).obscureText, isFalse);
      expect(
        tester.widget<TextField>(password).controller!.text,
        'unchanged password',
      );
      await tester.tap(find.byTooltip('Hide password'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(password).obscureText, isTrue);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('recovery placeholder is accessible and never starts auth', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final api = _CountingApi();
    await pumpLogin(tester, api: api);
    final recovery = find.widgetWithText(TextButton, 'Forgot Password?');
    final bounds = tester.getRect(recovery);
    expect(bounds.height, greaterThanOrEqualTo(48));
    expect(bounds.width, greaterThanOrEqualTo(48));
    expect(bounds.right, closeTo(tester.getRect(password).right, .001));
    expect(bounds.top, closeTo(tester.getRect(password).bottom, .001));
    expect(tester.getRect(loginButton).top - bounds.bottom, closeTo(4, .001));
    final style = tester.widget<TextButton>(recovery).style!;
    expect(style.foregroundColor!.resolve({}), DigiGymDarkColors.secondaryText);
    final semantics = tester.ensureSemantics();
    try {
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await tester.tap(recovery);
      await tester.pumpAndSettle();
      expect(find.text('Password recovery is coming soon.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(RegisterScreen), findsNothing);
      expect(api.loginCalls, 0);
      expect(DigiGymSession.currentUser, isNull);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('login gradient uses softer brand greens with readable text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await pumpLogin(tester);
    final surface = tester.widget<DecoratedBox>(
      find.ancestor(of: loginButton, matching: find.byType(DecoratedBox)).first,
    );
    final gradient =
        (surface.decoration as BoxDecoration).gradient! as LinearGradient;
    expect(gradient.begin, Alignment.centerLeft);
    expect(gradient.end, Alignment.centerRight);
    expect(gradient.colors, const [Color(0xFF3CBF5F), Color(0xFF67E780)]);
    final textLuminance = DigiGymDarkColors.graphite.computeLuminance();
    for (final color in gradient.colors) {
      expect(
        (color.computeLuminance() + .05) / (textLuminance + .05),
        greaterThan(4.5),
      );
    }
  });

  testWidgets('empty input and rejected credentials keep existing feedback', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final api = _CountingApi()..loginError = StateError('Rejected');
    await pumpLogin(tester, api: api);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text('Enter your email and password.'), findsOneWidget);
    expect(api.loginCalls, 0);
    ScaffoldMessenger.of(tester.element(email)).removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.enterText(email, 'test@example.com');
    await tester.enterText(password, 'secret12');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(api.loginCalls, 1);
    expect(
      find.text('Unable to sign in. Check your credentials and connection.'),
      findsOneWidget,
    );
    expect(tester.widget<ElevatedButton>(loginButton).onPressed, isNotNull);
    expect(DigiGymSession.currentUser, isNull);
  });

  testWidgets(
    'pending API login is single flight and success clears password',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final gate = Completer<void>();
      final api = _CountingApi()..loginWait = gate.future;
      UserProfile? result;
      var completions = 0;
      await pumpLogin(
        tester,
        api: api,
        onLogin: (user) {
          completions++;
          result = user;
        },
      );
      await tester.enterText(email, 'test@example.com');
      await tester.enterText(password, 'secret12');
      final submit = tester.widget<TextField>(password).onSubmitted!;
      submit('secret12');
      submit('secret12');
      await tester.pump();
      expect(api.loginCalls, 1);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<TextField>(email).readOnly, isTrue);
      gate.complete();
      await tester.pumpAndSettle();
      expect(completions, 1);
      expect(result!.email, 'test@example.com');
      expect(DigiGymSession.currentUser, same(result));
      expect(tester.widget<TextField>(password).controller!.text, isEmpty);
    },
  );

  testWidgets('the existing demo credentials bypass the API', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final api = _CountingApi();
    UserProfile? result;
    await pumpLogin(tester, api: api, onLogin: (user) => result = user);
    await tester.enterText(email, 'demo@gym.com');
    await tester.enterText(password, '123456');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(api.loginCalls, 0);
    expect(result!.isDemo, isTrue);
    expect(result!.name, 'Demo User');
    expect(tester.widget<TextField>(password).controller!.text, isEmpty);
  });

  testWidgets(
    'profile setup still navigates to assessment and clears secrets',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final api = _CountingApi()
        ..loginError = const ProfileSetupRequiredException(
          'pending@example.com',
        );
      await pumpLogin(tester, api: api);
      DigiGymSession.pendingRegistrationPassword =
          'retained registration password';
      await tester.enterText(email, 'pending@example.com');
      await tester.enterText(password, 'secret12');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      expect(find.text('Assessment destination'), findsOneWidget);
      expect(DigiGymSession.pendingUser!.email, 'pending@example.com');
      expect(DigiGymSession.pendingRegistrationPassword, isNull);
    },
  );

  testWidgets('Sign Up preserves the original registration route and API', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final api = _CountingApi();
    await pumpLogin(tester, api: api);
    await tester.tap(find.widgetWithText(TextButton, 'Sign Up'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<RegisterScreen>(find.byType(RegisterScreen)).api,
      same(api),
    );
    expect(
      Theme.of(tester.element(find.byType(TextFormField).first)).brightness,
      Brightness.dark,
    );
    expect(api.loginCalls, 0);
  });

  testWidgets(
    'narrow, short, keyboard and 3x layouts keep every action reachable',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final size in [
        const Size(320, 568),
        const Size(390, 844),
        const Size(1280 / 3, 952),
      ]) {
        for (final scale in [1.0, 1.5, 2.0, 3.0]) {
          for (final keyboard in [0.0, 280.0]) {
            await pumpLogin(
              tester,
              size: size,
              scale: scale,
              keyboard: keyboard,
            );
            for (final target in [
              email,
              password,
              find.widgetWithText(TextButton, 'Forgot Password?'),
              loginButton,
              find.widgetWithText(TextButton, 'Sign Up'),
            ]) {
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
              reason: '$size / $scale / $keyboard',
            );
          }
        }
      }
    },
  );
}
