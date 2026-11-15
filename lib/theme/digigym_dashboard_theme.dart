import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared palette for DigiGym's dark appearance.
abstract final class DigiGymDarkColors {
  static const graphite = Color(0xFF0C1010);
  static const charcoal = Color(0xFF1A201E);
  static const electricGreen = Color(0xFF70FF45);
  // Softer right-hand stop of the approved Login button gradient.
  static const softGreen = Color(0xFF67E780);
  // Existing Profile Log Out red, shared with destructive dialog actions.
  static const destructive = Color(0xFFFF5F68);
  static const primaryText = Color(0xFFF4F7F5);
  static const secondaryText = Color(0xFFABB5AF);
}

/// Semantic colors shared by saved fitness-level labels and indicators.
abstract final class DigiGymFitnessLevelColors {
  static const beginner = Color(0xFF45D98A);
  static const intermediate = Color(0xFFF2A34A);
  static const advanced = Color(0xFFF26B6B);

  static Color forLevel(String level) => switch (level.trim().toLowerCase()) {
    'beginner' => beginner,
    'intermediate' => intermediate,
    'advanced' => advanced,
    _ => DigiGymDarkColors.primaryText,
  };
}

/// Central application palettes; content typography stays scoped so navigation
/// keeps the approved Sprint 2 font metrics.
abstract final class DigiGymDashboardTheme {
  static const textFont = 'DigiGymInter';
  static const numberFont = 'DigiGymDoto';
  static const cardRadius = 16.0;

  /// Only the light dashboard calorie flame: a compact warm separation shadow.
  static const calorieFlameLightShadow = Shadow(
    color: Color(0x487F6A24),
    blurRadius: 2.2,
    offset: Offset(0, .75),
  );

  /// Apply to page content, leaving navigation typography untouched.
  static ThemeData content(ThemeData base) =>
      base.copyWith(textTheme: base.textTheme.apply(fontFamily: textFont));

  static ThemeData dark(ThemeData base) {
    final colors =
        ColorScheme.fromSeed(
          seedColor: DigiGymDarkColors.electricGreen,
          brightness: Brightness.dark,
        ).copyWith(
          primary: DigiGymDarkColors.electricGreen,
          onPrimary: DigiGymDarkColors.graphite,
          primaryContainer: Color.alphaBlend(
            DigiGymDarkColors.electricGreen.withValues(alpha: 0.12),
            DigiGymDarkColors.charcoal,
          ),
          onPrimaryContainer: DigiGymDarkColors.electricGreen,
          surface: DigiGymDarkColors.charcoal,
          onSurface: DigiGymDarkColors.primaryText,
          onSurfaceVariant: DigiGymDarkColors.secondaryText,
          outlineVariant: DigiGymDarkColors.primaryText.withValues(alpha: 0.08),
        );
    final text = base.textTheme.apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
    );

    return base.copyWith(
      extensions: [
        ...base.extensions.values.where((value) => value is! DigiGymSurfaces),
        DigiGymSurfaces.dark,
      ],
      colorScheme: colors,
      scaffoldBackgroundColor: DigiGymDarkColors.graphite,
      canvasColor: DigiGymDarkColors.graphite,
      textTheme: text,
      iconTheme: base.iconTheme.copyWith(color: colors.primary),
      dividerColor: colors.outlineVariant,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      listTileTheme: base.listTileTheme.copyWith(iconColor: colors.primary),
      expansionTileTheme: base.expansionTileTheme.copyWith(
        textColor: colors.primary,
        collapsedTextColor: colors.onSurface,
        iconColor: colors.primary,
        collapsedIconColor: colors.onSurfaceVariant,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: DigiGymDarkColors.charcoal.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
    );
  }

  static ThemeData light(ThemeData base) {
    final colors =
        ColorScheme.fromSeed(
          seedColor: DigiGymDarkColors.electricGreen,
          brightness: Brightness.light,
        ).copyWith(
          // Retain the electric brand green for fills; use accent for small text
          // and icons to maintain contrast on frosted white surfaces.
          primary: DigiGymDarkColors.electricGreen,
          onPrimary: const Color(0xFF15221B),
          primaryContainer: const Color(0xFFE0F0E2),
          onPrimaryContainer: DigiGymSurfaces.light.accent,
          surface: const Color(0xFFFAFAFB),
          onSurface: const Color(0xFF121418),
          onSurfaceVariant: const Color(0xFF606C65),
          outlineVariant: const Color(0x241E3529),
        );
    return base.copyWith(
      colorScheme: colors,
      scaffoldBackgroundColor: const Color(0xFFF0F1F3),
      canvasColor: const Color(0xFFF0F1F3),
      textTheme: base.textTheme.apply(
        bodyColor: colors.onSurface,
        displayColor: colors.onSurface,
      ),
      iconTheme: base.iconTheme.copyWith(color: DigiGymSurfaces.light.accent),
      dividerColor: colors.outlineVariant,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extensions: [
        ...base.extensions.values.where((value) => value is! DigiGymSurfaces),
        DigiGymSurfaces.light,
      ],
    );
  }

  /// Legacy routes remain dark during the dashboard-only Stage 1 rollout.
  static ThemeData resolve(ThemeData base) =>
      base.extension<DigiGymSurfaces>() == null ? dark(base) : base;

  /// Retains the approved Stage 1B BMI material while dashboard glass evolves.
  static ThemeData bmiDialog(ThemeData base) {
    if (base.brightness == Brightness.dark) return base;
    final surfaces = base.extension<DigiGymSurfaces>()!;
    return base.copyWith(
      extensions: [
        ...base.extensions.values.where((value) => value is! DigiGymSurfaces),
        surfaces.copyWith(
          glass: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xEBFFFFFF),
                Color(0xCEF8F9FB),
                Color(0xD5E9ECF0),
                Color(0xE6FFFFFF),
              ],
              stops: [0, .28, .72, 1],
            ),
          ),
          glassLighting: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(.65, -1.25),
              radius: 1.5,
              colors: [Color(0xB8FFFFFF), Color(0x26FFFFFF), Color(0x00FFFFFF)],
              stops: [0, .35, 1],
            ),
          ),
          glassEdge: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xD9FFFFFF),
              Color(0x1A78818E),
              Color(0x3078818E),
              Color(0xF2FFFFFF),
            ],
            stops: [0, .16, .48, .76, 1],
          ),
          glassShadow: const BoxShadow(
            color: Color(0x16545D6B),
            blurRadius: 24,
            offset: Offset(0, 9),
          ),
        ),
      ],
    );
  }
}

/// Non-Material treatments, kept together with interpolation for theme changes.
/// Geometry lives in existing widgets; these values only control appearance.
@immutable
class DigiGymSurfaces extends ThemeExtension<DigiGymSurfaces> {
  final BoxDecoration background;
  final BoxDecoration atmosphere;
  final BoxDecoration glass;
  final BoxDecoration glassLighting;
  final Gradient glassEdge;
  final BoxShadow glassShadow;
  final Color accent;
  final Color onAccent;
  final Color warmAccent;
  final Color progressTrack;
  final Color streakAccent;
  final BoxDecoration streak;
  final Gradient notification;
  final Color navigationActive;
  final Color navigationInactive;
  final Color navigationSurface;
  final Color navigationBorder;
  final BoxShadow navigationShadow;
  final double navigationGlowOpacity;
  final double navigationGlowSigma;
  final double glowIntensity;
  final Color iconWell;
  final Color iconWellBottom;
  final Color iconShadow;
  final Gradient iconLighting;
  final double numberScale;
  final double dotoWeightBoost;
  final double dotFillRatio;
  final double bmiSurfaceOpacity;
  final double bmiBackdropSigma;
  final double selectionGlowOpacity;
  final double iconCoreSigma;
  final double iconCoreOpacity;
  final double iconOuterSigma;
  final double iconOuterOpacity;
  final double iconStrokeHighlight;
  final double iconHighlightInset;
  final double navigationBackdropSigma;
  final Color numeralInk;

  const DigiGymSurfaces({
    required this.background,
    required this.atmosphere,
    required this.glass,
    required this.glassLighting,
    required this.glassEdge,
    required this.glassShadow,
    required this.accent,
    required this.onAccent,
    required this.warmAccent,
    required this.progressTrack,
    required this.streakAccent,
    required this.streak,
    required this.notification,
    required this.navigationActive,
    required this.navigationInactive,
    required this.navigationSurface,
    required this.navigationBorder,
    required this.navigationShadow,
    required this.navigationGlowOpacity,
    required this.navigationGlowSigma,
    required this.glowIntensity,
    required this.iconWell,
    required this.iconWellBottom,
    required this.iconShadow,
    required this.iconLighting,
    this.numberScale = 1,
    this.dotoWeightBoost = 0,
    this.dotFillRatio = .68,
    this.bmiSurfaceOpacity = 1,
    this.bmiBackdropSigma = 0,
    this.selectionGlowOpacity = 0,
    this.iconCoreSigma = 0,
    this.iconCoreOpacity = 0,
    this.iconOuterSigma = 0,
    this.iconOuterOpacity = 0,
    this.iconStrokeHighlight = 0,
    this.iconHighlightInset = 0,
    this.navigationBackdropSigma = 14,
    this.numeralInk = DigiGymDarkColors.primaryText,
  });

  static DigiGymSurfaces of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<DigiGymSurfaces>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  static final dark = DigiGymSurfaces(
    background: BoxDecoration(
      color: DigiGymDarkColors.graphite,
      gradient: RadialGradient(
        center: Alignment(1.2, -0.6),
        radius: 1.6,
        colors: [Color(0xFF202C30), DigiGymDarkColors.graphite],
        stops: [0, 0.85],
      ),
    ),
    atmosphere: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-1.1, 1.2),
        radius: 1.25,
        colors: [Color(0x0D39FF98), Color(0x0039FF98)],
      ),
    ),
    glass: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xF23B474A),
          Color(0xEE192123),
          Color(0xF00F1618),
          Color(0xF0222D2F),
        ],
        stops: [0, 0.28, 0.72, 1],
      ),
    ),
    glassLighting: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(0.85, -1.15),
        radius: 1.1,
        colors: [Color(0x20FFFFFF), Color(0x06FFFFFF), Color(0x00FFFFFF)],
        stops: [0, 0.35, 1],
      ),
    ),
    glassEdge: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x70D5E1DF),
        Color(0x26D5E1DF),
        Color(0x05D5E1DF),
        Color(0x12D5E1DF),
        Color(0x38D5E1DF),
      ],
      stops: [0, 0.16, 0.48, 0.76, 1],
    ),
    glassShadow: BoxShadow(
      color: Color(0x38000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
    accent: DigiGymDarkColors.softGreen,
    onAccent: DigiGymDarkColors.graphite,
    warmAccent: Color(0xFFFFD35B),
    progressTrack: Color(0xFF2B3530),
    streakAccent: Color(0xFFFFAA58),
    streak: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xE032302B), Color(0xE619211F), Color(0xE6212723)],
        stops: [0, 0.55, 1],
      ),
      border: Border.all(
        color: const Color(0xFFFFAA58).withValues(alpha: 0.30),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFFAA58).withValues(alpha: 0.11),
          blurRadius: 12,
          spreadRadius: -1,
        ),
      ],
    ),
    notification: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x9634413D), Color(0x66151D1A)],
    ),
    navigationActive: DigiGymDarkColors.electricGreen,
    navigationInactive: Color(0xFFA6AEAA),
    navigationSurface: Color(0x331A201E),
    navigationBorder: Colors.white.withValues(alpha: 0.15),
    navigationShadow: BoxShadow(
      color: Colors.black.withValues(alpha: 0.22),
      blurRadius: 18,
      offset: Offset(0, 5),
      blurStyle: BlurStyle.outer,
    ),
    navigationGlowOpacity: 0.85,
    navigationGlowSigma: 4,
    glowIntensity: 1,
    iconWell: Color(0xFF14231C),
    iconWellBottom: Color(0xFF0E1916),
    iconShadow: Color(0x45000000),
    iconLighting: RadialGradient(
      center: Alignment(-0.55, -0.8),
      radius: 0.95,
      colors: [Color(0x24FFFFFF), Color(0x00FFFFFF), Color(0x28000000)],
      stops: [0, 0.5, 1],
    ),
  );

  static const light = DigiGymSurfaces(
    background: BoxDecoration(
      color: Color(0xFFF0F1F3),
      gradient: LinearGradient(
        begin: Alignment(-1, -0.85),
        end: Alignment(1, 0.9),
        colors: [
          Color(0xFFFCFDFE),
          Color(0xFFC9CFD8),
          Color(0xFFE3E7ED),
          Color(0xFFBBC3CE),
          Color(0xFFD9DFE7),
        ],
        stops: [0, 0.30, 0.56, 0.82, 1],
      ),
    ),
    atmosphere: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.7, -1.1),
        radius: 1.7,
        colors: [Color(0xCCFFFFFF), Color(0x26FFFFFF), Color(0x00FFFFFF)],
        stops: [0, 0.55, 1],
      ),
    ),
    glass: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xE0FFFFFF),
          Color(0xC2F8F9FC),
          Color(0xC3E4E9F0),
          Color(0xDDFFFFFF),
        ],
        stops: [0, 0.28, 0.72, 1],
      ),
    ),
    glassLighting: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(0.65, -1.25),
        radius: 1.5,
        colors: [Color(0xA8FFFFFF), Color(0x20FFFFFF), Color(0x00FFFFFF)],
        stops: [0, 0.35, 1],
      ),
    ),
    glassEdge: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xEBFFFFFF),
        Color(0x1478818E),
        Color(0x2478818E),
        Color(0xFFFFFFFF),
      ],
      stops: [0, 0.16, 0.48, 0.76, 1],
    ),
    glassShadow: BoxShadow(
      color: Color(0x16545D6B),
      blurRadius: 24,
      offset: Offset(0, 9),
    ),
    accent: Color(0xFF237C47),
    onAccent: Color(0xFFF8F9F6),
    warmAccent: Color(0xFFFFD35B),
    progressTrack: Color(0xFFD4DDD5),
    streakAccent: Color(0xFFFFAA58),
    streak: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xF5FFFAF2), Color(0xE6F5F6EF), Color(0xE6EDF1EA)],
        stops: [0, 0.55, 1],
      ),
      border: Border.fromBorderSide(BorderSide(color: Color(0x29AE5B18))),
      boxShadow: [
        BoxShadow(color: Color(0x0CAE5B18), blurRadius: 12, spreadRadius: -1),
      ],
    ),
    notification: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xE6FFFFFF), Color(0xB3E6ECE5)],
    ),
    navigationActive: Color(0xFF237C47),
    navigationInactive: Color(0xFF626C66),
    navigationSurface: Color(0x4DF8F9FB),
    navigationBorder: Color(0xEBFFFFFF),
    navigationShadow: BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 18,
      offset: Offset(0, 5),
    ),
    navigationGlowOpacity: 0.70,
    navigationGlowSigma: 4,
    glowIntensity: 0.78,
    iconWell: Color(0xFFF0F5ED),
    iconWellBottom: Color(0xFFE5EDE4),
    iconShadow: Color(0x1025362B),
    iconLighting: RadialGradient(
      center: Alignment(-0.55, -0.8),
      radius: 0.95,
      colors: [Color(0x80FFFFFF), Color(0x00FFFFFF), Color(0x0C304535)],
      stops: [0, 0.5, 1],
    ),
    numberScale: 1.06,
    dotoWeightBoost: 40,
    dotFillRatio: .74,
    bmiSurfaceOpacity: .94,
    bmiBackdropSigma: 14,
    selectionGlowOpacity: .16,
    iconCoreSigma: .45,
    iconCoreOpacity: .75,
    iconOuterSigma: 2.8,
    iconOuterOpacity: .26,
    iconStrokeHighlight: .62,
    iconHighlightInset: .55,
    navigationBackdropSigma: 16,
    numeralInk: Colors.black,
  );

  @override
  DigiGymSurfaces copyWith({
    BoxDecoration? background,
    BoxDecoration? atmosphere,
    BoxDecoration? glass,
    BoxDecoration? glassLighting,
    Gradient? glassEdge,
    BoxShadow? glassShadow,
    Color? accent,
    Color? onAccent,
    Color? warmAccent,
    Color? progressTrack,
    Color? streakAccent,
    BoxDecoration? streak,
    Gradient? notification,
    Color? navigationActive,
    Color? navigationInactive,
    Color? navigationSurface,
    Color? navigationBorder,
    BoxShadow? navigationShadow,
    double? navigationGlowOpacity,
    double? navigationGlowSigma,
    double? glowIntensity,
    Color? iconWell,
    Color? iconWellBottom,
    Color? iconShadow,
    Gradient? iconLighting,
    double? numberScale,
    double? dotoWeightBoost,
    double? dotFillRatio,
    double? bmiSurfaceOpacity,
    double? bmiBackdropSigma,
    double? selectionGlowOpacity,
    double? iconCoreSigma,
    double? iconCoreOpacity,
    double? iconOuterSigma,
    double? iconOuterOpacity,
    double? iconStrokeHighlight,
    double? iconHighlightInset,
    double? navigationBackdropSigma,
    Color? numeralInk,
  }) => DigiGymSurfaces(
    background: background ?? this.background,
    atmosphere: atmosphere ?? this.atmosphere,
    glass: glass ?? this.glass,
    glassLighting: glassLighting ?? this.glassLighting,
    glassEdge: glassEdge ?? this.glassEdge,
    glassShadow: glassShadow ?? this.glassShadow,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    warmAccent: warmAccent ?? this.warmAccent,
    progressTrack: progressTrack ?? this.progressTrack,
    streakAccent: streakAccent ?? this.streakAccent,
    streak: streak ?? this.streak,
    notification: notification ?? this.notification,
    navigationActive: navigationActive ?? this.navigationActive,
    navigationInactive: navigationInactive ?? this.navigationInactive,
    navigationSurface: navigationSurface ?? this.navigationSurface,
    navigationBorder: navigationBorder ?? this.navigationBorder,
    navigationShadow: navigationShadow ?? this.navigationShadow,
    navigationGlowOpacity: navigationGlowOpacity ?? this.navigationGlowOpacity,
    navigationGlowSigma: navigationGlowSigma ?? this.navigationGlowSigma,
    glowIntensity: glowIntensity ?? this.glowIntensity,
    iconWell: iconWell ?? this.iconWell,
    iconWellBottom: iconWellBottom ?? this.iconWellBottom,
    iconShadow: iconShadow ?? this.iconShadow,
    iconLighting: iconLighting ?? this.iconLighting,
    numberScale: numberScale ?? this.numberScale,
    dotoWeightBoost: dotoWeightBoost ?? this.dotoWeightBoost,
    dotFillRatio: dotFillRatio ?? this.dotFillRatio,
    bmiSurfaceOpacity: bmiSurfaceOpacity ?? this.bmiSurfaceOpacity,
    bmiBackdropSigma: bmiBackdropSigma ?? this.bmiBackdropSigma,
    selectionGlowOpacity: selectionGlowOpacity ?? this.selectionGlowOpacity,
    iconCoreSigma: iconCoreSigma ?? this.iconCoreSigma,
    iconCoreOpacity: iconCoreOpacity ?? this.iconCoreOpacity,
    iconOuterSigma: iconOuterSigma ?? this.iconOuterSigma,
    iconOuterOpacity: iconOuterOpacity ?? this.iconOuterOpacity,
    iconStrokeHighlight: iconStrokeHighlight ?? this.iconStrokeHighlight,
    iconHighlightInset: iconHighlightInset ?? this.iconHighlightInset,
    navigationBackdropSigma:
        navigationBackdropSigma ?? this.navigationBackdropSigma,
    numeralInk: numeralInk ?? this.numeralInk,
  );

  @override
  DigiGymSurfaces lerp(DigiGymSurfaces? other, double t) {
    if (other == null) return this;
    double mix(double a, double b) => a + (b - a) * t;
    return DigiGymSurfaces(
      background: BoxDecoration.lerp(background, other.background, t)!,
      atmosphere: BoxDecoration.lerp(atmosphere, other.atmosphere, t)!,
      glass: BoxDecoration.lerp(glass, other.glass, t)!,
      glassLighting: BoxDecoration.lerp(glassLighting, other.glassLighting, t)!,
      glassEdge: Gradient.lerp(glassEdge, other.glassEdge, t)!,
      glassShadow: BoxShadow.lerp(glassShadow, other.glassShadow, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      warmAccent: Color.lerp(warmAccent, other.warmAccent, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      streakAccent: Color.lerp(streakAccent, other.streakAccent, t)!,
      streak: BoxDecoration.lerp(streak, other.streak, t)!,
      notification: Gradient.lerp(notification, other.notification, t)!,
      navigationActive: Color.lerp(
        navigationActive,
        other.navigationActive,
        t,
      )!,
      navigationInactive: Color.lerp(
        navigationInactive,
        other.navigationInactive,
        t,
      )!,
      navigationSurface: Color.lerp(
        navigationSurface,
        other.navigationSurface,
        t,
      )!,
      navigationBorder: Color.lerp(
        navigationBorder,
        other.navigationBorder,
        t,
      )!,
      navigationShadow: BoxShadow.lerp(
        navigationShadow,
        other.navigationShadow,
        t,
      )!,
      navigationGlowOpacity: mix(
        navigationGlowOpacity,
        other.navigationGlowOpacity,
      ),
      navigationGlowSigma: mix(navigationGlowSigma, other.navigationGlowSigma),
      glowIntensity: mix(glowIntensity, other.glowIntensity),
      iconWell: Color.lerp(iconWell, other.iconWell, t)!,
      iconWellBottom: Color.lerp(iconWellBottom, other.iconWellBottom, t)!,
      iconShadow: Color.lerp(iconShadow, other.iconShadow, t)!,
      iconLighting: Gradient.lerp(iconLighting, other.iconLighting, t)!,
      numberScale: mix(numberScale, other.numberScale),
      dotoWeightBoost: mix(dotoWeightBoost, other.dotoWeightBoost),
      dotFillRatio: mix(dotFillRatio, other.dotFillRatio),
      bmiSurfaceOpacity: mix(bmiSurfaceOpacity, other.bmiSurfaceOpacity),
      bmiBackdropSigma: mix(bmiBackdropSigma, other.bmiBackdropSigma),
      selectionGlowOpacity: mix(
        selectionGlowOpacity,
        other.selectionGlowOpacity,
      ),
      iconCoreSigma: mix(iconCoreSigma, other.iconCoreSigma),
      iconCoreOpacity: mix(iconCoreOpacity, other.iconCoreOpacity),
      iconOuterSigma: mix(iconOuterSigma, other.iconOuterSigma),
      iconOuterOpacity: mix(iconOuterOpacity, other.iconOuterOpacity),
      iconStrokeHighlight: mix(iconStrokeHighlight, other.iconStrokeHighlight),
      iconHighlightInset: mix(iconHighlightInset, other.iconHighlightInset),
      navigationBackdropSigma: mix(
        navigationBackdropSigma,
        other.navigationBackdropSigma,
      ),
      numeralInk: Color.lerp(numeralInk, other.numeralInk, t)!,
    );
  }
}
