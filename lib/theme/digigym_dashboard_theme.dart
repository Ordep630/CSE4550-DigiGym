import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared palette for DigiGym's dark appearance.
abstract final class DigiGymDarkColors {
  static const graphite = Color(0xFF0C1010);
  static const charcoal = Color(0xFF1A201E);
  static const electricGreen = Color(0xFF70FF45);
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

/// Builds a scoped theme using semantic colors that widgets can also consume
/// from a future application-wide dark or light theme.
abstract final class DigiGymDashboardTheme {
  static const textFont = 'DigiGymInter';
  static const numberFont = 'DigiGymDoto';
  static const cardRadius = 16.0;

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
}
